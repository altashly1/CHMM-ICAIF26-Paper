# ICAIF '26 Paper Readiness Review — Second Full Audit

**Paper:** *Heavy-Tail Hidden Markov Generators for Daily Equity Returns: Stylized Facts and Filter-Conditional Value-at-Risk*

**Review date:** July 15, 2026

**Scope:** Technical accuracy, narrative flow, correctness, conference fit, source-artifact consistency, and rendered-PDF quality.

**Compared against:**

- `/Users/abdulrahmanalswaidan/Desktop/Project-Repos/Thesis/CHMM-Paper-Repository`;
- `/Users/abdulrahmanalswaidan/Desktop/Project-Repos/Thesis/CHMM-Model-Repository`;
- the official ICAIF '26 call: <https://icaif2026.org/call-for-papers.html>.

## Executive verdict

The manuscript is a **very strong topical fit for ICAIF '26**, and most issues from the first review have been corrected. It is nevertheless **not ready to submit unchanged**. This audit found a new central inconsistency in the cross-ticker spectral evidence: the manuscript says the panel supports one-mode/non-binding behavior at the median, but the stored artifact's own criterion is not met, and the cross-ticker script computes a different modal-share quantity from the one defined in the paper.

This is a targeted rather than foundational problem. The SPY spectral results remain internally supported. The panel diagnostic should be corrected and rerun, after which the abstract, introduction, results, and Table 3 must be aligned with the revised result.

Additional corrections are needed for an unsupported shared-`nu` CRPS statement, an internally inconsistent Hill paragraph, an undefined ACF “tolerance,” and the rendered placement of Table 3 inside the reference list.

| Dimension | Assessment |
|---|---:|
| Conference fit | 9/10 |
| Technical accuracy | 7/10 |
| Narrative and coherence | 7.5/10 |
| Reproducibility/correctness | 7/10 |
| Current submission readiness | 6.5/10 |

## Conference fit and domain

ICAIF '26 explicitly solicits:

- **Generative AI, simulation, and synthetic data generation**;
- **AI-driven risk management**;
- **validation and calibration of financial models**;
- **robustness and uncertainty quantification**;
- **risk modeling and risk management**;
- **forecasting of financial scenarios**;
- **financial time-series analysis and factor models**.

The best primary CMT methodology is:

> **Generative AI, simulation, and synthetic data generation**

Best secondary methodology:

> **Validation and calibration of financial models**

Best application area:

> **Risk modeling and risk management**

Secondary applications are **financial time-series analysis** and **forecasting of financial scenarios**.

The technical domain is:

> **Probabilistic machine learning for finance: latent-variable, regime-switching, and synthetic financial time-series modeling.**

Do not submit it primarily under asset pricing, trading, NLP, or deep learning. The present CCS terms—latent-variable models, economics, and time-series analysis—are appropriate.

The venue risk is novelty, not scope. The paper should continue to position itself as an empirical/model-validation contribution: the CHMM and spectral identity are established; the contribution is the two-channel diagnosis, controlled emission-family comparison, small inspectable generator, filter-conditional risk head, and validation/failure analysis.

## What the revision fixed successfully

The current version materially improves on the earlier draft:

- The abstract now distinguishes the Gaussian, shared-`nu`, and penalized per-state Student-t configurations.
- Filter-conditional VaR is correctly defined as the quantile of the one-step-ahead predictive mixture.
- The ACF identity is correctly restricted to positive lags.
- The parameter range is corrected to 12–17, with the 12- and 15-parameter headline variants identified.
- The shared-`nu` objective and hybrid generalized block-update caveat are disclosed.
- The HSMM duration update is correctly labeled moment-updated rather than maximum-likelihood.
- The cross-ticker panel identifies the penalized model and reports its poor kurtosis behavior.
- The CRPS wording was softened from statistical equivalence to numerical similarity.
- The Hill discussion now disclaims asymptotic/far-tail inference.
- The conclusion distinguishes state selection by BIC/CV from spectral diagnosis.
- ACM reference format and figure alternative text were restored.
- `make check` passes with no unused or undefined citations and a clean anonymization scan.

The main SPY, model-comparison, state-selection, walk-forward, refit, and VaR numbers checked against the stored artifacts.

## Critical technical findings

### 1. The cross-ticker spectral conclusion does not satisfy its own criterion

The abstract says that the 30-ticker diagnostic supports the SPY reading at the cross-ticker median. The introduction and results similarly state that the rank bound is non-binding at the panel median.

The stored artifact `results/diagnostics/spectral_rank_cross_ticker.txt` reports:

