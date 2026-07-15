# ICAIF '26 Paper Readiness Review

**Paper:** *Heavy-Tail Hidden Markov Generators for Daily Equity Returns: Stylized Facts and Filter-Conditional Value-at-Risk*
**Review date:** July 15, 2026  
**Scope:** Technical accuracy, narrative flow, correctness, conference fit, and rendered-submission quality  
**Compared against:**

- extended manuscript: `/Users/abdulrahmanalswaidan/Desktop/Project-Repos/Thesis/CHMM-Paper-Repository`;
- implementation and stored results: `/Users/abdulrahmanalswaidan/Desktop/Project-Repos/Thesis/CHMM-Model-Repository`;
- official ICAIF '26 call: <https://icaif2026.org/call-for-papers.html>.

## Executive verdict

The paper is a **strong topical fit for ICAIF '26 and close to submission-ready**, but I would not submit this exact PDF. The core numerical claims checked in the source artifacts are accurate, the principal model configurations are now disclosed, and the paper is much more technically candid than the previous version. The remaining work is a focused accuracy and presentation pass rather than a new experimental program.

The main blockers are:

1. a direct contradiction in the abstract between “at three states” and a statistic evaluated at `K = 18`;
2. a few remaining family-level statements that are not true of every estimator/configuration;
3. an ACF identity whose domain must be stated as lag `tau >= 1`;
4. an unsupported “statistically indistinguishable” CRPS claim in the self-contained conference version;
5. ACM template warnings caused by suppressing the mandatory reference-format block and omitting figure descriptions.

Indicative assessment:

| Dimension | Assessment |
|---|---:|
| Conference fit | 9/10 |
| Technical accuracy | 7.5/10 |
| Narrative and coherence | 7/10 |
| Correctness and reproducibility | 8/10 |
| Current submission readiness | 7/10 |

## Conference fit and domain

### Fit

ICAIF '26 explicitly lists the following relevant areas:

- **Generative AI, simulation, and synthetic data generation**;
- **AI-driven risk management**;
- **validation and calibration of financial models**;
- **risk modeling and risk management**;
- **forecasting of financial scenarios**;
- **financial time-series analysis and factor models**.

The paper therefore fits the venue directly. Its best positioning is not “a new HMM algorithm” and not generic econometrics. It is an **interpretable probabilistic generator for financial scenarios, with model validation and a risk-management head**.

### Recommended domain selection

If CMT asks for one primary topic, choose:

> **Methodology: Generative AI, simulation, and synthetic data generation**

Recommended secondary topics:

1. **Validation and calibration of financial models**;
2. **AI-driven risk management**;
3. **Robustness and uncertainty quantification**.

Recommended application area:

> **Risk modeling and risk management**

with **financial time-series analysis** and **forecasting of financial scenarios** as secondary applications.

The technical subdomain is:

> **Probabilistic machine learning for finance — latent-variable, regime-switching, and synthetic financial time-series models.**

Do not position it primarily as asset pricing, trading, deep learning, or NLP. The existing CCS concepts—latent-variable models, economics, and time-series analysis—are appropriate.

### Acceptance-risk framing

Topical fit is not the main risk. The likely reviewer concern is novelty: the paper openly uses an established model class and standard forward–backward machinery. Its publishable contribution is the combination of:

- a two-channel reinterpretation of the low-state Gaussian-HMM limitation;
- an empirical spectral effective-rank diagnosis;
- a transparent cross-emission comparison;
- a small, inspectable financial generator;
- filter-conditional VaR;
- walk-forward and cross-ticker validation with explicit failure cases.

Keep that empirical-diagnostic contribution central. Avoid implying that CHMMs, Baum–Welch, or the spectral identity are themselves new.

## What is now technically solid

The following corrections and disclosures are strong:

- The risk head is correctly named **filter-conditional VaR** and is defined as the quantile of the one-step predictive state mixture, not as state-conditioned VaR.
- The forecast timing is consistent with a one-step-ahead filter and no future-return leakage was found in the described procedure.
- The HSMM row is now explicitly described as approximate because its truncated-duration normalizer is ignored in the shape update.
- The shared-`nu` Student-t objective and its parameter-counting convention are described.
- The dominant-mode share is correctly defined using absolute modal contributions, including the sign caveat.
- The panel section now identifies the penalized per-state Student-t configuration and discloses its poor kurtosis behavior instead of reporting only KS.
- The QuantGAN is correctly labeled a smaller in-house negative control rather than a faithful reproduction of the published system.
- KS pass rates are described as descriptive rather than calibrated tests under serial dependence, and Wasserstein-1 is supplied as a continuous-distance check.
- VaR non-rejection is not presented as proof of correct coverage, and the 1% test is correctly described as power-limited.
- Table 3 makes the configuration switching explicit and adds the state-selection, rolling-origin, walk-forward, panel, and spectral evidence needed in a no-supplement conference submission.

