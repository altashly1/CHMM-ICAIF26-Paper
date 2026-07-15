# ICAIF '26 Paper Readiness Review

**Paper:** *Heavy-Tail Hidden Markov Generators for Daily Equity Returns: Stylized Facts and Regime-Conditional Value-at-Risk*  
**Review date:** July 15, 2026  
**Scope:** Technical accuracy, narrative flow, correctness, conference fit, and rendered-submission quality  
**Compared against:**

- Extended paper: `/Users/abdulrahmanalswaidan/Desktop/Project-Repos/Thesis/CHMM-Paper-Repository`
- Model and result artifacts: `/Users/abdulrahmanalswaidan/Desktop/Project-Repos/Thesis/CHMM-Model-Repository`
- Official ICAIF '26 call for papers: <https://icaif2026.org/call-for-papers.html>

## Executive verdict

The paper is **not submission-ready yet**, but its central idea is viable for ICAIF '26 after a focused major revision.

Conference fit is excellent. ICAIF '26 explicitly solicits work on synthetic data generation, financial-model validation, risk management, and financial time-series analysis. The current manuscript also satisfies the principal mechanical constraints: it uses anonymous ACM `sigconf`, compiles to seven pages, has no undefined references or citations, and passes the repository's anonymization checks.

The stored SPY generator, VaR, and walk-forward numbers mostly trace correctly to the source artifacts. The principal problem is therefore not numerical transcription. It is that the narrative combines results from several materially different CHMM configurations into what reads as a single 12-parameter model. This affects the abstract, novelty claim, cross-ticker evidence, and interpretation of the VaR results.

Indicative assessment:

| Dimension | Assessment |
|---|---:|
| Conference fit | 9/10 |
| Technical accuracy | 5/10 |
| Narrative and coherence | 6/10 |
| Current submission readiness | 4/10 |

## Submission-format audit

The official ICAIF '26 requirements are correctly captured in the repository:

- Submission deadline: August 2, 2026, AoE.
- Maximum eight pages total, including figures and references.
- ACM two-column `sigconf` format with the `anonymous` option.
- Double-blind review.
- No supplementary material or appendices.
- Self-contained submission.

The current PDF is seven pages and compiles successfully. The reference and anonymization checks pass. Five very small overfull boxes remain, all below the repository's 5-point failure threshold.

The visual rendering is stable, with no clipping, overlap, missing glyphs, or broken references. Figure 1 is too small for comfortable reading at normal page scale, however, and most of page 7 is blank after the references. The free space should be used to display evidence that is currently only asserted in prose.

## Critical technical findings

### 1. Headline claims are assembled from different model configurations

The abstract states that a model with 12 free parameters reproduces the stylized facts, narrows the Gaussian kurtosis gap without a tuning parameter, supports the VaR result, generalizes across the panel, and benefits from periodic refitting. These results do not come from one specification:

- The preferred SPY generator in Table 1 is the **shared-`nu` Student-t CHMM**, with six transition parameters, six location/scale parameters, and one shared shape parameter: **13 free parameters**, not 12.
- The VaR table uses **Gaussian CHMM-N**.
- The six-fold generator walk-forward uses **Gaussian CHMM-N**.
- The 30-ticker static and quarterly-refit panels use the **penalized per-state-`nu` Student-t model with `lambda = 20`**.
- The cross-ticker spectral diagnostic uses a separate Gaussian configuration at a different state count.

The penalized cross-ticker configuration is particularly important because the omitted kurtosis results are poor. The stored `sector_panel_summary_k3.txt` reports a median kurtosis residual of `+7.18`, with several simulated excess-kurtosis values between approximately 25 and 106. The conference paper reports only its KS summary.

This produces a configuration-switching problem: the marginal result comes from one model, VaR from another, walk-forward results from another evaluation, and cross-ticker/refit claims from a model that the SPY analysis classifies as a sensitivity specification because of its shrinkage artifact.

