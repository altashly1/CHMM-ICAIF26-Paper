# Paper Readiness Review — Eighth Full Audit

**Paper:** *Heavy-Tail Hidden Markov Generators for Daily Equity Returns: Stylized Facts and Filter-Conditional Value-at-Risk*

**Target:** 7th ACM International Conference on AI in Finance (ICAIF '26)

**Audit date:** July 15, 2026

**Manuscript commit reviewed:** `39394c4` — `Address seventh audit: regenerate Figure 1 with corrected axis label`

**Model/artifact commit reviewed:** `e34fafa` — `Correct stylized-facts figure axis label to annualised log growth rate`

## Executive verdict

The manuscript is **submission-ready**. I found no remaining blocking technical, narrative, correctness, anonymization, or layout defect.

The final Figure 1 terminology issue is resolved: the rendered axis now reads “Annualised Log Growth Rate,” the model section clearly explains that `r_f = 0`, the figure-generation code uses the same terminology, and the paper's embedded figure is byte-for-byte identical to the committed model-repository artifact. The Section 3 opening was also split into clearer sentences.

The central reviewer-facing limitation remains the non-overlapping Polygon-to-Alpaca/IEX feed switch inside the held-out period. It is now disclosed accurately and conservatively. This lowers empirical strength but is no longer a hidden correctness problem.

### Readiness scores

| Dimension | Score | Assessment |
|---|---:|---|
| Technical accuracy | **9.4/10** | Mathematics, estimation descriptions, state selection, spectral results, and VaR interpretation are internally supported. |
| Empirical correctness | **8.5/10** | Values trace to committed artifacts; the mixed-feed held-out period remains a material disclosed limitation. |
| Narrative flow | **9.3/10** | Contributions, evidence, limitations, and conclusions are aligned and clearly sequenced. |
| ICAIF topical fit | **9.5/10** | Direct match to synthetic financial data, model validation, financial risk, and time-series analysis. |
| Submission readiness | **9.5/10** | Eight-page anonymous build passes all checks and the complete rendered PDF is visually clean. |

## 1. Technical accuracy assessment

### Mathematics and estimation

- The paper correctly presents CHMM as an established model class rather than a novel architecture.
- The absolute-growth-rate ACF identity is stated with stationarity, irreducibility/aperiodicity, finite-moment, and diagonalizability conditions.
- The algebraic `K - 1` modal bound is distinguished from fitted effective contribution.
- Complex-conjugate contributions and the non-diagonalizable Jordan-form caveat are disclosed.
- The dominant-mode share uses the declared `|a_k lambda_k|` lag-1 contribution rather than eigenvalue magnitude alone.
- The reported eigenvector-matrix condition numbers (`1.4` at `K = 3`, `7.3` at `K = 18`) reproduce from the committed artifact and support the SPY numerical-stability statement.
- Student-t and GED fitting are accurately described as hybrid/generalized block procedures without an unjustified monotonic-likelihood guarantee.
- Initial-distribution conventions and their effect on the 12-versus-15 parameter comparison are explicit.
- The HSMM duration row is correctly called moment-updated rather than maximum-likelihood because the update ignores the truncated normalizer.

### Empirical claims

- BIC/CAIC select `K = 3`; rolling-origin validation is correctly described as unable to distinguish `K = 3` from `K = 6` while disfavoring `K = 18`.
- The SPY modal shares (`0.968` at `K = 3`, `0.936` at `K = 18`) and panel diagnostic (median `0.726`, minimum `0.287`, median `n95 = 7`) trace to stored artifacts.
- Near-one-mode behavior is correctly limited to SPY rather than claimed panel-wide.
- The shared-`nu` CRPS value `1.0406` and other headline metrics are supported by committed outputs.
- Table 2 correctly maps each headline result to its actual Gaussian, shared-`nu`, or penalized per-state configuration.
- The Hill statistic is treated as a finite-threshold shape diagnostic for light-tailed mixtures, not an asymptotic tail-index estimate.
- Interval overlap is not presented as a formal equality test.
- The reduced QuantGAN control is said to fail the marginal and volatility-clustering diagnostics while retaining near-baseline raw-return autocorrelation, matching Table 1.

### Risk analysis

- Filter-conditional VaR is correctly defined as the quantile of the one-step-ahead predictive state mixture.
- It is distinguished from state-specific VaR, expected shortfall, and the Christoffersen conditional-coverage criterion.
- Main-window and walk-forward non-rejections are interpreted as compatibility, not proof.
- Low power at the 1% tier and multiplicity across walk-forward tests are explicit.
- The paper makes no unsupported pairwise superiority claim over filtered bootstrap or CAViaR.

## 2. Empirical credibility and reproducibility

The paper and model repositories were clean at the start of this audit. The figure assets embedded in the paper match the model-repository outputs by SHA-256. The replacement feed-boundary diagnostic, corrected spectral-share implementation, shared-`nu` CRPS evidence, eigenvector-conditioning output, and dedicated Figure 1 runner are committed.

The principal reviewer risk is still feed consistency. Polygon consolidated VWAP aggregates are used through December 2024, while Alpaca/IEX bars are used afterward. Because the feeds do not overlap and the switch is confounded with time, later changes cannot be attributed uniquely to the market or data source.

The manuscript handles this correctly:

- it calls the switch an unresolved OoS confound;
- it describes the KS result as an unadjusted, time-confounded, non-dependence-calibrated non-rejection;
- it acknowledges segment volatility and kurtosis differences; and
- it treats segmented VaR counts as descriptive rather than proof of feed equivalence.

Reconstructing the held-out period from one consistent feed would remain the strongest empirical enhancement, but it is not required for the manuscript to be technically honest in its current form.

## 3. Narrative flow and correctness

### Strengths

- The introduction moves cleanly from the Rydén low-state Gaussian result to the temporal/distributional decomposition and then states the paper's actual contributions.
- CHMM novelty is not overstated.
- The single reduced QuantGAN control is positioned accurately rather than presented as a broad deep-generator benchmark.
- Section 3 now introduces the growth-rate convention in two readable sentences and uses terminology consistent with Figure 1.
- Section 6.1 separates state selection from the spectral diagnostic.
- Table 2 prevents configuration drift by identifying the exact model behind each claim.
- The introduction, abstract, results, and conclusion now agree on periodic refitting: it helps under ordinary drift but did not repair abrupt stress-regime introductions.
- The conclusion accurately distinguishes information-criterion selection from ambiguous `K = 3` versus `K = 6` rolling-origin evidence.
- The bibliography is balanced and the last page looks finished.

### Optional polish only

- The abstract remains dense, but its density is defensible under the eight-page limit.
- Two small overfull horizontal boxes remain (`4.37 pt` and `2.17 pt`), neither visibly clipped.

No clipping, overlap, broken glyph, unreadable table text, stale figure label, or unbalanced column was observed on any page.

## 4. ICAIF '26 fit and domain

### Fit: very strong

The official [ICAIF '26 call for papers](https://icaif2026.org/call-for-papers.html) explicitly includes:

- generative AI, simulation, and synthetic data generation;
- AI-driven risk management;
- robustness and uncertainty quantification;
- validation and calibration of financial models;
- risk modeling and risk management;
- forecasting of financial scenarios; and
- financial time-series analysis and factor models.

The paper combines interpretable synthetic equity-return generation, financial-model validation, and conditional risk forecasting. It therefore fits both the methodological and application-oriented sides of ICAIF.

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

Topical fit is stronger than algorithmic novelty because CHMM itself is established. The paper correctly foregrounds:

1. the finite-mode spectral diagnostic and SPY-versus-panel finding;
2. the controlled heavy-tailed emission comparison under a common harness; and
3. the filter-conditional VaR head with walk-forward failure analysis.

## 5. Formal submission compliance

The official CFP lists an **August 2, 2026, Anywhere-on-Earth deadline** and requires a self-contained, anonymous ACM `sigconf` paper of no more than eight total pages, including references, with no supplementary appendix.

Fresh build and inspection results:

- PDF length: **8 / 8 pages**
- ACM `sigconf,anonymous`: **pass**
- source, PDF, and metadata anonymization: **pass**
- citations: **30 used, 30 defined, 0 unused, 0 undefined**
- visible clipping or overlap: **none**
- figures and tables: **legible**
- Figure 1 terminology: **correct and reproducible**
- bibliography balance: **pass**
- balance warnings: **none in the final log**
- overfull boxes: **2**, maximum `4.37 pt`, with no visible clipping
- automated repository checks: **all passed**

The conference is scheduled for November 14–17, 2026, in Milan and requires in-person presentation of accepted papers.

## 6. Final checklist

### Paper content

No blocking manuscript change remains.

### Strongest optional empirical improvement

1. Rebuild the held-out period from one consistent market-data feed if feasible; otherwise preserve the current limitation exactly.

### Repository/operational handoff

2. Commit this eighth-audit report if it should remain part of the paper repository.
3. Push paper commit `39394c4` and model commit `e34fafa`; both local branches were one commit ahead of `origin/main` during this audit.
4. Upload the freshly built `main.pdf` to CMT and re-open the uploaded file for a final page-count and rendering check.

## Bottom line

The paper is **ready for ICAIF '26 submission**. Its technical story, numerical evidence, scope qualifications, narrative flow, configuration mapping, and rendered presentation are coherent. The mixed-feed held-out period remains its main empirical weakness, but it is disclosed with appropriate restraint and does not undermine the paper's technical correctness.