- median dominant-mode share: `0.756`;
- median number of modes needed for 95%: `6`;
- minimum dominant share: `0.326`;
- maximum modes needed for 95%: `11`.

The same artifact states its decision rule:

> If median dominant share is at least 0.90, the rank-non-binding claim is supported across the panel.

The observed median `0.756` fails that criterion. It therefore does **not** support a panel-wide one-mode conclusion under the predeclared rule.

A defensible interpretation is:

> SPY is unusually close to one-mode. Across the panel, effective rank remains below the 17-mode algebraic maximum at `K = 18`, but the typical ticker requires about six modes to reach 95% of absolute lag-1 contribution.

That is still an interesting result, but it is different from “the panel supports the SPY reading.”

Required edits after rerun:

- narrow the abstract's panel sentence;
- revise Introduction paragraph 3;
- revise Results 6.1;
- report median `n95 = 6` in Table 3, not only the dominant share;
- avoid inferring that marginal flexibility dominates additional ACF modes across tickers unless a state-count/ACF comparison is actually run on the panel.

### 2. The cross-ticker code and manuscript use different modal-share definitions

The manuscript defines the lag-1 share from complex modal magnitudes:

`|a_k lambda_k| / sum_j |a_j lambda_j|`.

The SPY script implements this with `abs(r.w_k * r.lambda)`. The cross-ticker script instead computes:

`abs(real(r.w_k * r.lambda))`.

These differ for complex eigenvalues. The fitted `K = 18` chains do contain complex-conjugate modes, as indicated by repeated eigenvalue magnitudes in the SPY artifact. The mismatch already produces two values for the same SPY control:

- `0.936` under the main SPY modulus definition;
- `0.943` in the cross-ticker artifact.

Consequently, the panel median `0.756` is not computed under the definition printed in Section 4 and Table 3.

**Required action:** Change the cross-ticker implementation to the manuscript's declared definition, or redefine the paper consistently. Preferably group complex-conjugate pairs into real damped-oscillatory modes and state that convention explicitly. Rerun the 30-ticker diagnostic and regenerate every affected number.

### 3. The shared-`nu` CRPS claim is not present in the stored artifact

Results 6.2 says the four displayed CHMM variants have numerically similar OoS CRPS values. The quoted range comes from the older `K = 3` headline artifact containing the penalized per-state Student-t row. The new shared-`nu` runner and stored CSV report KS, kurtosis, and ACF metrics, but not CRPS.

The full Table-2 artifact includes shared-`nu` Wasserstein/Hellinger results, not CRPS. Thus the sentence currently treats the new shared-`nu` row as if its CRPS had been computed when the checked artifacts do not show that result.

**Required action:** Compute CRPS for the saved shared-`nu` simulations using the same scoring implementation and seed policy, or rewrite the statement to cover only configurations with stored CRPS values. Do not use the penalized Student-t CRPS as the shared-`nu` value.

### 4. The ACF “tolerance” is undefined

Results 6.2 and the conclusion say the CHMM matches the slow ACF “within our lag-252 MAE tolerance,” but no tolerance or acceptance threshold is defined in Experimental Setup.

This matters because the paper's central historical claim turns on whether the ACF is adequately reproduced. Table 1 shows:

- CHMM-N: `0.0462`;
- GARCH-t: `0.0316`;
- MS-GARCH: `0.0284`;
- i.i.d. bootstrap: `0.0628`.

The CHMM improves on the i.i.d. floor but is not the closest model in the panel. A post hoc “tolerance” cannot carry the claim unless it is specified and motivated.

Use one of these alternatives:

1. define a pre-specified or scientifically motivated tolerance;
2. state the relative result directly: “CHMM-N reduces ACF-MAE from 0.0628 for the i.i.d. bootstrap to 0.0462”;
3. say “captures substantial slow-decay persistence” instead of “matches.”

The relative statement is the safest.

### 5. The Hill paragraph mixes headline and sensitivity rows

Results 6.3 says every emission family produces an in-band Hill estimate and that simulated excess kurtosis spans `3.83` to `18.87` “across the same rows.” That is internally inconsistent:

- the four displayed headline rows span `3.83` to `5.45` IS kurtosis;
- `18.87` belongs to the penalized per-state Student-t sensitivity configuration, not the shared-`nu` headline row.

The paragraph also concludes that the regime mixture “rather than the emission family carries the heavy tail.” The evidence more directly shows that the top-5% Hill diagnostic is not discriminative among these configurations at this sample size.

Recommended wording:

> The four headline families yield similar threshold-local Hill estimates despite different kurtosis values (`3.83–5.45`); the penalized sensitivity row reaches `18.87`. At this threshold and sample size, the Hill statistic does not discriminate reliably among emission families.

