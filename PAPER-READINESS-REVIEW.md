# Paper Readiness Review — Eighth Audit (2026-07-15)

**Paper:** *Heavy-Tail Hidden Markov Generators for Daily Equity Returns: Stylized Facts and Filter-Conditional Value-at-Risk* — ICAIF '26 submission (`main.pdf`, 8 pages including references)

**Scope of this audit:** technical accuracy (every quoted number cross-checked against stored artifacts in `Thesis/CHMM-Model-Repository/` and `Thesis/CHMM-Paper-Repository/`), methodology-vs-code consistency (Julia implementation read directly), correctness of the statistics, narrative flow, and ICAIF format/anonymity compliance.

---

> **Status update (same day):** F1, F2, and F3 below have been applied to the sources (`sections/06-results.tex`, plus an in-sample scoping clause in `sections/07-conclusion.tex`), the paper recompiled, and all submission gates re-run: 8 pages, 0 undefined references, anonymization clean, no new overfull boxes. **The paper is now fit for submission.**

## Executive verdict

**Fit for submission after three small corrections — not strictly "as is."** *(Corrections since applied; see status note above.)*

The paper is in outstanding shape after seven audit rounds: **every table cell in all three tables verifies exactly against its stored artifact**, all 17 methodology descriptions match the implementation line-for-line, the format/anonymity/bibliography checks are fully clean, and the narrative is coherent and honestly scoped. However, this audit found **one claim-level statement that the stored artifacts contradict** (finding F1), plus one wrong numeric interval (F2) and one configuration misattribution (F3). All three are one-sentence fixes with no layout risk, but F1 in particular would be caught by any referee or reproducer with the released code, and it currently overstates the model in the paper's favor. Fix F1–F3 and the paper is ready.

---

## 1. Findings requiring correction

### F1 (claim-level, must fix): "stored OoS values preserve the ranking" is contradicted by the stored OoS values

Section 6.2 (`sections/06-results.tex:11`):

> "ACF-MAE is scored on the IS window, and stored OoS values preserve the ranking, e.g. 0.0544 for CHMM-N"

The stored OoS `|G_t|` ACF-MAE column (`CHMM-Model-Repository/results/SPY/Table-2-Full.txt`; same values in `CHMM-Paper-Repository/results/robustness/kstar3_headline.csv`) is:

| Model | IS ACF-MAE (paper Table 1) | OoS ACF-MAE (stored) |
|---|---|---|
| CHMM-L | 0.0530 | **0.0498** |
| CHMM-GED | 0.0531 | 0.0501 |
| CHMM-t shared-ν | 0.0531 | 0.0502 |
| Bootstrap (i.i.d. floor) | 0.0628 | 0.0542 |
| CHMM-N | **0.0462** | 0.0544 |
| Gaussian i.i.d. | 0.0627 | 0.0546 |
| GARCH(1,1) | 0.0490 | 0.0593 |

The ranking is **not** preserved out of sample: CHMM-N flips from best CHMM row to worst, and — more importantly — its headline volatility-clustering advantage over the i.i.d. floor (0.0462 vs 0.0628, cited three times: §6.2, §6.2 last para, §7) vanishes OoS, where CHMM-N (0.0544) sits *at* the bootstrap floor (0.0542). Only the narrow CHMM-N-vs-GARCH pair ordering survives (0.0544 < 0.0593).

The IS-scoping of the table itself is honest and disclosed; the false statement is precisely the parenthetical asserting OoS rank preservation. **Fix options:** (a) narrow the claim to what holds — "the CHMM-N-vs-GARCH ordering also holds on the stored OoS values (0.0544 vs 0.0593)"; or (b) disclose the flip — the OoS window (T = 572, low-volatility 2024–2026) has a much flatter observed ACF, so the clustering axis is an IS-window result. Option (b) is more robust, since a referee running the released code will see the full column.

### F2 (numeric, must fix): the α = 0.01 Christoffersen interval "[0.10, 0.16]" matches no row set

Section 6.5 (`sections/06-results.tex:83`): "The α = 0.01 rows are also not rejected by Christoffersen-cc ($p_{\text{cc}} \in [0.10, 0.16]$)".

