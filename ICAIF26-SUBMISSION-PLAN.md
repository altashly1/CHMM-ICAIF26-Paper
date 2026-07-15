# Plan: CHMM-ICAIF26-Paper — 8-page ICAIF '26 submission repo

## Context

The 76-page CHMM working paper (arXiv:2606.23492, thesis Paper II) is to be condensed into a conference submission for **ICAIF '26** (7th ACM Int'l Conference on AI in Finance, Milan, Nov 14–17). Fit was assessed with devil's-advocate scrutiny and confirmed viable: the CFP's first methodology topic is "Generative AI, simulation, and synthetic data generation," plus "AI-driven risk management" and "validation and calibration of financial models," and ICAIF has a track record of regime-switching/statistical papers. Main risks: ML-leaning reviewers dismissing an HMM as non-novel, and the paper's own honest baselines (bootstrap/HSMM win raw KS) reading as weakness under skim — so the condensed paper must lead with what only the CHMM delivers.

**Decisions:** synthetic-generator story (interpretable 12-parameter generator vs QuantGAN/bootstrap, spectral two-channel diagnostic, regime-conditional VaR as validation head; copula head demoted to future work); paper is arXiv-only (no exclusivity conflict); new **sibling repo**, source repo untouched.

## Hard constraints (verified from https://icaif2026.org/call-for-papers.html, 2026-07-14)

- **Deadline Aug 2, 2026 AoE** (19 days). Notification Sept 27. Submit PDF via CMT (cmt3.research.microsoft.com/ICAIF2026).
- **Max 8 pages TOTAL** incl. figures and references; two-column `\documentclass[sigconf,anonymous]{acmart}` (acmart already installed in TeX Live 2025).
- **Double-blind**; **no supplementary material accepted**; **arXiv preprints must not be cited during review** → drop `alswaidan2026hybrid` and any cite of the extended version; no "extended version" pointer until camera-ready; every "see appendix" reference must become an in-text number or be deleted.
- At least one author must attend in person; ORCID required on acceptance.

## New repo layout

`/Users/abdulrahmanalswaidan/Desktop/Project-Repos/CHMM-ICAIF26-Paper/`

```
main.tex                 # acmart shell: topmatter, abstract, \input chain, bib
sections/01-introduction.tex … 07-conclusion.tex   (7 files)
figs/                    # ONLY Fig-1-Stylized-Facts-a.pdf and -d.pdf (copied)
references.bib           # fresh ~30-entry file, entries copied verbatim
Makefile                 # build + `check` target (page count, anonymization greps)
README.md                # build notes, camera-ready TODOs; repo stays private
.gitignore               # aux files + main.pdf
```

Everything **copied**, nothing symlinked; no `results/` CSVs needed (all tables hand-typeset). `git init`, commit skeleton first, then commit per section.

## main.tex preamble

- `\documentclass[sigconf,anonymous]{acmart}`; `\acmConference[ICAIF '26]{...}{November 14--17, 2026}{Milan, Italy}`; placeholder `Anonymous Author(s)` (real block in a `%% CAMERA-READY` comment).
- CCS: Machine learning → Latent variable models; Applied computing → Economics; Time series analysis. Keywords: synthetic data generation; hidden Markov models; heavy-tailed distributions; regime switching; Value-at-Risk.
- Drop from source preamble: `geometry`, `authblk`, `natbib`/`hyperref` loading (acmart provides), `amsthm` theorem defs, algorithm packages, tikz (architecture figure is cut), and especially the source `hypersetup{pdfauthor=...}`. Keep `booktabs` + the numeric macros (`\pct`, `\Kdisc`, `\LRuc`, `\TIS`, `\TOoS`).
- `\bibliographystyle{ACM-Reference-Format}`.

## Condensation map (~5.4k words of prose available; source body ~10.7k → cut ~50%)