**Required action:** Select one canonical `K = 3` specification and evaluate it consistently across SPY generation, VaR, the cross-ticker panel, periodic refitting, and walk-forward folds. If rerunning is infeasible, identify the configuration explicitly in every result and rewrite the abstract as a statement about the CHMM family rather than one model.

### 2. The abstract's HSMM statement is false

The abstract says that the bootstrap and maximum-likelihood HSMM “carry no latent state for a regime-conditional forecast.” An HSMM necessarily contains latent states.

The intended claim appears to be that an analogous HSMM risk head was not implemented or evaluated. The results section already uses this more defensible wording.

**Required action:** Replace the abstract sentence with wording such as:

> The bootstrap and HSMM match or exceed the CHMM on single-window marginal fit; an analogous HSMM risk head is not evaluated here.

### 3. “Regime-conditional VaR” is not the quantity being calculated

The code computes the quantile of a one-step predictive mixture whose weights are filtered/predicted regime probabilities. It conditions on the observed return history while integrating over the latent state. It is not the state-specific quantity

\[
\operatorname{VaR}_{\alpha}(G_{t+1}\mid S_{t+1}=k).
\]

The current model section instead says that “conditional” means conditioning on the latent regime. That is inconsistent with the mixture definition and implementation.

The forecasting timing itself appears correct: each threshold uses the predicted state distribution before observing the corresponding held-out return, and the filter is initialized from the in-sample history without future leakage.

**Required action:** Rename the head to one of:

- filter-conditional VaR;
- regime-adaptive VaR;
- regime-mixture predictive VaR.

Then define it explicitly as the quantile of

\[
p(G_{t+1}\mid G_{1:t})
= \sum_k p(S_{t+1}=k\mid G_{1:t}) f_k(G_{t+1}).
\]

### 4. The “maximum-likelihood HSMM” duration update is not an exact MLE

The main HSMM benchmark uses a truncated discrete Pareto duration distribution,

\[
p(d;\alpha) \propto d^{-(\alpha+1)}, \qquad d\in\{1,\ldots,D_{\max}\}.
\]

Its implementation updates `alpha` using `1 / E[log d]`. This is the familiar continuous, untruncated Pareto expression, but it is not the exact maximum-likelihood update for a normalized truncated discrete Pareto because the normalizing constant depends on `alpha`.

Consequently, the duration block is approximate and the fitted model should not currently be described as jointly maximum-likelihood.

**Required action:** Either:

1. numerically maximize the posterior-weighted duration objective including the `alpha`-dependent normalizer; or
2. relabel the row as an approximate or moment-updated explicit-duration HSMM.

The former is preferable because the HSMM comparison is central to the paper's historical framing.

### 5. The spectral evidence is described more strongly than it supports

The reported dominant-mode share is calculated from absolute modal contributions, `|a_k lambda_k|`. Thus “93.6% of the lag-1 ACF” should be “93.6% of the total absolute lag-1 modal contribution.” With signed or complex contributions, the two statements are not generally equivalent.

The cross-ticker diagnostic is also evaluated at `K = 18`. It does not establish the abstract's panel-wide statement that the rank bound is inactive “once a few states are used.” The available evidence supports:

- nonbinding behavior for SPY at `K = 3`;
- dominant-mode behavior across the panel at the evaluated `K = 18`;
- a median panel share of 0.76 but a minimum of 0.326.

The median share is suggestive, but there is no predeclared threshold under which 0.76 proves that the remaining modes are immaterial. Nor is the cross-ticker ACF-MAE shown to be flat from `K = 3` to `K = 18`.

**Required action:** Narrow the panel claim to the actual evaluated state count or run the cross-ticker diagnostic at `K = 3`. Define the dominant share precisely as a share of total absolute modal contribution.

### 6. The preferred shared-`nu` model is not described in the estimation section

The model and ECM section describes per-state degrees of freedom `nu_k` and the penalized sensitivity specification. The headline Table 1 row instead uses a single `nu` shared across all states, fitted through an aggregate posterior-weighted objective.

