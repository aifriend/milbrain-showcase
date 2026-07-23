# Growing the column count — the first accuracy-vs-compute frontier point

> **⚠️ Correction, applied throughout this page (2026-07-23).** The three-column model was a **generated
> configuration, not the product of a search** — the evolutionary genome cannot represent a 3-column model
> at all (`SHIPPED_LMS = (1, 5)`) — and its connectivity has since been measured to be no better than
> random. **The measurements below stand; the word *grown* does not.** This is a *configuration* result.
> Full reasoning in the section *"Follow-up (2026-07-23) — the connectivity was tested, and it is no better
> than random"* below.

[E0](evolving-topology.md) held the number of cortical columns fixed at five and evolved only the
*voting topology* between them — and found no resolvable effect on the shipped tasks. **E1 lets the
column count itself vary.** This is the comparison the [research plan](../theory/research-plan.md) was
built toward: *does a smaller-column architecture match the hand-designed five-column model — and at what
compute?*

This page reports the first real frontier point. **The headline is a genuine (if under-powered)
positive: a generated three-column cortex is statistically equivalent in accuracy to the designed
five-column one while using roughly a third of the compute** — and the one thing that keeps it from a
clean "pass" is not accuracy at all, but a few percent more integration steps.

---

## The setup (pre-registered)

- **Arms.** Grown *N* ∈ {2, 3, 4} columns versus the designed *N* = 5 reference. The generated 5-column
  configuration is round-trip-identical to Monty's shipped one, so "designed 5" is a faithful baseline.
- **Task.** 77-object recognition (`eval_77obj_random`) — the full YCB object set under random rotation
  with sensor noise. This is the **non-ceiling** task; the 10-object task saturates at ~100% and cannot
  separate architectures.
- **Training.** Every arm is pretrained **identically** by the generator (77 objects × 14 rotations) —
  no arm gets a training advantage; only the column count differs.
- **Design.** 8 random seeds × 77 episodes, paired on shared episodes (the same object/rotation draws
  across arms, which removes the dominant nuisance variance).
- **Metric.** Accuracy is Monty's official **priority-max** per-episode rule. The accuracy comparison is
  a paired-by-seed *t* with **TOST equivalence** at a ±2-point margin, **Holm-corrected** across the
  three grown arms (family-wise error control). Compute is `compute_total` = per-column match
  invocations + all-to-all voting cost (directed edges × integration steps); a separate **wall-clock
  guard** watches mean integration steps so a matching-count win that costs more steps isn't miscounted
  as an efficiency win.
- **Decision rule.** A grown *N* **passes** iff it clears Holm-TOST equivalence (or Holm superiority)
  **and** is cheaper on `compute_total` **and** is not worse on wall-clock steps. All of this was fixed
  before the run.

## The result

| architecture | accuracy | Δ vs designed (95% CI) | Holm-TOST (±2 pt) | `compute_total` | integration steps | verdict |
|---|---|---|---|---|---|---|
| **designed 5** | 89.4 % | — | — | 719 | 31.2 | reference |
| grown 2 | 89.6 % | +0.16 [−4.64, +4.96] | 0.261 | 109 (**15 %**) | 32.7 (+4.8 %) | under-powered *(+ slower)* |
| **grown 3** | 89.4 % | +0.00 [−1.30, +1.30] | **0.012** | 255 (**36 %**) | 32.5 (+4.2 %) | under-powered *(+ slower)* |
| grown 4 | 89.6 % | +0.16 [−3.39, +3.71] | 0.261 | 449 (**62 %**) | 31.1 (−0.3 %) | under-powered |

Every grown architecture lands on the designed model's 89.4 % accuracy, within noise — the disagreements
between arms are almost perfectly balanced (per-episode discordances *b* ≈ *c* ≈ 35 on each comparison,
i.e. each architecture wins about as many episodes as it loses). **Grown-3 is the one arm that formally
established equivalence**: its accuracy difference from designed-5 is +0.00 points with a 95 % CI of
[−1.30, +1.30] — entirely inside the ±2-point band — at a Holm-corrected TOST *p* = 0.012, using **36 %
of the designed model's compute**. It was denied a pre-registered *pass* only by the wall-clock guard: it
takes ~4 % more integration steps per episode, just over the 1.02× tolerance.

That trade is the honest shape of the frontier: **fewer columns buy a large reduction in voting compute
(which scales with the square of the column count) at the price of a small increase in the number of
sensorimotor steps needed to accumulate the same evidence.** Accuracy is conserved across the whole
range; what moves is *how the same recognition is paid for* — in parallel voting versus serial
integration time.

## What it does and does not say

- **It does not say "grown beats designed."** The registered study-level verdict is **under-powered**.
  Because voting cost is O(*N*²), a smaller *N* being "cheaper" is nearly automatic — so *cheaper* is not
  the interesting claim. The interesting claim is **equal accuracy**, and only grown-3 cleared the
  equivalence bar under family-wise correction. Grown-2 and grown-4 are cheaper-and-not-worse but too
  seed-noisy (wide CIs) to certify as equivalent from eight seeds.