### 6. Quarterly refitting improves KS, not every generator axis

The abstract says the penalized Student-t panel variant “improves materially under quarterly refitting.” The displayed evidence establishes an improvement in median marginal KS and failure count. It does not show corresponding refit changes in kurtosis or ACF-MAE.

Use:

> quarterly refitting raises median OoS KS from 69.1% to 84.7%

rather than an unqualified model-wide improvement.

### 7. Data reproducibility needs a clearer statement

The paper identifies “commercial daily-price vendors” but not the vendor, retrieval rules, VWAP definition, corporate-action source, or duplicate/missing-session handling. It also uses split-adjusted but not dividend-adjusted SPY prices; ex-dividend price changes can mechanically affect return tails and regime assignment.

This is disclosed, so it is not hidden, but it weakens the claim that released runners regenerate every table. At minimum:

- name the vendor and field definition;
- state timezone/session and missing-value rules;
- explain why price returns rather than total returns are appropriate;
- if licensing allows, release the derived return series or immutable data hashes.

## Narrative and presentation

### Narrative strengths

The central story is now coherent:

1. split the low-state HMM limitation into temporal and marginal channels;
2. diagnose the SPY temporal channel spectrally;
3. compare emission families at a fixed state count;
4. disclose cross-window and cross-ticker failure modes;
5. evaluate the Gaussian member's filter-conditional VaR head.

The configuration map is conceptually valuable, and the paper is commendably candid about configuration switching, the approximate HSMM update, KS calibration, 1% VaR power, stress-fold failures, and lack of privacy guarantees.

The abstract is about 243 words—reasonable for a conference paper, though still syntactically dense. The second sentence and configuration-list sentence would benefit from splitting.

### Table 3 interrupts the bibliography

The rendered PDF places Table 3 at the top of page 8 after references 1–24 have begun on page 7; references 25–30 then continue below the table. This visually inserts a results table into the middle of the bibliography and makes the evidence appear after the conclusion.

This is a submission-quality problem even though nothing overlaps or clips.

Move the `table*` earlier in the source or force it to the top of page 7 before the conclusion/references. A compact one-column configuration table or a reduced conclusion may give LaTeX enough room. Re-render all pages after changing float placement.

### Placeholder DOI

The ACM reference block visibly prints `10.1145/nnnnnnn.nnnnnnn`. Do not submit a fake DOI unless ICAIF explicitly directs authors to retain the template placeholder. Keep the reference block but suppress/empty the DOI field, or follow a chair-provided submission template.

### Figure alternative text

The new `Description` says the absolute-return ACF remains above the 99% band for well over 100 lags. The plotted curve crosses and revisits the band; it is not continuously above it for that duration. Use “shows positive persistence across many lags” or describe the crossings more literally.

## Mechanical audit

Fresh build results:

- exactly 8 pages, including references;
- latest local `acmart`, `sigconf`, and `anonymous` options;
- no undefined citations or references;
- no unused bibliography entries;
- anonymization scan clean;
- three small overfull boxes, maximum `4.37 pt`;
- no clipping, overlap, missing glyphs, or unreadable plots;
- Figure 1 and Tables 1–2 are legible at page scale.

The official ICAIF '26 limit is eight pages total, in anonymous ACM `sigconf`, with no supplement. The manuscript currently satisfies those mechanical requirements, but the float placement and placeholder DOI should still be corrected.

## Prioritized revision sequence

### Submission blockers

1. Correct the cross-ticker spectral implementation and rerun the panel diagnostic.
2. Rewrite the panel spectral conclusion using the corrected dominant share and `n95` distribution.
3. Compute shared-`nu` CRPS or remove the four-variant CRPS statement.
4. Replace/define the ACF “tolerance.”
5. Fix the Hill-row inconsistency.
6. Move Table 3 ahead of the conclusion/references.
7. Remove the visible placeholder DOI.

### High-value polish

8. Qualify quarterly-refit improvement as an improvement in KS.
9. Improve data-source reproducibility and justify non-dividend-adjusted returns.
10. Shorten the densest abstract/introduction sentences.
11. Correct the Figure 1 alternative text.
12. Rebuild, run `make check`, and inspect all eight pages.

## Bottom line

**Keep ICAIF '26 as the target.** The paper belongs there and has a credible application-oriented contribution. The current SPY evidence, configuration disclosures, and VaR definition are substantially improved. The main remaining risk is the panel spectral generalization: under the stored criterion it is not supported, and under the manuscript's stated definition it has not yet been computed consistently.

After that rerun and the targeted textual/layout fixes above, the paper should be in credible submission condition.