The table caption identifies the constraint, but the estimation method and parameter count are missing from the methods section.

**Required action:** Add the shared-shape objective,

\[
Q(\nu)=\sum_{t,k}\gamma_t(k)\log t_{\nu}(O_t;\mu_k,\sigma_k),
\]

state the bounded optimization used, and give the correct 13-parameter count at `K = 3`.

### 7. Gaussian states do not have fitted shape parameters

The introduction and conclusion connect the 12-parameter CHMM-N to readable per-state “location, scale, and shape.” CHMM-N has only location and scale parameters. The shared-`nu` Student-t model has one global shape, not a separately readable shape for every state.

**Required action:** Match the interpretability claim to the actual variant:

- CHMM-N/L: state-specific location and scale;
- CHMM-GED/per-state Student-t: state-specific location, scale, and shape;
- shared-`nu` Student-t: state-specific location/scale and one global tail-shape parameter.

### 8. Table 1 mixes IS/OoS columns with unlabeled IS-only ACF values

The KS and kurtosis columns are explicitly divided into IS and OoS. The two ACF columns contain only in-sample values, but this is not stated clearly. For example, CHMM-N's displayed absolute-return ACF-MAE is `0.0462` IS, while the stored OoS value is `0.0544`.

The GARCH-t and MS-GARCH rows also leave OoS kurtosis blank without explaining why.

**Required action:** Mark the ACF columns as IS or provide both IS/OoS values. Explain or populate missing baseline entries.

### 9. The Hill-estimator interpretation overreaches

The manuscript correctly acknowledges that a top-5% Hill estimate for Gaussian, Laplace, and GED mixtures is a threshold-local shape diagnostic rather than an asymptotic tail index. It then says that the simulated tail is “matched” and is only “slightly thinner in the far tail.” Those conclusions do not follow from the stated diagnostic.

At the OoS length, the top 5% contains only about 29 observations. Overlap between an across-path interval and an observed bootstrap interval is also not a formal equality test.

**Required action:** State only that the finite-threshold estimates overlap the observed uncertainty range. Do not infer asymptotic or far-tail agreement.

### 10. The CRPS citation is incorrect

Diebold and Mariano (1995), *Comparing Predictive Accuracy*, is not the standard reference for CRPS or proper scoring rules.

**Required action:** Cite an appropriate CRPS/proper-scoring source, such as Gneiting and Raftery (2007). Retain Diebold-Mariano only if an actual predictive-accuracy comparison test is reported.

## Evaluation-design concerns

### KS pass rate

The paper appropriately acknowledges that the asymptotic two-sample KS null assumes independent observations and is not calibrated for serially dependent return paths. Nevertheless, it continues to use the pass rate as the main ranking, defines cross-ticker “failures” from it, and uses “best” language.

The extended work contains block-bootstrap recalibration and continuous-distance robustness results, but ICAIF accepts no supplement and the conference manuscript does not display them.

**Recommendation:** Show at least one continuous distributional distance in Table 1 or replace KS pass rate with the mean KS statistic. If retaining the pass rate, include the block-aware OoS recalibration for the canonical model and key baselines.

### VaR non-rejection

The manuscript is commendably careful not to equate non-rejection with proof. The `alpha = 0.01` results remain extremely low-powered at 573 observations, with only 5.7 expected breaches.

The phrase “higher-power DQ test” is too broad. DQ can test richer dynamic misspecification, but it is not uniformly more powerful, especially in sparse-tail samples.

**Recommendation:** Say “the richer DQ specification” rather than “higher-power DQ test,” unless direct power evidence for the relevant alternatives is shown.

### Cross-ticker reporting

The paper reports cross-ticker KS but omits the corresponding kurtosis failures. This is selective relative to its own three-axis definition of generator quality. It also does not identify the 30 tickers, family, penalty, training-window behavior, or refit training length in the condensed manuscript.

**Recommendation:** Report the panel's marginal and temporal metrics together for the canonical configuration. Include the ticker universe and the 1,260-day rolling window/63-day cadence.