From `CHMM-Model-Repository/results/conditional_var_all_families/conditional_var_panel.csv`:
- Table 3's α = 0.01 rows: CHMM-N 0.137/0.137, filtered bootstrap 0.163, CAViaR 0.136 → **[0.14, 0.16]** (CHMM rows alone: [0.14, 0.14]).
- The full sixteen-row family panel at α = 0.01: range **[0.089, 0.388]** (CHMM-L K=3 at 0.089, CHMM-L K=18 at 0.388) — so [0.10, 0.16] is not that set either, and 0.089 falls below the stated floor.

The substantive claim (no α = 0.01 cc rejection) holds on every row. Replace the interval with [0.14, 0.16] (or [0.14, 0.14] if the sentence is meant to scope to CHMM rows only, matching the α = 0.05 sentence's convention).

### F3 (attribution, should fix): the sector ANOVA was computed on the K = 18 panel, inside a subsection scoped to K = 3

Section 6.4 opens by stating that "the panel claims in this subsection therefore attach to that configuration" (penalised CHMM-t, K★ = 3, λ = 20), then reports the ANOVA. But both ANOVA artifacts are K = 18 runs:
- `results/sector_panel/anova_oos_ks.txt` sources `sector_panel_summary.csv` — the **K = 18** panel (grand mean 66.84%, vs the K = 3 panel's 66.2%).
- `results/sector_panel_n6/sector_panel_n6.txt` header: "penalised CHMM-t at **K = 18**, λ = 20" (60 tickers).

The no-sector-effect conclusion is supported (F(9,20) = 0.436, p = 0.899; n = 6: F(9,50) = 0.366, p = 0.946), and the two panels' OoS KS distributions are very similar, but the sentence as written attributes the test to a configuration it was not run on — exactly the kind of slippage §6.6 exists to prevent. Fix: add "(computed on the K = 18 panel)" or rerun the ANOVA on the K = 3 panel values (all inputs are on file).

---

## 2. Verified-correct: technical accuracy

Everything below was checked against artifacts and **matches**, at the stated rounding:

- **Table 1 (generator comparison)** — all 11 rows × 6 columns exact vs `kstar3_headline.csv`, `table2_baselines.csv`, `garch_suite.csv`, `quantgan_tcn.csv`, `hsmm_ml_metrics.csv`, `Table-2-Full.txt`. The "–" cells are genuine (the sourced GARCH-t/MS-GARCH runs store no OoS kurtosis).
- **Table 2 (configuration map)** — every key value verified: ν = 5.81 (5.8076), fold KS 63.2/7.2/82.4/0.8/78.4/61.0 median 62.1 (`walkforward_summary.csv`), panel 69.1 [51.4, 91.9] 11/30 → 84.7 [56.3, 94.5] 8/30 (`sector_panel_summary_k3.txt`, `sector_panel_quarterly_refit.txt`), kurt residual +7.18 [0.34, 21.19], BIC/CAIC 7745/7757, 7848/7890, 9903/10245 with both criteria minimized at K = 3, held-out log-liks −1.793/−1.767, −1.800/−1.740, −2.061/−1.964 with the 0.007/0.027 sign flip, dominant shares 1.000/0.968/0.936, panel median 0.726 IQR [0.583, 0.809] min 0.287 (NEM) n95 median 7 max 13.
- **Table 3 (VaR backtest)** — all 8 rows exact (breaches, rates, p_cc, p_DQ) vs `conditional_var_panel.csv`, `engle_manganelli_dq_all_families.csv` (4-lag confirmed), `filtered_bootstrap_var.csv`, `caviar_var.csv`. Walk-forward 19/24 with exactly the five claimed rejections (4×W2 + W4/K18/α.01). Sixteen-row DQ rejection range 0.0005–0.030 ✓. 573 = 572 + boundary return confirmed in runner code. Kupiec/Christoffersen-ind non-rejections at α = 0.05 ✓.
- **Prose metrics** — observed kurtosis 7.68/5.29; block-bootstrap CIs [2.17, 12.40]/[0.90, 8.26] (L = 20 row); condition numbers 1.4/7.3; CRPS 1.0393/1.0398/1.0406/1.0432/1.0398/1.0440; Hill 3.15/3.30, CI [2.45, 4.25], shared-ν 3.67 band [3.11, 4.38], families 3.41/3.26/3.24, asymmetry sign recovered; Wasserstein ordering 0.193/0.236/0.252/0.264/0.286/0.355/0.368 with AD/Hellinger behaving as claimed (one L/N Hellinger tie); K = 2 replication 79.0%/0.0501/λ₂ = 0.942 & 0.95; regime parameters (0.29, 0.85), (0.14, 1.91), (−0.43, 3.98); penalised-t 18.87 with λ tuned at K = 18; feed-switch KS D = 0.099 p = 0.13, D = 0.065 p = 0.59, breach split 17/250 vs 19/323; GLD static breakdown (OoS KS 0.0%) and refit non-repair (2.5% after quarterly refit).
- **Spectral diagnostic** — the runner implements exactly the paper's definition (max_k |a_k λ_k| / Σ|a_k λ_k| over non-unit eigenvalues, complex modulus, conjugate-pair members counted separately); SPY control 0.936 reproduced in the cross-ticker run.

## 3. Verified-correct: methodology vs code

All 17 checked descriptions match the implementation (`CHMM-Model-Repository/src/Compute.jl`, runners): log-space forward–backward with logsumexp in all four fitters; the prior fallback correctly attributed to the *filters* (it lives in the VaR predictive filters, not the EM recursions — the paper's wording gets this right); quantile initialization with uniform T⁽⁰⁾/π⁽⁰⁾; Gaussian π fixed-uniform & excluded from counts vs t/L/GED updating π ← γ₁; parameter counts 12 = K(K−1)+2K and 15 = 12+1+(K−1) consistent with code conventions; tol 1e-4 + iteration cap; O(K²T); the Student-t σ² denominator **Σγ (not Σγu) — the paper states the implemented variant faithfully**; shared-ν golden-section on [2.1, 50] over the aggregate Q(ν); penalty −λ/ν active only at λ = 20; restore-last-finite-iterate safeguard present in t and GED fitters; Laplace weighted-median/MAD closed form; GED three-block CM updates with p-bounds (0.5, 3.0) making p = 1, 2 interior; 1,000 paths, fixed seeds (20260420), stationary-distribution initialization; growth-rate definition with Δt = 1/252, r_f = 0, VWAP column; VaR head = filter under IS-fixed parameters with bisection mixture quantile; ACF-MAE and KS pass-rate metrics as defined.

The paper's caveat that monotone ascent is *not* guaranteed for the t/GED fitters is the correct (safer) claim — note the GED docstring in the code asserts the opposite and should be cleaned up before release (repo issue, not a paper issue).

## 4. Format, anonymity, bibliography — all clean

- Exactly 8 pages including references; final page balanced (`pbalance`); no undefined or multiply-defined references in `main.log`. Two sub-5pt overfull boxes (4.4pt and 2.2pt, in the model/setup sections) pre-date this round and are invisible in print; the Makefile `boxes` gate is informational and does not fail on them.
- All 30 cited keys resolve; zero uncited bib entries; key claims' citations (Rydén et al. 1998, Bulla & Bulla 2006, Cont 2001, Liu & Rubin 1995, Peel & McLachlan 2000) are used accurately, including the Rydén winsorisation point.
- Anonymization: no author-identifying strings in the sources; PDF metadata carries only the acmart producer string and "Anonymous Author(s)". CCS concepts, keywords, ACM reference block present; conference metadata (Milan, Nov 14–17 2026) correct.
- Figure 1 renders correctly with an accurate caption and `\Description` (accessibility requirement met).

## 5. Narrative flow assessment

The structure is logical and the argument connects: negative result → two-channel decomposition → spectral identity → which channel binds → risk head as the payoff. The configuration map (Table 2 + §6.6) is a genuine strength — it preempts the "which model got which result" objection that multi-configuration papers usually attract. Scope limits and hedges are honest and, for this venue, appropriate.

Non-blocking observations, in descending order of value:

1. **The abstract is very long (~340 words) and carries body-level qualifications** ("Evaluating one configuration at a time", the HSMM-risk-head disclaimer, the panel-vs-SPY spectral split). It is accurate but exhausting; trimming to ~220 words by moving the configuration-by-configuration detail to §6.6 would improve first impressions without losing a defensible claim. Optional — the current abstract is safe, just dense.
2. **Hedging density in §6.2–§6.5** is high (nearly every result sentence carries a qualifier). Most hedges are load-bearing; a few are duplicated (e.g., the KS-not-calibrated-under-dependence point appears in §5 and again in §6.5's "non-rejection ≠ demonstration"). Could be consolidated, but this is taste, not correctness.
3. **HSMM-N naming**: the paper's description of the duration update (untruncated-Pareto α̂ formula on a truncated support, hence "moment-updated rather than maximum-likelihood") matches the sourced runner exactly. Be aware the repo also contains a *different* HSMM benchmark (`run_hsmm_gamma.jl`, method-of-moments Gamma sojourn, materially different numbers) and the sourced runner currently lives in `_attic/runners/run_hsmm_ml.jl` — before the promised code release, move it out of `_attic/` and name it so reproducers find the right one.
4. **Figure 1 left panel** y-axis label "Probability Density (AU)": densities have units of 1/x, so "(AU)" is unusual; harmless, but "(density)" or dropping the parenthetical would be cleaner if the figure is ever regenerated. Not worth a regeneration on its own.

## 6. Minor notes for the record (no action required for submission)

- Observed OoS excess kurtosis: the paper and `Table-2-Full.txt` say 5.29; `kurtosis_bootstrap.txt` (the source of the quoted CI) says 5.323 — a small cross-artifact inconsistency, likely a 572-vs-573-observation window difference. The CI endpoints quoted are exact.
- §6.1 says the K sweep is {3, 6, 9, 12, 15, 18, 21}; the artifact also includes K = 2, and the cross-validation grids omit 15 and 21. The paper's CV statements only concern K ∈ {3, 6, 18}, so nothing quoted is affected.
- MS-GARCH ACF-MAE 0.02845 is printed as 0.0284 (round-half-even; defensible).
- "IEX feed carrying roughly 2.5% of consolidated volume" (§5) has no artifact or citation behind it — it is a well-known market-structure figure, but a citation (e.g., IEX market-share statistics) would immunize it.
- "tickers that introduced a new regime out of sample" (§6.4, LLY/UNH/NEM) is interpretive — the failure identities and depths are on file, the regime-introduction mechanism is not. The sentence reads as observation, which is acceptable; a stored regime-trajectory diagnostic would make it verifiable.
- A `crps_dm` artifact records CHMM-N CRPS = 1.0412 under a different protocol from the headline 1.0393; the paper's number matches its sourced protocol. Reproducers may trip on this — a line in the release README would help.
- A different full-path GARCH-t run (`garch_suite/GARCHt_Full_Metrics.txt`) does store an OoS kurtosis (5.75); the table's "–" is true of the sourced run. If a referee asks, the number exists.
- No runner script for the QuantGAN TCN row was found in either repo (only the smaller `run_quantgan_baseline.jl`); the "materially smaller approximation" characterization is qualitatively supported but parameter counts are stored nowhere. Ensure the TCN runner is included in the code release.
- Stationary distribution computed by power iteration (T¹⁰⁰⁰) rather than a linear solve — same fixed point for the ergodic chains fitted here; fine.

---

## Bottom line

Seven audit rounds have left a paper whose numbers are, with the exceptions above, perfectly reproducible from its artifacts and whose methodology text is a faithful description of the code — an unusually strong position for referee scrutiny. Apply F1 (rewrite one parenthetical about OoS ACF-MAE ranking), F2 (correct one p-value interval), and F3 (one attribution clause for the ANOVA), recompile, confirm the page count stays at 8, and submit.
