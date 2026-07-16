# Paper Readiness Review — Seventh Full Audit

**Paper:** *Heavy-Tail Hidden Markov Generators for Daily Equity Returns: Stylized Facts and Filter-Conditional Value-at-Risk*

**Target:** 7th ACM International Conference on AI in Finance (ICAIF '26)

**Audit date:** July 15, 2026

**Manuscript commit reviewed:** `d77ca88` — `Address sixth audit: claim-level corrections and final-page balance`

**Model/artifact commit reviewed:** `4a196be` — `Report eigenvector condition number in SPY spectral diagnostic`

## Executive verdict

The manuscript is now **technically coherent and essentially submission-ready**. The sixth-audit corrections are accurate: the feed-boundary claim is properly qualified, state-count selection is described consistently, refitting is no longer overgeneralized, the QuantGAN interpretation matches Table 1, the zero-risk-free-rate series is named correctly in the text, the spectral conditioning claim is supported by a committed artifact, and the final bibliography page is balanced.

One small but visible correctness inconsistency remains before submission: **Figure 1's x-axis still reads “Excess Growth Rate,” while the manuscript now correctly defines the series as annualised log growth with `r_f = 0`.** Regenerate or relabel the figure. No model refit is needed for this change.

The central reviewer-facing empirical limitation remains the non-overlapping Polygon-to-Alpaca/IEX feed switch inside the held-out window. The manuscript now discloses it accurately and does not claim that the boundary diagnostic validates feed equivalence.

### Readiness scores

| Dimension | Score | Assessment |
|---|---:|---|
| Technical accuracy | **9.3/10** | Core mathematics, estimation descriptions, state selection, spectral results, and VaR interpretation are internally supported. |
| Empirical correctness | **8.5/10** | Reported values trace to committed artifacts; the mixed-feed held-out period remains a material but explicit limitation. |
| Narrative flow | **9.1/10** | Contribution, validation, limitations, and application now form a clear sequence; only minor density remains. |
| ICAIF topical fit | **9.5/10** | Direct match to synthetic financial data, model validation, financial risk, and time-series analysis. |
| Submission readiness | **9.1/10** | Apply the Figure 1 label correction, rebuild, and visually verify; no other blocking issue was found. |

## 1. Remaining required correction

### Relabel Figure 1's x-axis

The revised model section correctly states that setting `r_f = 0` makes the analyzed series an annualised log growth rate rather than an empirically risk-free-adjusted excess return. The Figure 1 caption and accessibility description also use “growth rate.” The rendered left panel, however, still labels its horizontal axis **“Excess Growth Rate.”**

This comes from the figure-generation code in the model repository, including:

- `runners/headline/run_all_analysis.jl:26`, where `RETURN_LABEL = "Excess Growth Rate"`; and
- `runners/headline/run_figures.jl:104` and `:144`, which use “Excess growth rate.”

Change the label to **“Annualised Log Growth Rate”** or simply **“Growth Rate”**, regenerate `Fig-1-Stylized-Facts-a.pdf`, copy the updated asset into the paper repository, rebuild, and inspect the PDF. This is a terminology-only correction; it does not change any numerical result.

## 2. Verification of the sixth-audit corrections

All prior blocking issues are resolved correctly:

1. **Feed boundary:** Section 5 now describes an unadjusted KS non-rejection, explicitly notes time confounding and lack of dependence calibration, acknowledges volatility/kurtosis differences, and treats the VaR segment counts as descriptive rather than evidence of feed equivalence.
2. **State selection:** The conclusion now says BIC/CAIC select `K = 3`, rolling-origin validation cannot distinguish `K = 3` from `K = 6`, and `K = 18` is disfavored. This matches Table 2 and the stored four-fold/six-fold values.
3. **Periodic refitting:** The introduction now limits the benefit to ordinary drift and states that no tested cadence repaired abrupt stress-regime introductions.
4. **QuantGAN:** The results now say the reduced control fails the heavy-tailed marginal and volatility-clustering diagnostics while retaining near-baseline raw-return autocorrelation. This matches Table 1.
5. **Growth-rate terminology:** The model section correctly distinguishes annualised log growth at `r_f = 0` from empirically risk-free-adjusted excess return. Only the embedded figure label remains stale.
6. **Spectral conditioning:** The paper reports eigenvector-matrix condition numbers of `1.4` at `K = 3` and `7.3` at `K = 18`. The updated committed diagnostic reproduces both values; they are sufficiently modest to support the numerical-stability statement for the SPY decompositions.
7. **Final-page balance:** The `pbalance` option now produces a balanced two-column bibliography without a balance warning.

## 3. Technical accuracy assessment

### Mathematics and estimation

- The paper does not claim that CHMM is a new model class.
- The spectral ACF identity is stated with the necessary stationarity, irreducibility/aperiodicity, finite-moment, and diagonalizability conditions.
- The algebraic `K - 1` modal bound is distinguished from fitted effective contribution.
- Complex-conjugate eigen-contributions and the non-diagonalizable Jordan-form caveat are disclosed.
- The dominant-mode share uses the declared `|a_k lambda_k|` lag-1 contribution rather than eigenvalue magnitude alone.
- Student-t and GED fitting are accurately described as hybrid/generalized block procedures without an unjustified monotonic-likelihood guarantee.
- The Gaussian, Student-t, Laplace, and GED initial-distribution conventions and their effect on parameter counts are explicit.
- The HSMM duration row is correctly called moment-updated rather than maximum-likelihood because the update ignores the truncated normalizer.

### Empirical claims

- BIC/CAIC select `K = 3`; the rolling-origin evidence is appropriately treated as descriptive and does not separate `K = 3` from `K = 6`.
- The SPY modal shares (`0.968` at `K = 3`, `0.936` at `K = 18`) and the panel diagnostic (median `0.726`, minimum `0.287`, median `n95 = 7`) trace to stored artifacts.
- The manuscript correctly limits near-one-mode behavior to SPY rather than claiming it panel-wide.
- The shared-`nu` CRPS value `1.0406` and the other reported generator metrics are present in committed artifacts.
- Configuration-specific conclusions are mapped explicitly in Table 2; the Gaussian, shared-`nu`, and penalized per-state variants are no longer conflated.
- The Hill statistic is treated as a finite-threshold shape diagnostic for light-tailed mixtures rather than an asymptotic tail-index estimate.
- Interval overlap is not presented as a formal equality test.

### Risk analysis

- Filter-conditional VaR is correctly defined as the quantile of the one-step-ahead predictive state mixture.
- It is distinguished from state-specific VaR, expected shortfall, and the Christoffersen conditional-coverage criterion.
- The main-window and walk-forward non-rejections are interpreted as compatibility rather than proof.
- Low power at the 1% tier and multiplicity across the walk-forward panel are disclosed.
- No unsupported pairwise superiority claim is made against filtered bootstrap or CAViaR.

## 4. Empirical credibility and reproducibility

The paper and model repositories were clean at the start of this audit. The replacement boundary diagnostic, corrected spectral-share definition, shared-`nu` CRPS evidence, and eigenvector-conditioning output are committed.

The principal remaining reviewer risk is data consistency. Polygon consolidated VWAP aggregates are used through December 2024, while Alpaca/IEX bars are used afterward. Because the feeds do not overlap and the switch is confounded with time, the paper cannot establish whether later changes reflect the market, the feed, or both.

The current disclosure is technically adequate. The strongest empirical improvement would still be to reconstruct the full held-out period from one consistent feed and rerun the OoS-dependent results. If that is infeasible, retain the limitation exactly as written.

## 5. Narrative flow and presentation

### Strengths

- The introduction clearly moves from the Rydén result to temporal and distributional failure channels, then identifies the actual contribution without claiming CHMM novelty.
- The abstract is less overloaded after removing one secondary panel statistic.
- Section 6.1 is now split between state selection and the spectral diagnostic, improving readability.
- The single reduced QuantGAN control is positioned accurately rather than presented as a broad deep-generator benchmark.
- Table 2 provides a clear configuration map before the conclusion.
- The conclusion now matches the evidence on state selection and refitting.
- The final bibliography page is balanced, readable, and visually finished.

### Minor optional polish

- The first sentence of Section 3 contains a long parenthetical explaining `r_f = 0`. Two shorter sentences would read more cleanly: define the growth rate first, then state that the zero risk-free assumption makes it annualised log growth rather than measured excess return.
- The abstract is still dense, but the density is defensible under the eight-page constraint.
- Two small overfull horizontal boxes remain (`4.37 pt` and `2.17 pt`), neither visibly clipped.

No clipping, overlap, broken glyph, unreadable table text, or unbalanced column was observed on any page.

## 6. ICAIF '26 fit and domain

### Fit: very strong

The official [ICAIF '26 call for papers](https://icaif2026.org/call-for-papers.html) explicitly lists:

- generative AI, simulation, and synthetic data generation;
- AI-driven risk management;
- robustness and uncertainty quantification;
- validation and calibration of financial models;
- risk modeling and risk management;
- forecasting of financial scenarios; and
- financial time-series analysis and factor models.

The paper combines interpretable synthetic-return generation, financial-model validation, and conditional risk forecasting, so it directly fits both the methodology and application sides of the conference.

### Recommended submission domain

**Primary methodology:** **Generative AI, simulation, and synthetic data generation**

**Secondary methodologies:**

1. Validation and calibration of financial models
2. AI-driven risk management
3. Robustness and uncertainty quantification

**Application areas:**

1. Risk modeling and risk management
2. Financial time-series analysis and factor models
3. Forecasting of financial scenarios

The CFP publishes topic areas rather than guaranteeing an identical CMT track taxonomy. Select the closest equivalents available in CMT.

### Positioning risk

Topical fit is stronger than algorithmic novelty because CHMM itself is established. The submission should continue to foreground:

1. the finite-mode spectral diagnostic and SPY-versus-panel finding;
2. the controlled heavy-tailed emission comparison under a common harness; and
3. the filter-conditional VaR head with walk-forward failure analysis.

## 7. Formal submission compliance

The official CFP lists an **August 2, 2026, Anywhere-on-Earth deadline** and requires a self-contained, anonymous ACM `sigconf` paper of no more than eight total pages, including references, with no supplementary appendix.

Fresh build and inspection results:

- PDF length: **8 / 8 pages**
- ACM `sigconf,anonymous`: **pass**
- source, PDF, and metadata anonymization: **pass**
- citations: **30 used, 30 defined, 0 unused, 0 undefined**
- visible clipping or overlap: **none**
- figures and tables: **legible**
- bibliography balance: **pass**
- balance warnings: **none in the final log**
- overfull boxes: **2**, maximum `4.37 pt`, with no visible clipping
- automated repository checks: **all passed**

The conference is scheduled for November 14–17, 2026, in Milan and requires in-person presentation of accepted papers.

## Priority checklist

### Required before submission

1. Relabel Figure 1's x-axis from “Excess Growth Rate” to “Annualised Log Growth Rate” or “Growth Rate.”
2. Regenerate/copy the figure, rebuild the paper, rerun `make check`, and visually inspect all eight pages.

### Strongly recommended if feasible

3. Rebuild the held-out period from one consistent market-data feed; otherwise preserve the current limitation.

### Optional polish

4. Split the first sentence of Section 3 for readability.
5. Remove the two small overfull boxes if this does not disturb pagination.

## Bottom line

The paper has crossed from “close” to **submission-ready subject to one figure-label correction**. Its technical story, reported results, narrative qualification, configuration mapping, and conference positioning are now coherent. After regenerating Figure 1 with the corrected axis label and verifying the final PDF, I would consider the manuscript ready for ICAIF '26 submission, with the mixed-feed held-out period retained as its principal disclosed empirical limitation.
