# Paper Readiness Review — Fourth Full Audit

**Paper:** *Heavy-Tail Hidden Markov Generators for Daily Equity Returns: Stylized Facts and Filter-Conditional Value-at-Risk*

**Target:** 7th ACM International Conference on AI in Finance (ICAIF '26)

**Audit date:** July 15, 2026

**Paper state:** base commit `c388ef0` plus uncommitted manuscript revisions

**Model/artifact state:** base commit `ad8e24c` plus uncommitted feed-boundary runner and artifact

## Executive verdict

The manuscript is now **close to submission-ready** and remains a **very strong topical fit for ICAIF '26**. The prior central errors are corrected: the paper no longer claims a false Polygon/Alpaca overlap, identifies the stored vendor VWAP field correctly, discloses the exact feed boundary and unresolved confound, narrows the refit claim, qualifies parameter counting, and describes the spectral panel in terms of eigen-contributions.

No remaining issue overturns the central SPY spectral, generator-comparison, or filter-conditional VaR results. I would nevertheless make one final correction pass before submission. Two statements are technically too strong, the introduction retains one stale refit recommendation, and the final bibliography page is visibly unbalanced.

### Readiness scores

| Dimension | Score | Assessment |
|---|---:|---|
| Technical accuracy | **8.7/10** | Core mathematics and model claims are sound; state-selection and boundary-test wording need correction. |
| Empirical correctness | **8.3/10** | Values trace to artifacts; the mixed-feed OoS confound is now disclosed but remains unresolved. |
| Narrative flow | **8.6/10** | Figure and tables now appear in a coherent sequence; abstract remains dense and one stale recommendation remains. |
| ICAIF topical fit | **9.5/10** | Direct match to synthetic financial data, model validation, financial risk, and time-series analysis. |
| Submission readiness | **8.5/10** | Formal checks pass; make the short corrections below and commit all supporting artifacts. |

## 1. What the latest revision successfully fixes

The manuscript now correctly states that:

- the raw Polygon and Alpaca files are date-disjoint;
- Polygon supplies observations through December 31, 2024;
- Alpaca/IEX supplies observations from January 3, 2025;
- the feed switch falls inside the held-out window;
- no genuine cross-vendor equality test is possible from the repository data;
- the switch is an unresolved OoS confound;
- the analyses consume the vendors' stored daily VWAP field rather than a locally constructed typical-price proxy;
- quarterly refitting improves the non-stress cross-ticker panel but does not repair the stress folds;
- `n95` counts non-unit eigen-contributions, with conjugate-pair members counted separately;
- the 12-versus-15 parameter comparison uses the models' implemented initial-state conventions; and
- shared-`nu` selection reflects a joint KS–kurtosis–regularization trade-off, not kurtosis alone.

The replacement feed-boundary runner also explicitly retires the circular vendor-stitch diagnostic and reproduces the values now cited in the setup section.

## 2. Must correct: the feed-boundary KS interpretation is too strong

Section 5 currently says that the boundary diagnostic “finds no significant distributional break” and that the close-price column “gives the same picture.” This is too affirmative for the evidence.

### Why

The stored artifact reports:

| Price field | Segment | Standard deviation | Excess kurtosis |
|---|---|---:|---:|
| VWAP | Polygon 2024 | 1.640 | 2.31 |
| VWAP | Alpaca/IEX 2025–2026 | 2.215 | 5.24 |
| Close | Polygon 2024 | 2.004 | 1.81 |
| Close | Alpaca/IEX 2025–2026 | 2.913 | 19.77 |

The unadjusted two-sample KS gives `D = 0.0988`, `p = 0.1291` for VWAP and `D = 0.0650`, `p = 0.5924` for close. Those non-rejections do not establish absence of a break. The same paper correctly explains that ordinary KS calibration assumes i.i.d. observations, while the return series exhibit dependence in absolute magnitude. Calendar time and vendor feed are also perfectly confounded, and the scale and kurtosis changes are material—especially the close-return kurtosis.

### Required wording

Replace the current clause with something like:

> The feeds do not overlap, so the switch remains an unresolved OoS confound. Descriptively, an unadjusted pre/post KS does not reject equality for VWAP returns (`D = 0.099`, `p = 0.13`) or close returns (`D = 0.065`, `p = 0.59`), but the test is time-confounded and not dependence-calibrated, and the segments differ in volatility and kurtosis.

The segmented VaR counts (`17/250` versus `19/323` at 5%) are accurately reported, but should remain a descriptive check rather than evidence of feed equivalence.

## 3. Must correct: rolling-origin validation did not select `K = 3`

The conclusion says:

> BIC/CAIC and rolling-origin validation select the state count.

That conflicts with Section 6.1 and Table 2. The four-fold and six-fold held-out log-likelihood comparisons between `K = 3` and `K = 6` are nearly tied and reverse ordering:

- four-fold: `K = 3` is `-1.793`, `K = 6` is `-1.800`;
- six-fold: `K = 3` is `-1.767`, `K = 6` is `-1.740`.

The paper itself correctly treats those comparisons as descriptive and says they cannot separate `K = 3` from `K = 6`. BIC and CAIC select `K = 3`; rolling-origin validation mainly rules against `K = 18` and does not contradict the parsimony choice.

Suggested correction:

> BIC/CAIC select `K = 3`; rolling-origin validation cannot distinguish `K = 3` from `K = 6` but disfavors `K = 18`, so `K = 3` is retained as the parsimonious choice.

## 4. Must align: the introduction retains the old refit recommendation

The abstract and conclusion now accurately say that quarterly refit improves the non-stress panel without repairing abrupt stress shifts. The last sentence of the introduction still says broadly:

> we recommend periodic refit within that scope.

Use the same qualified statement as the abstract and conclusion. Otherwise the paper simultaneously says refit is recommended for drift and that no tested cadence repaired its principal drift/stress failures.

## 5. Strongly recommended empirical improvement: use one market-data feed

The transparent disclosure is now adequate for readers to understand the limitation, and the false validation claim is gone. It does not, however, remove the empirical confound. All 2025–2026 observations come from Alpaca's IEX feed, which represents only a small fraction of consolidated U.S. volume, while the earlier observations are consolidated Polygon aggregates.

The strongest submission would rebuild the full period from one consistent feed and rerun all OoS-dependent results. At minimum, preserve the explicit limitation and avoid interpreting the boundary diagnostic as validation of feed comparability. The official [Alpaca historical-data documentation](https://docs.alpaca.markets/us/v1.1/docs/historical-stock-data-1) distinguishes single-exchange IEX data from consolidated SIP coverage.

This is now an **empirical credibility risk rather than a hidden correctness error**. It may attract reviewer criticism because the static panel failures, quarterly-refit gains, tail estimates, and main-window VaR all use the mixed-feed held-out period.

## 6. Technical accuracy assessment

### Strong and internally supported

- The paper clearly states that the CHMM is established and does not claim a new model class.
- The absolute-growth-rate ACF identity is stated with stationarity, irreducibility/aperiodicity, finite-moment, and diagonalizability conditions.
- The algebraic `K - 1` bound is distinguished from fitted effective contribution.
- The SPY `K = 2`, `K = 3`, and `K = 18` modal-share values trace to stored diagnostics.
- The cross-ticker script now uses the paper's declared `|a_k lambda_k|` definition.
- The panel conclusion is appropriately limited: near-one-mode behavior is SPY-specific.
- The shared-`nu` CRPS value `1.0406` is present in a dedicated stored artifact.
- Student-t and GED estimation are described as hybrid/generalized block procedures without an unjustified monotonicity guarantee.
- The HSMM row is accurately labeled moment-updated rather than maximum-likelihood.
- VaR is correctly defined as the quantile of the one-step-ahead filtered mixture, not state-specific VaR or expected shortfall.
- Non-rejection in VaR tests is interpreted as compatibility rather than proof, with low-power and multiplicity caveats.
- Configuration-specific claims are mapped clearly in Table 2.

### Remaining methodological risks, already mostly disclosed

- The primary KS pass rate is descriptive rather than calibrated under serial dependence.
- Different CHMM configurations support different headline tasks.
- The shared-`nu` default is directly validated on SPY, whereas the cross-ticker panel uses the penalized per-state model.
- The QuantGAN implementation is a reduced negative control rather than a faithful reproduction.
- The model does not cover leverage dynamics, far-tail asymptotics, multivariate dependence, or an HSMM risk head.
- Modal weights are computed through an eigendecomposition; reporting the eigenvector-matrix condition number would strengthen the `K = 18` numerical diagnostic, though the current results do not show an obvious instability.

## 7. Narrative flow and presentation

### Improved

- Figure 1 now appears at the top of page 5 immediately before the main result discussion, rather than two pages after its first citation.
- Table 1 has a shorter, more readable caption.
- Table 2 precedes the conclusion and visibly maps each result to its actual configuration.
- Table 3 follows the VaR discussion and no longer interrupts the references.
- The abstract now states the SPY-versus-panel distinction and refit limitation more efficiently.

### Still worth improving

- The abstract remains number- and qualification-heavy. It is defensible, but one fewer secondary result would sharpen the contribution.
- Section 6.1 remains a very long paragraph combining state selection, the SPY spectral result, the panel diagnostic, and interpretation. Splitting after the state-selection discussion would improve readability.
- The final bibliography page is visibly unbalanced: references 1–28 fill the left column while only references 29–30 appear at the top of the right column. The build emits `balance` warnings. Rebalance or start the bibliography cleanly so the final page does not look unfinished.

## 8. ICAIF '26 fit and domain

### Topical fit: very strong

The official [ICAIF '26 call for papers](https://icaif2026.org/call-for-papers.html) explicitly lists:

- generative AI, simulation, and synthetic data generation;
- AI-driven risk management;
- robustness and uncertainty quantification;
- validation and calibration of financial models;
- risk modeling and risk management;
- forecasting of financial scenarios; and
- financial time-series analysis and factor models.

The paper directly addresses synthetic equity-return generation, interpretable latent-state simulation, empirical model validation, and conditional risk forecasting.

### Recommended domain

**Primary methodology domain:** **Generative AI, simulation, and synthetic data generation**

**Secondary methodology domains:**

1. Validation and calibration of financial models
2. AI-driven risk management
3. Robustness and uncertainty quantification

**Application domains:**

1. Risk modeling and risk management
2. Financial time-series analysis and factor models
3. Forecasting of financial scenarios

The CFP describes topic areas rather than guaranteeing a formal track taxonomy. Use these as CMT subject areas or keywords if equivalent choices are available.

### Positioning risk

Conference fit is stronger than novelty positioning. Because the CHMM itself is established, reviewers must immediately see the paper's three actual contributions:

1. the finite-mode spectral diagnostic and its SPY-versus-panel result;
2. the controlled heavy-tailed emission comparison under one evaluation harness; and
3. the filter-conditional VaR head with walk-forward failure analysis.

## 9. Formal submission compliance

The official CFP currently gives an **August 2, 2026 Anywhere-on-Earth deadline** and requires a self-contained, anonymous ACM `sigconf` paper of no more than eight total pages, with no supplementary appendix.

Current build checks:

- PDF pages: **8 / 8**
- ACM `sigconf,anonymous`: **pass**
- Source/PDF/metadata anonymization: **pass**
- Citations: **30 used, 30 defined, 0 unused, 0 undefined**
- Visual clipping or overlap: **none observed**
- Figure and table legibility: **pass**
- Overfull boxes: three small horizontal boxes; maximum `4.37 pt`, with no visible clipping
- Bibliography balance: **needs visual correction**

## 10. Repository reproducibility status

The manuscript revisions are currently uncommitted. In the model repository, the old stitch runner/artifact are being retired, but the replacement `run_feed_boundary_check.jl` and `feed_boundary_check.txt` are still untracked. Before submission or archival release:

1. commit the manuscript corrections;
2. add and commit the replacement runner and artifact;
3. remove or clearly archive the stale `vendor_stitch_check.csv` as well as the retired text artifact;
4. rerun the boundary script from the committed state;
5. rebuild and visually inspect the final PDF; and
6. rerun `make check`.

## Priority checklist

### Must fix before submission

1. Replace “no significant distributional break” with the appropriately qualified boundary-diagnostic interpretation.
2. Correct the conclusion's claim that rolling-origin validation selected `K = 3`.
3. Align the introduction's refit recommendation with the abstract and conclusion.
4. Fix the final bibliography-column balance.
5. Commit all manuscript, runner, and artifact changes.

### Strongly recommended

6. Rebuild the OoS period from one consistent market-data feed if feasible.
7. Split the long Section 6.1 paragraph.
8. Report eigenvector-conditioning diagnostics for the `K = 18` modal decomposition.

## Bottom line

The paper's central technical story is now coherent and substantially more defensible than in the prior audits. The remaining required changes are narrow: correct two overstatements, align one stale sentence, repair the final-page balance, and commit the evidence. After that, the manuscript is credible for ICAIF submission. The mixed Polygon/IEX held-out series remains the main reviewer-facing empirical limitation, but it is now transparently disclosed rather than incorrectly validated.
