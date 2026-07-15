# CHMM — ICAIF '26 Conference Submission

8-page conference version of the CHMM equity-returns paper, condensed for the
**7th ACM International Conference on AI in Finance (ICAIF '26)**, Milan,
November 14–17, 2026.

- **Deadline:** August 2, 2026 (AoE), via CMT: <https://cmt3.research.microsoft.com/ICAIF2026/>
- **Format:** max **8 pages total** (figures + references included), ACM `sigconf`, double-blind.
- **Story:** interpretable 12-parameter synthetic generator for daily equity
  returns (vs QuantGAN/bootstrap), unified heavy-tail-emission EM framework,
  spectral two-channel diagnostic, regime-conditional VaR as validation head.
  The multi-asset copula head is future/companion work here.
- **Source of truth for content:** the sibling `CHMM-Paper-Repository`
  (extended working paper). All numbers here were copied verbatim from its
  `sections/results.tex` / `discussion.tex`. Do not retype numbers — copy them.

## Build

```sh
make          # latexmk -pdf main.tex
make check    # page limit, undefined refs, checkcites, anonymization greps, overfull boxes
make clean
```

Requires TeX Live with `acmart` (built against TeX Live 2025), `latexmk`,
`pdfinfo` (poppler), `checkcites`.

## Submission rules encoded here

- `\documentclass[sigconf,anonymous]{acmart}` — do not remove `anonymous`
  before acceptance.
- **No supplementary material** is accepted; the paper must be self-contained.
- **arXiv preprints must not be cited** during review — the extended arXiv
  version and the discrete-state predecessor preprint are deliberately
  uncited. Restore at camera-ready only.
- Self-citations in third person only.

## Camera-ready TODOs (post-acceptance only)

- [ ] Remove `anonymous` option; restore real author block (marked
  `%% CAMERA-READY` in `main.tex`).
- [ ] Restore citation of the extended arXiv version and the data-availability
  statement with repository URLs.
- [ ] Fill real `\acmDOI` / `\acmISBN` from the rights form; ORCIDs for all
  authors.
- [ ] Confirm one author registered for in-person presentation in Milan.

**Keep this repository private until the submission decision.**