The checked numerical values agree with the stored artifacts, including:

- BIC/CAIC for `K = 3, 6, 18`;
- four-fold and six-fold held-out log likelihoods;
- SPY dominant-mode shares `1.000`, `0.968`, and `0.936` at `K = 2, 3, 18`;
- cross-ticker median/minimum shares `0.756/0.326`;
- the displayed Gaussian state locations and scales;
- the main generator, cross-ticker, refit, and VaR table entries.

## Required technical corrections

### 1. Correct the abstract's state-count contradiction

The abstract currently says:

> “dominated by one persistent mode at three states (93.6% ... at the evaluated K = 18)”

The source results are:

- `96.8%` at `K = 3`;
- `93.6%` at `K = 18`.

Use one of these constructions:

> On SPY, one persistent mode carries 96.8% of the total absolute lag-1 modal contribution at the selected three-state fit.

or:

> On SPY, one persistent mode carries 96.8% at `K = 3` and 93.6% at the diagnostic `K = 18`.

This is the most visible factual error because it appears in the abstract.

### 2. State that the spectral ACF identity applies at positive lags

The identity

`E[|G_t||G_{t+tau}|] = m' diag(pi) T^tau m`

uses conditional independence of separate observations given their states. It is valid for `tau >= 1`. At `tau = 0`, the same observation appears twice and the conditional second moment is required; substituting `m_k^2` is generally wrong.

Add `for tau >= 1` to the sentence introducing the identity and to the scope of Equation (6). The empirical diagnostic already uses positive lags, so no results need to be rerun.

### 3. Correct the parameter-budget language

The introduction says the four variants use “12 to 15 free parameters at three states depending on emission family.” Under the paper's own convention, the counts are:

| Variant | `K = 3` count |
|---|---:|
| CHMM-N, fixed initial distribution | 12 |
| CHMM-L, updated initial distribution | 14 |
| shared-`nu` CHMM-t, updated initial distribution | 15 |
| per-state-`nu` CHMM-t, updated initial distribution | 17 |
| CHMM-GED, updated initial distribution | 17 |

Either change the family-wide range to **12–17**, or say that the two headline configurations use **12 and 15** parameters.

Relatedly, “the four variants share everything except the emission family” is not literally true because CHMM-N fixes the initial distribution while the other fitters update it. Use:

> The variants share the state-space structure and forward–backward recursions but differ in emission family and the treatment of the initial distribution.

### 4. Narrow the CRPS inference

The results say that the four `K = 3` CHMM variants are “statistically indistinguishable” from their mean CRPS values alone. The conference paper does not display a test, and the stored Diebold–Mariano robustness artifact does not clearly establish the claim for the new shared-`nu`, `K = 3` row.

The safe correction is:

> The four CHMM variants have numerically similar mean OoS CRPS values (1.0393–1.0432).

If “statistically indistinguishable” is retained, run/report the exact pairwise test for the four displayed configurations, state the loss-differential and HAC specification, cite Diebold–Mariano, and account for multiplicity. Otherwise remove the unused `diebold1995comparing` bibliography entry.

### 5. Make the conclusion variant-accurate

The first conclusion sentence describes the family as a continuous-emission HMM “trained by Baum–Welch.” Baum–Welch is exact for the Gaussian row, while the Student-t and GED fits use generalized/hybrid block updates whose monotone ascent is not guaranteed. Use:

> The CHMM family, fitted with common forward–backward recursions and family-specific M-steps, captures the three symmetric diagnostics at `K = 3`...

The conclusion also says the spectral argument “motivates the state-count choice.” Operationally, BIC/CAIC and rolling-origin validation choose `K = 3`; the spectral argument diagnoses why additional ACF modes are unnecessary on this instance. State that distinction.

Finally, replace “the fitted states read directly as economic regimes” with **“return/volatility regimes”** or **“economically interpretable regimes.”** The location and scale values support calm/intermediate/stress labels, but no external economic-state validation is performed.

### 6. Avoid overclaiming exact reproduction of heavy tails

CHMM-N produces excess kurtosis `3.83/3.62` against observed `7.68/5.29`. Its mixture captures a heavy-tailed sample shape and performs well on KS/Hill diagnostics, but a finite Gaussian mixture is asymptotically light-tailed and leaves a substantial point-estimate kurtosis gap.

