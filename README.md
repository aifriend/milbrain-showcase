# milbrain — reproducing & extending the Thousand Brains cortical model

A research showcase: an independent, verified reproduction of **Monty** (the
[Thousand Brains Project](https://github.com/thousandbrainsproject/tbp.monty)'s sensorimotor
implementation of the neocortex), and a proposal to **grow** its architecture with an indirect
developmental encoding instead of hand-designing it.

**▶ Live interactive dashboard:** https://aifriend.github.io/milbrain-showcase/
*(learned 3D reference-frame models · step-by-step evidence accumulation · per-object results · the N=5 variance study)*

> **What this is and isn't.** This is a *functional* model of the cortical algorithm — reference
> frames, sensorimotor learning, voting columns — **not** a biophysical simulation of neurons or
> spikes. It reproduces the Thousand Brains Project's Monty; all credit for Monty and the theory is
> theirs. This repo is an independent showcase (theory, results, figures) — the implementation code
> lives in a separate private repository.

---

## The result: an exact reproduction

On the `randrot_noise_10distinctobj` benchmark — 10 YCB objects, each under random 3-axis rotation
with sensor noise — the reproduction matches the documented benchmark **exactly**, and not just on
one number:

| Metric | Documented (Monty v0.42.0) | This reproduction |
|---|---|---|
| Recognition accuracy (official metric) | **100.00%** | **100%** |
| Mean match-steps | 30 | **30** |
| Mean rotation (pose) error | 12.85° | **≈12.9°** |
| Misrecognitions (5 seeds × 100 episodes) | — | **0 / 500** |
| Strict-convergence accuracy (5 seeds) | — | 99.2% ± 1.17 |

Three independent quantities agreeing (accuracy, match-steps, pose error) is far stronger evidence
than a single accuracy figure. A **multi-learning-module (5-LM) architecture** was also run
end-to-end — all five columns active and voting, 100% recognition.

*Every number here was verified against the raw benchmark table, not a summary — see the
reproduction record.*

## Growing the architecture — results so far

The reproduction is the baseline; the actual research is whether the architecture can be **grown**
instead of hand-designed. Two experiments are in, both pre-registered and reported honestly:

- **Evolving the *voting topology*** on the fixed 5-column model → a **pre-registered inconclusive
  result**. On the shipped tasks we can claim neither that voting topology matters nor that it doesn't
  (10-object is ceiling-saturated; 77-object is noise-limited even at 10 seeds). The one real,
  tool-grounded finding is a *zero-mean* effect — a sparse tree helps on some object poses and hurts on
  others, cancelling in the mean. [Full write-up →](results/evolving-topology.md)

- **Evolving the *column count*** → a **first, under-powered *positive*.** A grown **three-column**
  cortex is statistically **accuracy-equivalent** to the hand-designed five-column model on 77-object
  recognition (paired TOST, ±2 pt, Holm-corrected, *p* = 0.012) while using **≈36 % of the compute** —
  denied a registered *pass* only because it needs ~4 % more integration steps, not on any accuracy
  deficit. Accuracy is conserved from 2 to 5 columns; what changes is *how* the recognition is paid for
  (parallel voting vs. serial integration time). Not yet "grown beats designed" — but the first evidence
  that the designed column count is load-bearing for *latency*, not *accuracy*.
  [Full write-up →](results/growing-columns.md)

**→ [Where this points next — the finding in the neuroscience literature](theory/directions-from-the-frontier.md)**

## What you can explore

- **[▶ Interactive dashboard](https://aifriend.github.io/milbrain-showcase/)** — the learned 3D
  reference-frame object models (rotatable), evidence accumulating over sensorimotor steps as the
  correct object overtakes its competitors, the per-object recognition grid, and the variance study.
- **[Theory — a neocortex research landscape](theory/neocortex-research-landscape.md)** — ten
  sub-fields of cortical neuroscience (cortical columns and their skeptics, the canonical
  microcircuit, dendritic computation, predictive coding, grid cells, the Thousand Brains Theory,
  development, connectomics, large-scale simulation, NeuroAI), with ~84 citation-verified references.
- **[The research plan](theory/research-plan.md)** — falsifiable hypotheses, method
  (ES-HyperNEAT / CPPN developmental encoding), experimental protocol, and go/kill gates for
  *growing* the architecture.
- **[Reproduction record](results/reproduction.md)** — the results, and an honest correction (an
  early "95%" reference turned out to be a fetch-summary error; the real documented figure is 100%).
- **[Evolution results — voting topology](results/evolving-topology.md)** — the first
  grow-the-architecture experiment: a pre-registered inconclusive result, the one real zero-mean pose
  interaction found, and the analysis-bug caught by adversarial review.
- **[Evolution results — growing the column count](results/growing-columns.md)** — the first
  accuracy-vs-compute frontier point: grown-3 ≈ designed-5 in accuracy at ~⅓ the compute, under-powered
  for a dominance claim, with the completeness guard and analyzer re-verification that back the number.
- **[Directions from the frontier](theory/directions-from-the-frontier.md)** — the grown-columns
  finding read against the neuroscience literature (cortical redundancy & degeneracy, efficient/sparse
  coding, the speed–accuracy tradeoff, developmental encoding), and the best next experiments
  (*algorithm-level*: the capabilities the system lacks).
- **[Directions at the implementation level](theory/directions-implementation-level.md)** — a companion
  assessing biophysical-realism ideas (dendritic units, bio-plausible backprop, neuromodulation, the
  genomic bottleneck): which add capability to a *functional* model and which are realism for a sister
  project — plus a fact-check of two recent-research claims.
- **[ALIFE 2026 abstract](paper/alife2026-abstract.md)** — the work-in-progress writeup.

## The idea, in one paragraph

The Thousand Brains Theory casts the neocortex as thousands of near-identical cortical columns, each
learning object models in reference frames and voting to a consensus. Monty realizes this — but its
*architecture* (how many learning modules, how they connect, the voting topology) is entirely
hand-designed. Biological cortex, by contrast, is **grown** by local developmental rules. This
project asks whether an indirect developmental encoding can *grow* the Thousand-Brains architecture,
and whether grown structure matches or beats the hand-designed one. An adversarial literature search
(July 2026) found this intersection — evolutionary/developmental encoding × reference-frame cortical
models — **unoccupied**.

## Credit & license

Monty and the Thousand Brains Theory are the work of the **Thousand Brains Project** (formerly
Numenta), released under the MIT License. This repository is an independent reproduction and
research proposal, not affiliated with or endorsed by them. Written content and figures here are
licensed **CC BY 4.0** (see [LICENSE](LICENSE)).