| Target | Source | Budget | Key survival rules |
|---|---|---|---|
| Abstract | paper.tex abstract | 150–180 w | Generator-story lead; keep one-sentence honesty clause (bootstrap/HSMM match raw fit) + scope clause |
| 1 Intro | introduction.tex | ~0.85 p | Rydén/Bulla two-channel framing intact; add QuantGAN/interpretability positioning (from discussion.tex ¶4); drop CRSP + six-asset from setting list; drop `alswaidan2026hybrid` cite |
| 2 Related | related_work.tex | ~0.45 p | 4 paragraphs → 2–3 sentences each; deep-generator paragraph gains prominence; copula paragraph → ≤1 sentence |
| 3 Model + EM | methods.tex (model, estimation) | ~1.1 p | Keep eq. for growth rate, model tuple/mixture, Student-t ECM updates (heart of unified-framework claim); other M-steps 1 sentence each; monotonicity caveat survives as 1 sentence; **cut TikZ architecture figure** |
| 4 Spectral diagnostic | theory.tex | ~0.35 p | Nearly intact incl. λ₂=0.94 empirics + both scope sentences; assumptions stated inline |
| 5 Setup | methods.tex (evaluation) | ~0.45 p | SPY IS/OoS + 30-ticker panel + baselines list + 3 primary metrics + KS-caveat sentence; cut CRSP, six-asset, copula machinery |
| 6 Results | results.tex | ~2.4 p (incl. 2 tables) | Sub-budgets: stylized facts/K-selection/spectral ~400 w; generator comparison ~550 w around Table 1 (**bootstrap/HSMM paragraph survives with exact logic**: they win raw OoS KS but sit at ACF-MAE floor 0.063 vs 0.0462 and cannot serve regime-conditional VaR); tail index ~200 w (table → prose); cross-ticker + refit ~250 w; VaR ~450 w around Table 2 (non-rejection language verbatim style). **Cut as subsections: copula (→3-sentence mention w/ cross-sectional-only caveat), CRSP, GLD, kurtosis-bootstrap/K-selection/leverage tables** |
| 7 Limitations + Conclusion | discussion.tex + conclusion.tex merged | ~0.5 p | Two-channel verdict; audit-hardened kurtosis sentence (ML fit doesn't select high-kurtosis mixture; lacks power-law tail — never "cannot reach kurtosis 7"); Rydén reconciliation (2 sentences); scope/refit; 12-vs-342-parameter closer; copula lands in future work. Delete CoI/Contributions/Data-Availability blocks; one anonymized code-release sentence instead |
| References | references.bib | ~0.9 p | ~30 entries (e.g. cont2001empirical, ryden1998stylized, bulla2006stylized, hamilton1989new, peel2000robust, liu1995ml, wiese2020quantgan, yoon2019timegan, takahashi2019modeling, kupiec1995techniques, christoffersen1998evaluating, engle2004caviar, ardia2019msgarch, assefa2020generating, cappe2011online, …). `checkcites` for zero unused |

**Figures/tables kept (only these):**
1. **Fig 1**: two panels — `Fig-1-Stylized-Facts-a.pdf` (marginal density) + `-d.pdf` (|G| ACF) — literally the two channels of the thesis. New ~40-word caption.
2. **Table 1** = `tab:model_comparison` trimmed to 11 rows (Observed, Bootstrap, GARCH-N/t, MS-GARCH K=3, QuantGAN, CHMM-N/L/GED/t-shared, HSMM-N), all 6 columns, `\footnotesize`; caption cut to ~50 w. **Copy table bodies verbatim then delete rows — never retype numbers.**
3. **Table 2** = `tab:cond_var` trimmed to 10 rows (CHMM-N K=3/K=18 × both α, filtered bootstrap ×2, CAViaR ×2), columns {Family, K, α, breaches, rate, p_cc, p_DQ}.

## Anonymization checklist

- No real authors/emails/Cornell; no varnerlab URL or commit `8f92968`; no CRSP-license phrasing (CRSP experiment is cut); no arXiv IDs `2606.23492`/`2603.10202`.
- Check the 2 figure PDFs for identifying metadata (`strings`/`exiftool`); strip via `qpdf`/`gs` if needed.
- Greps (source AND `pdftotext` AND `strings main.pdf`): `Alswaidan|Cade Jin|Varner|Cornell|varnerlab|aa2725|cj383|jdv27|altashly|8f92968|2606\.23492|2603\.10202|CHMM-Model-Repository`.

## Verification (Makefile `check` target)

1. `latexmk -pdf main.tex` builds clean
2. Page count ≤ 8 (`pdfinfo`)
3. No undefined citations/references in log; `checkcites` clean
4. Anonymization greps empty
5. PDF Author metadata empty
6. No overfull boxes >5pt
7. **Number audit**: every retained numeric vs source results.tex/discussion.tex, plus overclaim greps (`passed the|passes the` in VaR context; any "Gaussian mixture cannot" kurtosis phrasing) checked against `audit-results-update.md` and `CHMM-TECHNICAL-REVIEW-2026-07-14-RERUN.md`.

## Milestones (deadline Aug 2 AoE)

- **Jul 14–15**: scaffold repo, compiling acmart stub, trimmed bib, figs copied, Makefile.
- **Jul 16–19**: first-pass draft of all sections + both tables (≤10 pages OK).
- **Jul 20–23**: cut to 8.0 pages; abstract rewrite; resolve all appendix pointers.
- **Jul 24–26**: number/framing audit; register submission early in CMT.
- **Jul 27–29**: co-author review + anonymization verification on near-final PDF.
- **Jul 30–31**: polish, final `make check`.
- **Aug 1**: submit; tag `icaif26-submitted`.

**Over-length contingency (in cut order):** drop Table 2's K=18 rows (keep DQ result in prose) → drop Fig 1 panel (a) → refs 30→25 → Related Work to 0.3 p.

## Critical source files

- `sections/results.tex` (both tables + all headline numbers)
- `sections/methods.tex` (model/EM + evaluation setup)
- `sections/introduction.tex` (intro basis; contains the two uncitable arXiv self-cites)
- `sections/discussion.tex` (audit-hardened sentences that must survive)
- `references.bib` (verbatim source for trimmed entries)
- `audit-results-update.md`, `CHMM-TECHNICAL-REVIEW-2026-07-14-RERUN.md` (overclaim guardrails)