“Reproduces the three stylized facts” is defensible only as a qualitative diagnostic statement. More precise wording is:

> captures the three symmetric stylized-fact diagnostics, while leaving an excess-kurtosis gap that heavy-tailed emissions narrow.

This phrasing is also consistent with the limitations section.

### 7. Keep the HSMM label explicitly approximate

The benchmark is now candidly described, which resolves the earlier accuracy problem. Still, “approximate-ML” can be read as a nearly exact likelihood fit. A clearer label is:

> HSMM-N (moment-updated duration)

or:

> HSMM-N (approximate-EM)

No new experiment is required unless the paper wants to call it a maximum-likelihood HSMM; that would require optimizing the normalized truncated discrete-Pareto duration objective.

## Narrative and flow

### Strengths

The paper now has a coherent main argument:

1. separate the low-state Gaussian limitation into temporal and marginal channels;
2. show empirically that the fitted SPY ACF is effectively one-mode at small `K`;
3. compare emission families as the main remaining lever;
4. validate the family across rolling windows and tickers;
5. exercise the Gaussian member's filter-conditional risk head;
6. state where static fitting fails.

Table 3 is especially valuable because it prevents the reader from mistaking results from Gaussian, shared-`nu`, and penalized per-state Student-t configurations as one model.

### Remaining flow problems

The abstract is approximately **312 words** and tries to carry almost every caveat and result. It is accurate in intent but difficult to parse. Target roughly **180–220 words** with this order:

1. problem and two-channel hypothesis;
2. method and spectral diagnostic;
3. one SPY result;
4. generator/risk result with exact configurations;
5. principal limitation.

The introduction's first and third paragraphs are similarly dense. The narrative will improve if baseline qualifications are left in Related Work and the introduction preserves only the problem, gap, contribution, and headline finding.

The results section is broad but now manageable. If further compression is needed, the Hill subsection is the least central to the conference story. The main acceptance case rests on the spectral diagnosis, generator comparison, validation, and VaR.

## Mechanical and rendered-PDF audit

Current checks:

- PDF builds successfully;
- exactly **8 pages**, including references;
- ACM `sigconf` with `anonymous` is used;
- anonymization scan is clean;
- no undefined citations or references;
- four minor overfull boxes, maximum `4.37 pt`;
- one unused bibliography entry: `diebold1995comparing`;
- no clipping, overlap, missing glyphs, or broken figure rendering was found.

The full-width Figure 1 is now legible. Page 8 is only partly occupied by references, leaving layout margin for the small compliance additions below.

### ACM warnings to resolve

The class emits:

1. **“ACM reference format is mandatory”** because `printacmref=false` is set;
2. **possible image without description** because Figure 1 has no `\Description{...}`.

ICAIF requires the latest ACM template. Set `printacmref=true` unless the conference chairs explicitly instruct otherwise, and add a concise `\Description{...}` after the figure caption. The current half-empty final page should accommodate the ACM reference block without exceeding eight pages, but recompile to confirm.

## Recommended revision order

### Before submission

1. Fix `96.8% at K = 3` versus `93.6% at K = 18` in the abstract.
2. Add `tau >= 1` to the ACF identity.
3. Change the family-wide parameter range from `12–15` to `12–17`, or restrict it to the two headline variants.
4. Replace the CRPS significance claim with numerical-closeness language, or report the exact test for the displayed rows.
5. Rewrite the conclusion's Baum–Welch, regime-interpretability, and state-selection sentences.
6. Restore the ACM reference-format block and add figure alternative text.
7. Remove the unused Diebold–Mariano entry if it remains uncited.

### Strong polish

8. Cut the abstract to 180–220 words.
9. Use “captures the three diagnostics” instead of implying exact heavy-tail reproduction.
10. Label the cross-ticker spectral row explicitly as CHMM-N at `K = 18`.
11. If retaining the QuantGAN size comparison, report the implemented architecture's exact parameter count rather than only “orders of magnitude.”
12. Run `make clean && make && make check` and visually inspect all eight final pages.

## Bottom line

**Submit to ICAIF '26 after this focused correction pass.** The paper's topic is squarely in scope, its empirical artifacts largely support the displayed values, and the current configuration map resolves the most serious coherence problem from the earlier draft. The remaining issues are reviewer-visible but readily correctable without rerunning the main study.

The most accurate one-line positioning is:

> An interpretable probabilistic generator for daily equity scenarios that diagnoses the separate temporal and marginal limits of low-state HMMs and evaluates a filter-conditional risk head under walk-forward and cross-ticker validation.