### Benchmark fairness

The QuantGAN row is explicitly described as a negative control, which is good. The conference manuscript should still disclose that it is an in-house, materially smaller approximation rather than a faithful reproduction of the reference QuantGAN architecture. It should not be used to support a broad claim about deep generative models.

The HSMM row should identify `K = 3`, its truncated-Pareto duration law, `D_max`, and the estimation caveat. Otherwise the reader cannot assess why an explicit-duration model sits at the i.i.d. ACF-MAE floor.

## Self-contained evidence problem

ICAIF '26 prohibits supplementary material and requires self-contained papers. The manuscript currently asserts several results that are not supported by a displayed table or figure:

- BIC/CAIC and rolling-origin state selection;
- four-fold and six-fold likelihood comparisons;
- spectral effective-rank results;
- cross-ticker distribution and ANOVA;
- quarterly-refit improvement;
- six-fold generator walk-forward;
- robustness across KS, Anderson-Darling, Hellinger, and Wasserstein-1;
- CRPS indistinguishability;
- the full four-family VaR/DQ panel.

References to “extended experiments” cannot supply evidence during review because the extended arXiv paper is deliberately uncited and no supplement is allowed.

The rendered PDF has enough unused space to address this. Most of page 7 is blank, giving approximately one page for an additional compact figure or table.

**Recommended use of the eighth page:**

1. A compact canonical-model validation table containing:
   - SPY main-window results;
   - median and IQR across six walk-forward folds;
   - cross-ticker median/IQR and failure count;
   - static versus quarterly-refit comparison.
2. A small state-selection/effective-rank panel containing:
   - BIC/CAIC winner;
   - held-out log-likelihood for `K = 3, 6, 18`;
   - dominant modal share at `K = 2, 3, 18`.

If only one can be added, prioritize the canonical-model validation table.

## Narrative assessment

### What works

The strongest intellectual story is clear and relevant:

> The low-state Gaussian HMM limitation contains separate temporal and marginal channels. On the studied SPY data, the temporal rank bound is already effectively nonbinding at a small state count, while marginal/emission flexibility explains more of the residual fit gap.

This is a useful empirical reinterpretation of the Rydén/Bulla line and a credible ICAIF contribution when coupled with an inspectable generator and a properly defined risk head.

The manuscript is also unusually candid about:

- the CHMM not being a new model class;
- bootstrap/HSMM advantages on marginal fit;
- invalid iid calibration of KS under dependence;
- power limits of 1% VaR backtests;
- regime-introduction failures;
- the lack of a privacy guarantee;
- finite-state inability to generate genuine power-law memory.

These caveats increase credibility.

### What weakens the flow

The seven-page version tries to carry too many threads:

1. spectral diagnosis;
2. four emission families;
3. state-count selection;
4. generator benchmarks;
5. Hill tail index;
6. gain/loss asymmetry;
7. cross-ticker generalization;
8. periodic refitting;
9. multi-asset copula companion work;
10. VaR validation.

This breadth causes the results section to read as a compressed inventory rather than a single escalating argument. Important claims receive one sentence, while the copula and tail-asymmetry material introduce additional unvalidated directions.

**Recommended story order:**

1. Establish the two-channel question.
2. Define the canonical CHMM and estimation.
3. Use the spectral diagnostic to justify why additional states are not the main lever.
4. Compare emission families and select one canonical configuration.
5. Validate that same configuration on walk-forward and cross-ticker data.
6. Exercise its filter-conditional VaR head.
7. Conclude with limitations and stress-regime failure.

Remove the copula companion paragraph. Compress or remove the gain/loss-asymmetry sentence. Retain the Hill analysis only if it can be stated without asymptotic implications.

## Novelty positioning

The current paper openly states that the CHMM is established. This is appropriate but leaves the novelty claim dependent on the combination of:

- a controlled cross-emission comparison;
- quantile-based nondegenerate initialization;
- the empirical spectral effective-rank diagnosis;
- a small, inspectable generator;
- a filter-driven risk head;
- multi-window and cross-ticker validation.

