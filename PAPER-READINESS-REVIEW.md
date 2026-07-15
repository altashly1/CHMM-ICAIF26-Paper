# Paper Readiness Review — Sixth Full Audit

**Paper:** *Heavy-Tail Hidden Markov Generators for Daily Equity Returns: Stylized Facts and Filter-Conditional Value-at-Risk*

**Target:** 7th ACM International Conference on AI in Finance (ICAIF '26)

**Audit date:** July 15, 2026

**Manuscript commit reviewed:** `6471487` — `Address third audit: correct data provenance, boundary disclosure, claim narrowing`

**Model/artifact commit reviewed:** `95ca39b` — `Retire circular vendor-stitch check; add OoS feed-boundary diagnostic`

## Executive verdict

The paper is **close to submission-ready, but I would not submit this exact version unchanged**. Its central mathematics, reported numerical results, model descriptions, and configuration mapping are internally supported. It is also a **very strong topical fit for ICAIF '26**. The primary conference domain is **Methodologies → Generative AI, simulation, and synthetic data generation**, with strong secondary placement under model validation/calibration and AI-driven risk management.

The sixth regression audit reconfirmed the prior issues and found one additional claim-level contradiction in the QuantGAN interpretation. Five corrections should be made before submission:

1. the feed-boundary KS non-rejection is interpreted too affirmatively;
2. the conclusion incorrectly says rolling-origin validation selected `K = 3`;
3. the introduction's broad refit recommendation is inconsistent with the qualified evidence; and
4. the results say QuantGAN fails all three stylized facts even though its raw-return ACF result is close to the i.i.d. baseline; and
5. the last bibliography page is visibly unbalanced.

These are narrow fixes. The main reviewer-facing empirical risk remains the non-overlapping Polygon-to-Alpaca/IEX feed switch inside the held-out period.

### Readiness scores

| Dimension | Score | Assessment |
|---|---:|---|
| Technical accuracy | **8.5/10** | Core mathematics is sound; three result interpretations overstate what the evidence selects, rules out, or fails. |
| Empirical correctness | **8.3/10** | Reported values trace to stored artifacts; the mixed-feed OoS confound is disclosed but unresolved. |
| Narrative flow | **8.6/10** | The contribution sequence is coherent; one stale recommendation and a dense results paragraph reduce clarity. |
| ICAIF topical fit | **9.5/10** | Directly matches synthetic financial data, validation/calibration, risk, and financial time series. |
| Submission readiness | **8.3/10** | All automated checks pass; apply the five required corrections below before submission. |

## 1. Required technical corrections

### 1.1 Qualify the feed-boundary diagnostic

`sections/05-setup.tex:10` currently says the diagnostic “finds no significant distributional break” and that the close-price column “gives the same picture.” This is too strong.

The artifact reports:

| Price field | Segment | Standard deviation | Excess kurtosis |
|---|---|---:|---:|
| VWAP | Polygon 2024 | 1.640 | 2.31 |
| VWAP | Alpaca/IEX 2025–2026 | 2.215 | 5.24 |
| Close | Polygon 2024 | 2.004 | 1.81 |
| Close | Alpaca/IEX 2025–2026 | 2.913 | 19.77 |

The unadjusted two-sample KS results are `D = 0.0988`, `p = 0.1291` for VWAP and `D = 0.0650`, `p = 0.5924` for close. These are non-rejections, not evidence that there was no distributional break. In addition:

- calendar time and data vendor are perfectly confounded;
- the ordinary two-sample KS calibration assumes independent observations, while the manuscript itself documents dependence in return magnitudes; and
- the segment volatility and kurtosis estimates differ materially, especially for close returns.

Recommended replacement:

> The feeds do not overlap, so the switch remains an unresolved OoS confound. Descriptively, an unadjusted pre/post KS does not reject equality for VWAP returns (`D = 0.099`, `p = 0.13`) or close returns (`D = 0.065`, `p = 0.59`), but the test is time-confounded and not dependence-calibrated, and the segments differ in volatility and kurtosis.

The segmented VaR counts (`17/250` versus `19/323` at 5%) are valid descriptive checks, but they do not establish feed equivalence.

### 1.2 Correct the state-selection claim

`sections/07-conclusion.tex:5` says:

> BIC/CAIC and rolling-origin validation select the state count.

That conflicts with Section 6.1 and Table 2. The `K = 3` and `K = 6` ordering reverses across the two reported validation panels:

- four-fold log-likelihood per observation: `K = 3` is `-1.793`; `K = 6` is `-1.800`;
- six-fold log-likelihood per observation: `K = 3` is `-1.767`; `K = 6` is `-1.740`.

BIC/CAIC select `K = 3`. Rolling-origin validation cannot distinguish `K = 3` from `K = 6`, although it disfavors `K = 18`.

Recommended replacement:

> BIC/CAIC select `K = 3`; rolling-origin validation cannot distinguish `K = 3` from `K = 6` but disfavors `K = 18`, so `K = 3` is retained as the parsimonious choice.

### 1.3 Align the refit recommendation with the results

`sections/01-introduction.tex:5` ends with:

> we recommend periodic refit within that scope.

This is broader than the abstract and conclusion. Quarterly refitting improves the non-stress cross-ticker panel but does not repair the COVID or 2022 rate-hike folds. Replace the sentence with the same qualified conclusion used elsewhere: periodic refitting helps under ordinary drift, but no tested cadence repaired abrupt stress-regime introductions.

### 1.4 Correct the QuantGAN “all three” claim

`sections/06-results.tex:9` says the reduced QuantGAN control “fails all three stylized facts.” Table 1 does not support that statement:

- the `0.0%` KS pass rate and excess kurtosis of `0.56` show failure on the heavy-tailed marginal;
- the absolute-return ACF-MAE of `0.0617` is essentially at the i.i.d. floor of `0.0628`, showing failure to reproduce volatility clustering; but
- the raw-return ACF-MAE is `0.0264`, close to the i.i.d. baseline's `0.0235` and the CHMM values of `0.0235–0.0240`, which is consistent with negligible linear autocorrelation rather than failure of that diagnostic.

Recommended replacement:

> The reduced QuantGAN negative control fails the heavy-tailed-marginal and volatility-clustering diagnostics at this sample size (`0.0%` KS, excess kurtosis `0.56`, and absolute-return ACF-MAE at the i.i.d. floor), while its raw-return ACF remains close to the negligible-autocorrelation baseline.

This correction is especially important because the paper elsewhere correctly defines the three stylized facts separately.

## 2. Technical accuracy assessment

### Correct and internally supported

- The paper presents the CHMM as an established model class rather than a new one.
- The absolute-growth-rate ACF identity is stated with stationarity, irreducibility/aperiodicity, finite-moment, and diagonalizability conditions.
- The algebraic `K - 1` modal bound is distinguished from the fitted number of effective eigen-contributions.
- The spectral implementation uses `|a_k lambda_k|`; the stored 30-ticker diagnostic supports a median leading-mode share of `0.726`, minimum `0.287`, and median `n95 = 7`.
- The manuscript correctly narrows the near-one-mode interpretation to SPY rather than claiming it panel-wide.
- The dedicated artifact supports the shared-`nu` CHMM-t CRPS value of `1.0406`.
- Student-t and GED fitting are described as hybrid/generalized block procedures without an unjustified monotonicity guarantee.
- The HSMM duration update is accurately labelled moment-updated rather than maximum-likelihood.
- VaR is the quantile of the one-step-ahead filtered mixture, not state-specific VaR or expected shortfall.
- VaR non-rejections are interpreted as compatibility, with low-power and multiplicity caveats.
- Table 2 maps the headline results to their actual configurations and avoids implying one universal CHMM setting.
- The implemented parameter conventions behind the 12-versus-15 comparison are disclosed.
- The data-provenance account now correctly states that the Polygon and Alpaca/IEX files do not overlap and that the analysis uses the vendors' stored VWAP field.

### Remaining methodological limitations

- The primary KS pass rate is descriptive rather than dependence-calibrated.
- Different CHMM configurations support different parts of the empirical story.
- Shared-`nu` selection is validated directly on SPY; the cross-ticker spectral panel uses the penalized per-state model.
- The in-house QuantGAN is a reduced negative control, not a faithful reproduction of the published system.
- The analysis sets the risk-free rate to zero, so the measured series is the annualized log price growth rate rather than an empirically risk-free-adjusted excess return. The equation discloses this, but consistently calling it “excess growth” is potentially misleading; rename it to “annualized log growth rate” or use an actual risk-free series. This terminology change would not alter the kurtosis or ACF results because they are invariant to a constant shift.
- The paper does not model leverage dynamics, far-tail asymptotics, multivariate dependence, or an HSMM risk head.
- The `K = 18` modal decomposition relies on eigenvectors. Reporting the eigenvector-matrix condition number would strengthen the numerical-stability case, although no obvious instability appears in the stored results.

## 3. Empirical credibility and reproducibility

The revised provenance disclosure is accurate, and the replacement feed-boundary runner and artifact are committed in the clean model repository. This retires the former circular vendor-stitch check.

The disclosure does not eliminate the confound: the pre-2025 held-out observations use Polygon consolidated aggregates, whereas the later observations use Alpaca's single-exchange IEX feed. The static-panel failures, quarterly-refit gains, held-out tail estimates, and main-window VaR all touch the mixed-feed period. A reviewer can reasonably ask whether those findings reflect market change, feed change, or both.

The strongest empirical revision would rebuild the entire period from one consistent feed and rerun all held-out analyses. If that is infeasible before submission, keep the limitation prominent and avoid presenting the boundary KS as validation of comparability.

## 4. Narrative flow and correctness

### What works

- The introduction moves logically from the Rydén low-state Gaussian failure to temporal and distributional channels, then states the actual contribution without claiming CHMM novelty.
- The methodology, evaluation harness, main results, validation limits, and risk application form a coherent sequence.
- Figure 1 now appears immediately before the results discussion it supports.
- Table 2 provides an important configuration map before the conclusion.
- The abstract and conclusion clearly distinguish SPY-specific findings from panel-wide evidence.

### What still needs attention

- Section 6.1 combines state selection, the SPY spectral result, panel generalization, and interpretation in one long paragraph. Splitting it after state selection would improve readability.
- The abstract is defensible but dense with numbers and qualifications. Removing one secondary statistic would sharpen the contribution.
- The broad refit recommendation in the introduction breaks narrative consistency with the more careful abstract and conclusion.
- The introduction says “deep generative baselines” in the plural, but the evaluation contains one reduced QuantGAN negative control. Use singular wording and avoid implying a broad deep-generator comparison.
- Page 8 looks unfinished: references 1–28 fill the left column, while only references 29–30 appear at the top of the right column and most of that column is blank. The LaTeX log also warns that `\balance` was called in the second column. Rebalance the bibliography or start it cleanly.

No clipping, overlap, unreadable table text, or broken figure was observed on pages 1–7.

## 5. ICAIF '26 fit and domain

### Fit: very strong

The official [ICAIF '26 call for papers](https://icaif2026.org/call-for-papers.html) explicitly includes:

- generative AI, simulation, and synthetic data generation;
- AI-driven risk management;
- robustness and uncertainty quantification;
- validation and calibration of financial models;
- risk modeling and risk management;
- forecasting of financial scenarios; and
- financial time-series analysis and factor models.

This paper connects interpretable synthetic equity-return generation with model validation and filter-conditional risk forecasting. It therefore fits both the methodological and application sides of the conference.

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

The CFP publishes topic areas rather than a guaranteed CMT track taxonomy. Use the closest equivalent subject areas or keywords in CMT.

### Positioning risk

Topical fit is stronger than novelty positioning. Because the CHMM is established, the paper should foreground these three contributions:

1. the finite-mode spectral diagnostic and the contrast between SPY and the 30-ticker panel;
2. the controlled heavy-tailed emission comparison under one evaluation harness; and
3. the filter-conditional VaR head with walk-forward failure analysis.

## 6. Formal submission compliance

The official CFP lists an **August 2, 2026, Anywhere-on-Earth deadline**. It requires an anonymous ACM `sigconf` PDF of no more than eight total pages, including references, with no supplementary material or appendix.

Fresh build and check results:

- PDF length: **8 / 8 pages**
- ACM `sigconf,anonymous`: **pass**
- source, PDF, and metadata anonymization: **pass**
- citations: **30 used, 30 defined, 0 unused, 0 undefined**
- visible clipping or overlap: **none observed**
- figures and tables: **legible**
- overfull boxes: **three small horizontal boxes**, maximum `4.37 pt`, with no visible clipping
- automated repository checks: **all passed**
- bibliography balance: **fails visual polish**, despite passing automated checks

The conference is scheduled for November 14–17, 2026, in Milan and requires in-person presentation of accepted papers.

## Priority checklist

### Must fix before submission

1. Rephrase the feed-boundary result as an unadjusted, time-confounded, non-dependence-calibrated KS non-rejection.
2. Correct the claim that rolling-origin validation selected `K = 3`.
3. Qualify the introduction's periodic-refit recommendation.
4. Replace the claim that QuantGAN fails all three stylized facts with the two failures actually supported by Table 1.
5. Repair the final bibliography-column balance and rebuild.

### Strongly recommended

6. Rebuild the held-out period from one consistent market-data feed if feasible.
7. Rename the zero-risk-free-rate series from “excess growth” to “annualized log growth,” or use an actual risk-free series.
8. Change “deep generative baselines” to the singular reduced QuantGAN control.
9. Split the long Section 6.1 paragraph.
10. Report eigenvector-conditioning diagnostics for the `K = 18` decomposition.

## Bottom line

The paper's central technical story is coherent and well matched to ICAIF '26, but this exact version should not be submitted unchanged. Correct the four claim-level statements, repair the final-page layout, and then rebuild and inspect the PDF. The mixed-feed held-out series should remain an explicit limitation unless it is rebuilt from one consistent source. The zero-risk-free-rate terminology and singular QuantGAN positioning are smaller but worthwhile accuracy improvements.
