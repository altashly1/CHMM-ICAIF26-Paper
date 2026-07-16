# Paper Readiness Review — Ninth Post-Correction Audit (2026-07-15)

**Paper:** *Heavy-Tail Hidden Markov Generators for Daily Equity Returns: Stylized Facts and Filter-Conditional Value-at-Risk*

**Target:** 7th ACM International Conference on AI in Finance (ICAIF '26), Milan, November 14–17, 2026

**Audit basis:** the current clean manuscript commit `4fced70`, a fresh build of `main.pdf`, all eight rendered PDF pages, the stored results and Julia implementation in `Thesis/CHMM-Model-Repository`, and the live ICAIF '26 call for papers checked on July 15, 2026.

## Executive verdict

**Submission-ready. No blocking technical, numerical, narrative, formatting, or conference-fit issue remains.**

The eighth audit identified three claim-level problems. All three have now been corrected accurately and revalidated against the artifacts:

1. The manuscript no longer says the out-of-sample absolute-return ACF-MAE ranking is preserved. It correctly discloses that CHMM-N changes from `0.0462` in sample to `0.0544` out of sample, approximately the bootstrap floor (`0.0542`), behind the heavy-tailed CHMM rows (`0.0498–0.0502`) but ahead of GARCH (`0.0593`).
2. The reported 1% Christoffersen conditional-coverage interval is correctly changed to `[0.14, 0.16]` for the Table 3 rows.
3. The sector ANOVA is now explicitly identified as a diagnostic computed on the `K = 18` fits, rather than being implicitly attributed to the `K* = 3` cross-ticker configuration.

The paper can be submitted in its current form. The remaining issues below are limitations or optional polish, not reasons to delay submission.

### Readiness scores

| Dimension | Score | Assessment |
|---|---:|---|
| Technical accuracy | 9.4/10 | Equations, estimators, parameter counts, evaluation protocols, and corrected claims agree with the implementation and artifacts. |
| Empirical rigor | 8.6/10 | Unusually extensive checks, baselines, walk-forward tests, panel evidence, and explicit negative results; the nonoverlapping vendor switch remains the principal design limitation. |
| Narrative flow | 9.2/10 | Clear negative-result → two-channel diagnosis → spectral diagnostic → empirical comparison → risk application arc; some paragraphs remain dense. |
| Writing and correctness | 9.4/10 | Precise, restrained, and internally consistent; no material grammar or terminology defect found. |
| ICAIF topical fit | 9.5/10 | Direct fit to synthetic financial time-series generation, validation/calibration, and AI-driven risk management. |
| Submission readiness | 9.5/10 | Eight-page anonymous ACM PDF, self-contained, bibliography clean, visually sound. |

## 1. Technical accuracy

### Model and notation

The mathematical presentation is internally consistent and matches the code conventions:

- The annualised growth rate is defined as `(1/Delta t) log(P_t/P_{t-1}) - r_f`, with `Delta t = 1/252` and `r_f = 0`; the manuscript correctly calls this an annualised log growth rate rather than an excess growth rate.
- The filter-conditional VaR is correctly defined as the quantile of the one-step-ahead predictive state mixture. It is properly distinguished from a state-specific quantile, expected shortfall/CVaR, and the Christoffersen back-test statistic.
- The marginal mixture uses the stationary state distribution, while unconditional simulation initializes from that distribution. The risk head instead updates the filtered regime probabilities sequentially under fixed in-sample parameters.
- The spectral identity for the absolute-growth-rate ACF has the correct coefficient form under the stated irreducibility, aperiodicity, diagonalizability, and finite-second-moment assumptions. The discussion correctly handles complex-conjugate eigenpairs and non-diagonalizable matrices via real damped oscillations or Jordan terms.
- The dominant-mode share is accurately described as a share of total absolute modal contribution at lag 1, not necessarily a share of the signed ACF itself.

### Estimation and parameter counting

The estimation section faithfully describes the implementation:

- All emission families use log-space forward–backward recursions and quantile-based initialization.
- CHMM-N uses the Baum–Welch closed-form updates, fixes the initial distribution at uniform, and excludes it from the parameter count.
- The Student-t ECM uses the implemented scale update with denominator `sum(gamma)`, the posterior-precision weights, and a bracketed degrees-of-freedom update. The shared-nu variant uses one aggregate one-dimensional update.
- The Laplace weighted-median/weighted-MAD updates and GED block-coordinate conditional maximization match the Julia code.
- The paper correctly declines to promise monotone observed-likelihood ascent for the hybrid Student-t and GED procedures and describes the last-finite-iterate safeguard.
- Parameter counts are consistent with the stated conventions: 12 for Gaussian at `K = 3` and 15 for shared-nu Student-t.
- The stated stopping tolerance, iteration cap, asymptotic recursion cost, simulation path count, and fixed seed agree with the implementation.

### Results and statistical claims

The current tables and principal prose values agree with their stored artifacts at the displayed precision:

- Table 1's generator comparison is consistent with the headline CHMM, bootstrap, GARCH/MS-GARCH, QuantGAN-control, and HSMM artifacts.
- Table 2 correctly maps each result to its actual configuration rather than implying that one CHMM specification generated every headline result.
- Table 3's breach counts, rates, Christoffersen `p_cc`, and DQ values agree with the conditional-VaR artifacts. The manuscript appropriately treats the 1% rows as low-power and treats non-rejection as compatibility, not proof.
- The six-fold walk-forward statement correctly reports 19/24 Christoffersen non-rejections and locates the five rejections in W2 plus the W4 `K = 18`, 1% row.
- The single-window clustering improvement is now explicitly scoped to the in-sample window; the out-of-sample reversal is disclosed instead of hidden.
- Cross-ticker KS, kurtosis-residual, quarterly-refit, state-selection, spectral-share, and tail-index summaries match the stored files at their stated rounding.
- The two paper figure PDFs are byte-for-byte identical to the current model-repository artifacts (SHA-256 verified).

### Technical limitations that remain

1. **Vendor/feed transition inside the out-of-sample period.** Polygon consolidated bars end before the Alpaca/IEX segment begins, so vendor effects and calendar-time effects cannot be separately identified. The paper now describes this accurately as an unresolved confound and avoids interpreting the pre/post KS checks as proof of feed equivalence. This is the largest empirical limitation, but it is disclosed strongly enough that it is not a correctness defect.
2. **KS pass rate is descriptive under serial dependence.** The manuscript correctly states that the classical asymptotic KS null is not calibrated for these dependent paths and supplements it with Wasserstein, Anderson–Darling/Hellinger, CRPS, tail, and ACF diagnostics.
3. **Configuration heterogeneity.** Gaussian CHMM-N supplies the VaR head, shared-nu Student-t is the preferred SPY generator, penalised per-state Student-t supplies the cross-ticker panel, and `K = 18` supplies the panel spectral and sector-ANOVA diagnostics. Table 2 and Section 6.6 now make this division explicit. Reviewers may still find the result map cognitively demanding, but it is no longer misleading.
4. **Empirical rather than algorithmic novelty.** CHMMs and the component estimators are established. The defensible contribution is the two-channel diagnosis, spectral interpretation, controlled emission-family comparison, and risk evaluation—not a new HMM class. The paper positions this correctly.
5. **Stress-regime transport remains weak.** Static fits fail in the COVID/rate-hike folds and the GLD stress test; tested refit cadences do not repair abrupt regime introductions. This is reported prominently and improves the paper's credibility.

## 2. Narrative flow and writing

### What works

The argument has a strong, referee-friendly sequence:

1. motivate synthetic daily-equity paths and the classic low-state Gaussian-HMM failure;
2. separate temporal capacity from marginal-distribution capacity;
3. derive an interpretable spectral diagnostic;
4. compare emission families and conventional/nonparametric/deep controls;
5. test whether the SPY interpretation generalizes across windows and tickers;
6. turn the fitted state filter into a concrete VaR application;
7. finish with an explicit configuration map and negative stress evidence.

The paper's restraint is a major narrative strength. It does not claim a universal long-memory solution, does not equate back-test non-rejection with validation, does not claim privacy, and does not conceal benchmark wins or failed stress folds.

### Optional improvements

These are worthwhile only if they can be made without destabilizing the eight-page layout:

- The abstract is approximately 269 words and information-dense. It is accurate, but trimming the configuration-by-configuration detail to roughly 220–240 words would improve first-pass readability.
- Section 6.2's corrected ACF-MAE parenthetical is long. The disclosure is necessary, but it could become a short standalone sentence after the headline CHMM-N result.
- The introduction repeats much of the abstract's qualification structure. One paragraph could be shortened by reserving configuration-level caveats for Table 2/Section 6.6.
- “Tickers that introduced a new regime out of sample” is an interpretive diagnosis. If no per-ticker regime-trajectory artifact will accompany the release, “tickers experiencing an apparent distributional shift out of sample” would be harder to challenge.
- The claim that the IEX feed carries roughly 2.5% of consolidated volume should ideally receive a time-stamped market-share citation or be shortened to “a single-exchange feed.” The exact percentage is not needed for the argument.

No grammatical pattern, notation collision, or terminology error warrants mandatory copy-editing. The corrected manuscript is dense because the result set is large, not because the argument is disorganized.

## 3. Fit to ICAIF '26 and recommended domain

### Conference fit

**Fit is strong.** The live ICAIF '26 call explicitly solicits work connecting AI and finance from methodological and application perspectives. This paper contributes a latent-state generative model evaluation for financial time series, a spectral validation diagnostic, synthetic-return experiments, and a filter-conditional risk application. Its scope is narrower than a general machine-learning paper but exceptionally well aligned with ICAIF.

The main acceptance risk is not topical mismatch. It is whether reviewers view the empirical/spectral diagnostic contribution as sufficiently novel relative to established HMM and regime-switching literature. The paper addresses this reasonably by centering the two-channel decomposition and by providing much broader validation than a routine “fit an HMM to returns” study.

### Recommended submission domain

**Primary methodology domain:** **Generative AI, simulation, and synthetic data generation**

This should be the first classification because the paper's motivating object and main comparison are synthetic equity-return generators, and the stylized-fact tests evaluate synthetic path fidelity.

**Secondary methodology domains:**

- **Validation and calibration of financial models** — spectral diagnostic, state-count validation, walk-forward evaluation, cross-ticker checks, and back-testing.
- **AI-driven risk management and fraud detection** — specifically the risk-management half, through filter-conditional VaR.
- **Robustness and uncertainty quantification** — block-bootstrap intervals, tail-index uncertainty, multiple windows, stress folds, and explicit low-power interpretation.

**Primary application domain:** **Risk modeling and risk management**

**Secondary application domains:**

- Financial time series analysis and factor models
- Forecasting of financial scenarios
- Market microstructure modeling and simulation, but only as a weak tertiary label; the paper uses vendor/feed data rather than studying microstructure mechanisms.

If the submission system permits only one topic, choose **Generative AI, simulation, and synthetic data generation**. If it asks for an application rather than a methodology, choose **Risk modeling and risk management**.

## 4. Formal submission compliance

The current paper satisfies the live CFP requirements checked on July 15, 2026:

- `sigconf` ACM two-column format with the `anonymous` option;
- exactly 8 pages total, including figures and references;
- self-contained PDF with no supplement dependency;
- anonymous author block and clean source/PDF identity scan;
- 30 cited references, 30 defined, none unused or undefined;
- conference metadata: Milan, November 14–17, 2026;
- all eight pages visually inspected with no clipping, overlap, broken table, unreadable label, or unbalanced final bibliography page.

The build reports two small overfull lines (`4.37 pt` and `2.17 pt`). They are visually harmless at rendered-page scale and are not submission blockers.

The live CFP lists the paper deadline as **August 2, 2026, Anywhere on Earth**, requires double-blind review, limits papers to eight total pages, rejects supplementary materials, and expects an accepted paper to be presented in person. Source: [ICAIF '26 Call for Papers](https://icaif2026.org/call-for-papers.html).

## 5. Reproducibility and repository notes

- The model repository is clean and synchronized with its upstream at commit `e34fafa`.
- The paper branch is clean before this report update and is two commits ahead of its upstream; those commits contain the eighth-audit findings and the corresponding manuscript corrections.
- Before the promised public code release, move the exact HSMM benchmark runner out of an `_attic` path or document it unambiguously, include the runner for the QuantGAN TCN control if it is meant to be reproducible, and reconcile the GED fitter docstring with the paper's appropriately cautious monotonicity statement.
- These release-hygiene items do not affect anonymous PDF submission readiness, especially because the ICAIF call does not accept supplementary material.

## Final recommendation

**Submit to ICAIF '26.** Use **Generative AI, simulation, and synthetic data generation** as the primary methodology domain and **Risk modeling and risk management** as the primary application domain. The paper is technically defensible, narratively coherent, appropriately cautious, and formally compliant. Any further edits should be limited to optional readability polish and should be followed by another page-count and PDF-render check.