- **A "dominance" claim would need confirmation on fresh seeds** (a winner's-curse guard), and ideally a
  compute accounting that is not voting-dominated by construction (per-step FLOPs / node-count-matched
  graphs), so the wall-clock cost of the extra integration steps is priced in honestly.
- **What it *does* establish** is a real, quantified point on the accuracy-per-compute curve where a
  grown architecture is not paying an accuracy penalty for being smaller — the first evidence that the
  hand-designed column count is not, on this task, load-bearing for *accuracy*, only for *latency*.

---

## Follow-up (2026-07-23) — the connectivity was tested, and it is no better than random

The result above varies the column **count** while holding the voting **topology** fixed at all-to-all.
That left an obvious question unasked: was the connectivity itself doing any work? A pre-registered sweep
answered it — fixed *N* = 3, varying **only** the vote matrix, 56 evaluations on the same 77-object task,
8 seeds per arm, zero failures.

**There is no motif.** Designed sparse topologies were compared against **random matrices at the same edge
count** — the control that separates *"this particular wiring is good"* from *"fewer connections is
cheaper"*. Both designed arms came out **slightly below** their random equivalents (−1.30 and −1.14
points, neither significant). A vote matrix drawn at random works as well as a hand-designed hub or ring.

Without those random arms this would have looked like a discovery: the 3-edge ring is accuracy-equivalent
to the designed 5-column model at 38% less compute. It is simply a consequence of having fewer edges.

**The unexpected half is more interesting.** Removing voting *entirely* — three columns that never
exchange a message — costs essentially **nothing in accuracy** (it scored 1.5 points *higher*, within
noise) but takes **2.5× as many integration steps** to get there (20.2 → 51.2 matching steps; 32.5 → 80.3
system steps). And **three edges recover the whole benefit**: a 3-edge ring is indistinguishable from a
fully-connected 6-edge model on both step measures. It is a **cliff at zero, not a gradient** — *any*
connectivity buys nearly all of it.

So the finding on this page extends one level down. The designed column **count** is load-bearing for
latency rather than accuracy; so are the voting **connections**. Both are what an inter-column error
correlation of φ ≈ 0.75 predicts: columns that already fail on the same episodes cannot correct one
another, they can only reach agreement faster.

One honest caveat kept from the analysis: pooling across columns at readout *does* recover episodes a
single column misses (worth ~0.5–1.9 points in every arm, including the one with no voting at all). So
the claim is **not** "voting buys nothing" — it is that *explicit message-passing* adds nothing to accuracy
beyond that pooling.

**And a correction this forces on the language above.** "Evolving the column count" overstates what
happened twice over: the three-column model was a *generated configuration*, not the product of a search
(the evolutionary genome cannot represent a 3-column model at all), and the connectivity it used is now
measured to be no better than random. The measurements stand; the word *evolving* does not. This page's
results are a **configuration** result, not a growth result.

## The methodology is, again, the point

Consistent with the [E0 close-out](evolving-topology.md#the-methodology-is-the-real-win-so-far) and the
[reproduction's honest corrections](reproduction.md):

- **Pre-registration.** Arms, metric, equivalence bound, multiplicity correction, and the pass/fail rule
  were fixed before the data. The under-powered verdict could not be re-spun into a "win" after the fact.
- **A completeness guard that refuses to score partial data.** The analyzer will not return a verdict
  unless every arm has all its seeds and every seed its full 77 episodes — so a truncated or partially
  failed run yields an honest *incomplete*, never a false equivalence. It fired for real during
  analysis, rejecting an incomplete data pull before it could contaminate the result.
- **Adversarial re-verification of the verdict logic.** An independent multi-lens review of the analyzer
  — run *before* trusting its output — found two ways it could have manufactured a false "equivalent":
  a missing absolute-episode floor (a symmetric partial run scored as if complete) and a degenerate
  zero-variance equivalence test. Both were fixed and locked with known-answer tests; the verdict above
  is from the corrected analyzer, re-run on checksum-verified data rather than trusting the run's own
  in-situ output.
- **It took three attempts to get clean data.** The compute itself was unglamorous — a preempted machine,
  then a parallelism-induced resource stall that lost a run's eval phase — but no failure ever produced a
  *wrong* number: each one surfaced as an honest incomplete, the trained models were always preserved,
  and the eventual verdict runs on fully-verified episode counts.

---

*Status: a first, pre-registered, **under-powered positive** — grown-3 is accuracy-equivalent to
designed-5 at ~⅓ the compute, short of a registered pass only on integration-step latency. Not yet a
dominance result; that needs fresh-seed confirmation and a latency-honest compute model. **Why accuracy is
flat from 2 to 5 columns is answered next — the columns fail on the same objects (error correlation
φ ≈ 0.75): [the correlation bottleneck](correlation-bottleneck.md).** Where this points next — and how it
connects to cortical redundancy, efficient coding, and the speed–accuracy tradeoff in the neuroscience
literature — is taken up in [the directions report](../theory/directions-from-the-frontier.md). Full
experimental detail and the analysis live in the private implementation repository.*
