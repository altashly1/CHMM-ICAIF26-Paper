# Paper Readiness Review — Third Full Audit

**Paper:** *Heavy-Tail Hidden Markov Generators for Daily Equity Returns: Stylized Facts and Filter-Conditional Value-at-Risk*

**Target:** 7th ACM International Conference on AI in Finance (ICAIF '26)

**Audit date:** July 15, 2026

**Paper commit:** `6d6ae62`

**Model/artifact commit:** `ad8e24c`

## Executive verdict

The manuscript is a **strong topical fit for ICAIF '26**, and the technical corrections from the first two audits are now reflected consistently in the paper, code, and stored artifacts. The spectral panel has been recomputed under the manuscript's declared modulus definition, the conclusion is now SPY-specific rather than panel-wide, the shared-`nu` CRPS value is stored, and the PDF is cleanly rendered at the eight-page limit.

The paper is nevertheless **not ready to submit unchanged**. One remaining issue is a submission blocker because it affects the provenance of every 2025–2026 out-of-sample observation:

> The claimed 323-session Polygon/Alpaca overlap check does not compare two vendors. The dataset called “Polygon OoS” by the diagnostic already contains the Alpaca extension, so the diagnostic compares the Alpaca rows with themselves and necessarily reports an exact match.

The raw files have no overlap: the Polygon file ends on December 31, 2024, and the Alpaca/IEX file begins on January 3, 2025. The manuscript also incorrectly says its daily VWAPs are constructed from typical price and volume; the analyses consume the vendors' stored daily `volume_weighted_average_price` field, which is observably different from `(high + low + close)/3`.

### Readiness scores

| Dimension | Score | Assessment |
|---|---:|---|
| Technical accuracy | **8.0/10** | Core HMM, spectral, generator, and VaR claims are careful; data-lineage validation must be corrected. |
| Empirical correctness | **7.5/10** | Headline numbers trace to committed artifacts, but the mixed-feed OoS series has not received a valid cross-vendor check. |
| Narrative flow | **8.0/10** | Stronger configuration mapping and caveats; abstract/results remain dense and two claims should be tightened. |
| ICAIF topical fit | **9.5/10** | Direct match to synthetic financial data, model validation, risk modeling, and financial time series. |
| Submission readiness | **7.5/10** | Formatting passes; one data-provenance blocker plus several small wording corrections remain. |

## 1. Submission blocker: the vendor-stitch check is circular

### What the manuscript claims

Section 5 states that the Polygon and Alpaca vendors have a 323-session overlap that “passes an exact stitch check.” The diagnostic artifact reports zero VWAP and return differences and a KS statistic of zero over those 323 sessions.

### What the repository actually does

`build_new_train_oos.jl` loads and concatenates:

- `SP500-Daily-OHLC-1-3-2014-to-12-31-2024.jld2`; and
- `SP500-Daily-OHLC-1-3-2025-to-4-20-2026.jld2`.

A direct read of the SPY tables gives:

| Raw file | Rows | Actual dates |
|---|---:|---|
| Polygon/Massive file | 2,767 | 2014-01-03 to 2024-12-31 |
| Alpaca extension | 323 | 2025-01-03 to 2026-04-20 |
| Constructed OoS file | 573 prices | 2024-01-04 to 2026-04-20 |

There are therefore **zero overlapping source dates**.

In `runners/diagnostics/run_vendor_stitch_check.jl`, `polygon_oos` is loaded through `MyOutOfSamplePortfolioDataSet()`. That file is not Polygon-only: it was constructed by the concatenation above and already contains all 323 Alpaca rows. The runner then intersects its 2025–2026 dates with the original Alpaca extension and compares the same stored rows. This explains the otherwise implausible exact equality:

- VWAP relative difference: exactly `0`;
- return difference: exactly `0`; and
- two-sample KS: `D = 0`, `p = 1`.

The runner's stated source spans and November 19, 2025 stitch date do not match the raw data boundary. The actual vendor boundary is between December 31, 2024 and January 3, 2025.

### Why this matters

The held-out series uses Polygon observations through 2024 and Alpaca/IEX observations from 2025 onward. Alpaca's official documentation describes IEX as a single-exchange feed representing roughly 2.5% of market volume, whereas SIP represents all U.S. exchanges. A change from a consolidated aggregate to IEX-only bars can change volume, VWAP, tail measurements, and apparent distribution shift. The issue does not prove that the reported HMM conclusions are wrong, but it means the current artifact provides no evidence that the vendor change is innocuous.

### Required action

Before submission, do one of the following, in order of evidential strength:

1. **Preferred:** rebuild all IS and OoS observations from one consistent feed and rerun every OoS-dependent table and statement.
2. Obtain a genuine common-date Polygon-versus-Alpaca overlap, compare VWAP and returns, and rerun the key OoS metrics under each source over the overlap and post-boundary window.
3. If a consistent or overlapping source cannot be obtained before the deadline, remove the false overlap claim, disclose the exact source boundary, and label feed change as an unresolved OoS confound. This is weaker and should be paired with a close-return or same-vendor sensitivity analysis where possible.

Any changed values must be propagated through the abstract, Table 1, Table 2, Table 3, the panel/refit discussion, and conclusion.

## 2. Required correction: VWAP provenance is described incorrectly

Section 5 says:

> Prices are session-cumulative VWAPs built from the typical price `(high + low + close)/3` and volume.

The experiment runners instead read the existing `volume_weighted_average_price` column from each vendor table. Direct inspection confirms that this field is not the typical price. For SPY, the mean absolute difference between stored VWAP and typical price is about `0.250` in the Polygon file and `0.432` in the Alpaca file; individual differences reach several dollars.

`src/Compute.jl` contains a `vwap(df)` helper based on cumulative typical-price × volume, but repository search finds no experiment runner calling it. On a daily-bar DataFrame that helper would also accumulate across sessions rather than reconstruct an intraday session VWAP.

**Required wording:** identify `P_{i,j}` as the **vendor-provided daily aggregate VWAP field**, name the source and feed for each date range, and remove the typical-price construction claim. If the intended data are in fact locally constructed VWAPs, the dataset must be rebuilt and all results rerun using a documented intraday aggregation.

## 3. Important claim and narrative corrections

### Refit is an improvement, not a demonstrated remedy for regime drift

The abstract recommends periodic refitting “when regimes drift,” while the limitations section says that no tested refit cadence repaired the COVID or 2022 rate-hike stress folds. The positive evidence is narrower: quarterly refitting improved median cross-ticker marginal KS from `69.1%` to `84.7%` and reduced sub-60% failures from `11/30` to `8/30`.

Use the narrower conclusion throughout:

> Quarterly refitting improves marginal fidelity on the non-stress cross-ticker panel, but it does not solve abrupt stress-regime shifts in the tested walk-forward folds.

Similarly, replace “quarterly refit did recover the non-stress cross-ticker panel” in the conclusion with “improved the non-stress cross-ticker panel.”

### CRPS does not make family choice depend on kurtosis alone

Section 6.2 says the similar CRPS values mean “the family choice is driven by the per-row kurtosis match.” That is inconsistent with the selected shared-`nu` row: CHMM-L and CHMM-GED have closer OoS kurtosis to the observed `5.29`, while shared-`nu` has the best CHMM OoS KS and avoids a penalty hyperparameter.

Suggested correction:

> CRPS does not distinguish the four CHMM rows at the reported precision; the preferred shared-`nu` row is selected on the joint KS–kurtosis–regularization trade-off, not kurtosis alone.

### Clarify “mode” for complex eigenvalues

The spectral definition is now internally consistent: both scripts and paper use `|a_k lambda_k|`. However, the code counts each member of a complex-conjugate eigenvalue pair separately, while the theory text correctly notes that a pair combines into one real damped-oscillatory component. Therefore `n95 = 7` means seven **eigen-contributions**, not necessarily seven distinct real decay/oscillation modes.

Either group conjugate pairs before computing `n95`, or rename the reported quantity to “number of non-unit eigen-contributions needed for 95%.” The dominant-share convention itself is acceptable because it is explicitly defined.

### Parameter budgets use different initial-distribution treatments

The 12-parameter Gaussian fitter holds the initial state vector uniform, while the 15-parameter shared-`nu` fitter updates its `K - 1` free initial probabilities. The paper discloses this in Section 3, and unconditional simulations start from each fitted transition matrix's stationary law, so this is not a hidden numerical error. Still, the “12 versus 15” compactness comparison is not an emission-only comparison.

For maximum clarity, either standardize the initial-distribution treatment or add one short phrase where the budgets are advertised: “under their implemented initial-state conventions.”

## 4. Corrections from the second audit that are now resolved

The following items now pass:

- **Cross-ticker spectral implementation:** the runner now uses `abs(a_k * lambda_k)`, matching Section 4.
- **Cross-ticker interpretation:** the paper reports median dominant share `0.726`, minimum `0.287`, and median `n95 = 7`, and explicitly rejects a panel-wide near-one-mode reading.
- **SPY control:** the cross-ticker run reproduces the SPY `K = 18` share of `0.936`.
- **Shared-`nu` CRPS:** a committed artifact reports OoS CRPS `1.0406` under the same sample-CRPS implementation.
- **Hill paragraph:** family-specific tail and kurtosis values are no longer mixed.
- **ACF wording:** the undefined “tolerance” language has been removed.
- **Configuration attribution:** Table 2 clearly maps Gaussian VaR, shared-`nu` SPY generation, and penalized per-state Student-t panel claims.
- **Layout:** the validation table now appears before the VaR table, conclusion, and references; it no longer interrupts the bibliography.
- **Metadata:** placeholder DOI/ISBN text is absent.

## 5. Technical assessment

### Strong points

- The paper correctly states that the CHMM is established and frames the contribution as comparative estimation, a spectral diagnostic, and a filter-conditional risk head.
- The spectral identity is stated with its stationarity, finite-moment, and diagonalizability conditions.
- The paper distinguishes the algebraic `K - 1` upper bound from empirical effective contribution.
- The SPY-only conclusion is supported by the stored `K = 2`, `K = 3`, and `K = 18` artifacts.
- Non-diagonalizable and complex-eigenvalue cases are acknowledged instead of being silently ignored.
- The Student-t and GED update routines are accurately described as generalized/hybrid block-coordinate procedures without claiming guaranteed ECME monotonicity.
- The HSMM duration update is correctly labeled moment-approximate rather than maximum-likelihood.
- VaR is correctly defined as the quantile of the one-step-ahead filtered predictive mixture, distinct from a state-specific VaR or expected shortfall.
- Backtest non-rejection is interpreted as compatibility, not proof, and the low power of the 1% tail tests is disclosed.
- The paper is unusually candid about benchmark wins, stress-fold failures, the reduced QuantGAN implementation, lack of privacy guarantees, and the penalized Student-t kurtosis artifact.

### Residual methodological risks, appropriately disclosed

- The primary KS pass rate is descriptive because serial dependence invalidates the ordinary i.i.d. calibration; Wasserstein-1 and other distances partly mitigate this.
- The model family changes across headline tasks. The configuration map makes this readable, but reviewers may still prefer one prespecified primary configuration.
- The recommended shared-`nu` default is supported most directly on SPY, not on the cross-ticker panel, which uses the penalized per-state model.
- The QuantGAN row is a reduced in-house negative control, not a faithful reproduction of the published architecture.
- The paper does not model leverage effects, far-tail asymptotics, multivariate dependence, or explicit-duration risk forecasts.

## 6. Narrative flow and correctness

### What now works

- The title accurately signals the model, data frequency, stylized-fact objective, and risk application.
- The introduction cleanly separates temporal and marginal channels and avoids claiming a new HMM class.
- The revised SPY-versus-panel spectral narrative is coherent across abstract, introduction, results, and conclusion.
- The configuration map substantially reduces the earlier risk of readers attributing all findings to one fitted model.
- Limitations are concrete and tied to reported evidence rather than generic boilerplate.

### What should still be improved

- **Abstract density:** it contains too many percentages, configurations, and qualifications for one paragraph. Retain the central SPY spectral result, the panel qualification, the preferred generator result, and VaR result; move secondary benchmark details to the body.
- **Figure placement:** Figure 1 is first cited on page 4 but rendered at the top of page 6. Moving it closer to Section 6.1 would make the two-channel argument easier to follow.
- **Results density:** several paragraphs perform result, caveat, comparison, and interpretation simultaneously. Shorter topic sentences would make the main claims easier to audit.
- **Table 1 caption:** the caption is accurate but very long. Some benchmark qualifications can move to the surrounding prose now that page 8 has substantial unused space.

These are narrative improvements, not acceptance blockers.

## 7. ICAIF '26 fit and recommended domain

### Fit: very strong

The official [ICAIF '26 call for papers](https://icaif2026.org/call-for-papers.html) explicitly includes:

- generative AI, simulation, and synthetic data generation;
- AI-driven risk management;
- robustness and uncertainty quantification;
- validation and calibration of financial models;
- risk modeling and risk management;
- forecasting of financial scenarios; and
- financial time-series analysis and factor models.

This paper directly addresses synthetic financial time-series generation, regime-based simulation, model validation, and conditional VaR. Its classical statistical-learning orientation is within scope, though the submission should emphasize the interpretable generative-model and validation contributions so reviewers do not read it as only a traditional regime-switching econometrics paper.

### Recommended submission domain

**Primary domain:** **Methodologies → Generative AI, simulation, and synthetic data generation**

**Secondary methodology tags:**

1. Validation and calibration of financial models
2. AI-driven risk management
3. Robustness and uncertainty quantification

**Application tags:**

1. Risk modeling and risk management
2. Financial time-series analysis and factor models
3. Forecasting of financial scenarios

The CFP lists topic areas rather than promising a formal track taxonomy, so these should be treated as recommended CMT subject areas/keywords if corresponding choices appear in the submission form.

### Acceptance-positioning risk

Topical fit is stronger than novelty positioning. Because the CHMM itself is not new, the paper should foreground three contributions consistently:

1. the finite-mode spectral diagnostic and its SPY-versus-panel empirical interpretation;
2. the controlled heavy-tailed emission comparison under a common fitting/evaluation harness; and
3. the filter-conditional VaR head with rolling-origin validation and explicit failure analysis.

## 8. Formal submission compliance

The official CFP currently gives an **August 2, 2026 Anywhere-on-Earth deadline** and requires a self-contained, double-blind ACM `sigconf` paper of at most eight total pages, with no supplementary appendix.

Current checks:

- PDF pages: **8 / 8**
- ACM `sigconf,anonymous`: **pass**
- Source/PDF/metadata anonymization scan: **pass**
- Citations: **30 used, 30 defined, 0 unused, 0 undefined**
- Visual rendering: **pass**; no clipped tables, figures, or references
- Table/reference order: **pass**
- Placeholder DOI/ISBN: **absent**
- Overfull boxes: three small horizontal boxes (maximum `4.37 pt`) and one `1.13 pt` vertical box; no visible clipping, but worth cleaning if the text is edited

## 9. Priority checklist before submission

### Must fix

1. Correct the circular vendor-stitch diagnostic and the false 323-session overlap claim.
2. Correct the vendor date ranges and actual source boundary.
3. Correct the VWAP provenance/construction description.
4. Run a consistent-feed or genuine cross-vendor sensitivity analysis and propagate any changed OoS results.
5. Rebuild, rerender all eight pages, and rerun `make check`.

### Should fix

6. Narrow the refit conclusion to the evidence actually shown.
7. Replace the “family choice is driven by kurtosis” sentence with the joint trade-off interpretation.
8. Clarify whether `n95` counts eigen-contributions or conjugate-pair real modes.
9. Qualify the 12-versus-15 parameter comparison by its different initial-state conventions.
10. Reduce abstract and Table 1 caption density.

## Bottom line

This is now a technically serious, candid, and well-targeted ICAIF paper. The earlier spectral, configuration, CRPS, and layout blockers are resolved. The remaining obstacle is localized but important: **the manuscript currently makes a false cross-vendor validation claim, and the mixed Polygon/IEX OoS feed has not been validly checked**. Fix that provenance issue and rerun the affected sensitivity analysis; after those changes, the paper should be close to submission-ready.