That contribution is plausible for an application-oriented ICAIF paper, but reviewers may still view it as incremental if the evidence is spread across different configurations.

The paper should avoid claiming a new “unified EM” algorithm when Student-t/GED estimation is a hybrid generalized block-coordinate procedure without guaranteed monotone ascent. “Unified forward-backward framework with family-specific generalized-ECM updates” is more accurate.

The interpretability claim would also be stronger if the extra page showed the fitted state locations, scales, stationary weights, and expected durations. At present, the paper calls the states economically readable without displaying or economically interpreting them.

## Presentation corrections

### Dummy publication metadata

The rendered first page contains placeholder values:

- `10.1145/nnnnnnn.nnnnnnn`
- `978-x-xxxx-xxxx-x/YY/MM`

These should not appear in a review submission. Remove the placeholder DOI/ISBN and review-stage rights metadata, restoring the official values only at camera-ready.

### Figure 1

The two panels are individually only `0.49\columnwidth`, making labels difficult to read. The figure does not visually show the raw-return ACF even though the manuscript claims all three stylized facts.

Possible improvements:

- use a full-width two-column figure;
- enlarge labels and line weights at source;
- add a small raw-return ACF inset or explicitly state where that evidence appears.

### Density

Pages 1–6 are text-heavy, especially the abstract, introduction, and results. The abstract is much longer than the original 150–180 word target and contains too many subordinate claims. The conclusion repeats several numerical results already present in the results section.

Shortening the introduction's baseline survey and conclusion repetition would make room for direct evidence without exceeding eight pages.

## Prioritized revision sequence

### Submission blockers

1. Choose and declare a canonical model configuration.
2. Correct the false HSMM latent-state sentence.
3. Rename and correctly define the VaR head.
4. Fix or relabel the approximate “ML HSMM” benchmark.
5. Rewrite the abstract so its parameter count and claims refer to the same configuration.
6. Disclose the penalized model used in the cross-ticker/refit panel or rerun that panel with the canonical model.

### High-priority strengthening

7. Add one page of self-contained walk-forward/cross-ticker/state-selection evidence.
8. Describe the shared-`nu` estimation method.
9. Correct the spectral-share definition and narrow its generalization.
10. Label Table 1's ACF window and address missing baseline entries.
11. Replace the CRPS citation.
12. Narrow the Hill-estimator interpretation.

### Final polish

13. Remove dummy DOI/ISBN metadata.
14. Enlarge Figure 1.
15. Remove the copula companion paragraph.
16. Show fitted regime parameters or narrow the interpretability language.
17. Replace “higher-power DQ” with “richer DQ specification.”
18. Run `make check` and visually inspect the final eight-page PDF.

## Recommended abstract-level claim after correction

A defensible high-level claim would be:

> We evaluate a family of low-state continuous-emission HMM generators under a common filtering framework. On SPY, a spectral decomposition shows that the fitted absolute-return ACF is already dominated by one persistent mode at three states, while changing the emission family materially affects marginal and tail diagnostics. A canonical small-state specification is then evaluated across rolling windows, a 30-ticker panel, and a filter-conditional VaR backtest. The model is competitive on marginal and volatility-clustering diagnostics in stable periods but requires refitting under regime introductions and does not reproduce genuine long-memory or provide a privacy guarantee.

This is less aggressive than the current abstract but is technically coherent and easier for a reviewer to trust.

## Final recommendation

Proceed toward ICAIF '26, but do not submit the current PDF unchanged. The topic is directly aligned with the conference, the paper is mechanically compliant, and the two-channel spectral framing is potentially publishable. The configuration-switching problem, HSMM misstatement, VaR terminology, and approximate-ML benchmark are likely reviewer-visible technical weaknesses and should be resolved first.

After those corrections, the highest-value improvement is not more prose or more experiments. It is a single, self-contained validation panel showing that one named canonical specification supports the paper's generator, generalization, and risk claims.
