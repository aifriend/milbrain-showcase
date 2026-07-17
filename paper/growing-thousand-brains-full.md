# Growing the Thousand-Brains Architecture: Column Count Is Not the Accuracy Lever — Error Correlation Is

**Jose B. López** · *[affiliation — TODO]* · *[email — TODO]*
*Interactive results, learned models & data:* <https://aifriend.github.io/milbrain-showcase/>

*Draft full paper. Companion to the ALIFE 2026 abstract ([`alife2026-abstract.md`](alife2026-abstract.md)),
which proposed the approach; this reports the results.*

## Abstract

The Thousand Brains Theory (TBT) models the neocortex as many near-identical cortical columns that each
learn objects in reference frames and vote to a consensus. Its open-source implementation, Monty, is
**hand-designed**: the number of columns, their sensor mapping, and the voting topology are set by a person.
We asked whether a *grown* architecture — more columns, evolved topology — matches or beats the hand-designed
one on embodied object recognition, and built a genome→configuration→run pipeline to test it. Across a
pre-registered, adversarially-verified experimental program we find a clean **negative result with a
mechanism**: on static object recognition, accuracy is **flat from two to five columns** (≈89.4%), and the
reason is measurable — the columns make their errors on the *same* objects (inter-column error correlation
φ≈0.75). Adding near-identical columns buys redundancy, not accuracy; the hand-designed column count is
load-bearing for *latency*, not *accuracy*. A grown three-column model is statistically accuracy-equivalent
to the designed five-column model at ~⅓ the compute. The natural remedy — decorrelate the columns by
spreading their sensory patches — proves geometrically self-defeating: any spread wide enough to decorrelate
the median object pushes the patch off the small objects. The lever for capability is column **diversity**,
not **count** — a concrete, falsifiable refinement of "more columns, more robust," and a caution for anyone
scaling brain-like ensembles. We contribute the result, the reproduction and grow-the-architecture
infrastructure, and a verification methodology that repeatedly caught verdict-flipping analysis errors before
they became claims.

## 1. Introduction

TBT recasts the neocortex as thousands of cortical columns, each a full sensorimotor learner that models
objects in its own reference frame and reaches agreement with the others by voting (Hawkins et al., 2019;
Lewis et al., 2019). Monty (Thousand Brains Project, 2024; Leadholm et al., 2025) realizes this as sensor
modules feeding *learning modules* (LMs) that exchange messages and vote. By explicit project principle, the
architecture — LM count, sensor→LM mapping, LM↔LM voting graph — is **hand-designed and hand-iterated**.

This mirrors developmental neuroscience: biological cortex is *grown* by local rules, not wired from a
blueprint. It raises a question that, to our knowledge (an adversarial literature search, July 2026), sits in
an unoccupied intersection of mature indirect-encoding neuroevolution (Stanley, 2007; Risi & Stanley, 2012;
Najarro et al., 2023) and reference-frame cortical models: **can a developmental encoding grow the TBT
architecture, and does grown structure beat the designed one?** We set out to grow it. What we found instead
is a prior question that the growing programme has to answer first — *does the architecture axis buy accuracy
at all?* — and a clear answer: on this task, no, and for a specific, measurable reason.

## 2. Related work

*Indirect / developmental encoding:* CPPNs (Stanley, 2007) and ES-HyperNEAT (Risi & Stanley, 2012) evolve the
placement and connectivity of units as a function of geometry; neural developmental programs (Najarro et al.,
2023) grow networks by local rules; quality-diversity search (Mouret & Clune, 2015) illuminates the space of
good architectures rather than returning one optimum. *Reference-frame cortical models:* Monty operationalizes
TBT as an evaluable sensorimotor system. These traditions have not met — indirect encoding has not been
applied to grow a Thousand-Brains architecture — which is the gap the infrastructure here opens, and the
negative result below sharpens.

## 3. Methods

**Reproduction and substrate.** We independently reproduced Monty's sensorimotor benchmark in a containerized,
natively-built environment and closed a **genome→configuration→run** loop: a decoder maps a compact
architecture genome (module count, connectivity, voting topology) onto Monty's coupled configuration groups,
generates the matching pretrained model, and executes it. On `randrot_noise_10distinctobj` (10 YCB objects,
random 3-axis rotation, sensor noise) the reproduction matches the documented **100%** recognition, corroborated
by mean match-steps (30 vs 30) and pose error (≈13° vs 12.85°) over five seeds — zero misrecognitions in 500
episodes.

**Experiments.** (E0) evolve the voting topology on the fixed 5-LM model; (E1) vary the column count *N* ∈
{2,3,4,5} on the 77-object task (`eval_77obj_random`, the non-saturated benchmark), all arms pretrained
identically (77 objects × 14 rotations), 8 seeds × 77 episodes, paired on shared episodes; (Phase 0) re-analyze
E1's per-episode, per-column outcomes for inter-column error correlation; and a decorrelation pilot that widens
the sensory-patch geometry.

**Discipline (a first-class contribution).** Every experiment fixed its metric, equivalence margin,
multiplicity correction, and decision rule **before** the data. Accuracy is Monty's official priority-max
per-episode rule; equivalence is a paired-by-seed *t* with **TOST** at a ±2-point margin, **Holm-corrected**
across arms. Analyzers carry a **completeness guard** (no verdict on partial data) and were **adversarially
re-verified** before their outputs were trusted — an independent multi-lens review of the verdict logic, run
*before* spending compute or making claims. This repeatedly paid for itself (§4.4).

## 4. Results

### 4.1 Voting topology does not resolvably matter (E0)

Evolving the LM↔LM voting topology on the fixed five-column model yielded a **pre-registered inconclusive**
result on both shipped tasks: the 10-object task is ceiling-saturated, and the 77-object task is noise-limited
even at ten seeds. The one tool-grounded finding is a *zero-mean* effect — a sparse tree helps on some object
poses and hurts on others, cancelling in the mean. Topology is not resolvably accuracy-limiting here.

### 4.2 Grown ≈ designed on accuracy, at a fraction of the compute (E1)

| architecture | accuracy | Δ vs designed (95% CI) | Holm-TOST (±2 pt) | compute | integration steps |
|---|---|---|---|---|---|
| designed 5 | 89.4 % | — | — | 100 % | 31.2 |
| grown 2 | 89.6 % | +0.16 [−4.64, +4.96] | 0.261 | **15 %** | 32.7 (+4.8 %) |
| **grown 3** | 89.4 % | +0.00 [−1.30, +1.30] | **0.012** | **36 %** | 32.5 (+4.2 %) |
| grown 4 | 89.6 % | +0.16 [−3.39, +3.71] | 0.261 | **62 %** | 31.1 (−0.3 %) |

Every grown arm lands on the designed model's accuracy within noise (per-episode discordances balanced,
*b*≈*c*≈35). **Grown-3 formally established equivalence** (Holm-TOST *p*=0.012, CI inside ±2 pt) at 36% of the
designed compute, denied a registered *pass* only by a wall-clock guard (~4% more integration steps). The
study-level verdict is honestly **under-powered** for a dominance claim — and because voting cost is O(*N*²),
"cheaper" for smaller *N* is near-automatic, so *equal accuracy*, not cost, is the interesting claim. Accuracy
is conserved across the range; what moves is *how* the recognition is paid for (parallel voting vs. serial
integration steps).

### 4.3 Why accuracy is flat: the correlation bottleneck (Phase 0)

Re-analyzing the same data (no new compute), we measured the correlation of the columns' *errors* across
episodes.

| *N* | single-column acc | error correlation φ | Yule Q | P(all wrong) | oracle ceiling | actual acc |
|---|---|---|---|---|---|---|
| 2 | 88.5 % | 0.798 | 0.990 | 9.7 % | 90.3 % | 89.6 % |
| 3 | 87.0 % | 0.746 | 0.977 | 9.4 % | 90.6 % | 89.4 % |
| 4 | 87.5 % | 0.754 | 0.978 | 8.6 % | 91.4 % | 89.6 % |
| 5 | 88.1 % | 0.753 | 0.981 | 7.3 % | 92.7 % | 89.4 % |

The columns' errors are correlated at **φ≈0.75** (Yule Q≈0.98, near the marginal maximum). Consequently the
fraction of episodes where *every* column fails sits at the single-column error rate (~7–10%), rather than the
<1.5% independence would give — **when these columns are wrong, they are wrong together.** The oracle ceiling
(best any voting scheme could reach) rises only ~0.6 pt per column, and realized accuracy is flat. Three
checks keep this honest: (i) the oracle gap is *clairvoyant* — no realizable fusion rule (most-confident,
plurality, evidence-weighted) beats the current rule by >±0.5 pt, so it is correlation, not the vote rule,
that is the wall; (ii) the shared errors are only ~25% object-intrinsic (the all-wrong object set overlaps
Jaccard≈0.25 between a 2- and 5-column model, ≈6.5× chance but far from 1) — so most of the shared-error mass
is decorrelatable in principle, just small on a near-ceiling task; (iii) grown-3's wall-clock reservation is
not statistically robust (paired *p*≈0.43). **The bottleneck is inter-column error correlation, not column
count.**

### 4.4 Decorrelation is geometrically hard (pilot)

If correlation is the bottleneck, decorrelate the columns. The cheapest lever is geometric: the columns'
sensory patches sit on a ring spanning ~7% of a typical object, so they nearly coincide; widen it. A
fail-fast pilot showed this is self-defeating: a ring wide enough to decorrelate the *median* object pushes
the patch off the *small* objects (a die, marbles), where it observes too few points to build an object model
and pretraining fails outright. Because objects span a ~10× size range, **no single global patch-spread is
both on-object for all objects and decorrelating.** Decorrelation must instead use levers that keep the patch
centered (per-column spatial scale, feature channels) or scale geometry per object — a research programme, not
a configuration change. (En route, the pilot surfaced a latent Monty crash on sparse patches, reported
upstream.)

### 4.5 The methodology repeatedly mattered

The verification discipline was not ceremony. Adversarial review of the E0 analyzer caught three
verdict-flipping bugs (a false-null bootstrap, a wrong metric unit, an unused multiplicity correction) before
any claim; independent bug-hunting of the E1 gate caught two more that would have produced a false PASS on
partial data; the completeness guard fired for real, rejecting an incomplete data pull; and the fail-fast
decorrelation pilot cost ~$2 to learn that a ~$40 experiment grid would hit a wall. No infrastructure failure
(a preemption, a resource stall) ever produced a *wrong* number — each surfaced as an honest incomplete.

## 5. Discussion

**Count vs. diversity.** The headline is a sharpening of TBT intuition. "More columns, more robust" holds only
to the extent the columns' errors are *decorrelated*; here they are near-duplicates and their failures
co-occur, so more of them add redundancy, not capability. The lever for accuracy is column **diversity**, not
**quantity** — a testable claim, and one that connects directly to redundancy/efficient-coding accounts of
cortex, where robustness is attributed to *diverse* columns, not merely many.

**The task is the ceiling.** Static recognition of rigid objects saturates near 89–100%, leaving little
headroom for any architectural change to register — which is *why* nothing moves, and is itself informative.
It relocates the interesting question from "how many columns?" to capabilities the static task cannot measure:
planning and acting on a world whose state the agent changes, compositional multi-object scenes, abstraction
over non-spatial concept spaces. That is where a grown/diverse architecture could plausibly pay, and it is the
direction this work points.

**For scaling brain-like ensembles generally.** Measure inter-module error correlation before scaling. A high
value means each added unit is redundancy; an ensemble's real capacity is set by how independent its members'
failures are, not by their number.

## 6. Limitations

One model family (Monty v0.42.0), one near-ceiling task, and — for the grown-vs-designed frontier — an
under-powered eight-seed design that certifies equivalence only for grown-3. The correlation φ is
task-specific; a higher-error regime (occlusion, heavier noise, harder objects) could lower it, and is exactly
where decorrelation could pay. The decorrelation pilot tested only the geometric (patch-spread) lever; the
scale/feature levers remain open. These are the natural next experiments, not caveats that undercut the floor
established here.

## 7. Conclusion

We set out to grow the Thousand-Brains architecture and found, first, that the architecture *count* axis does
not buy accuracy on static recognition — and, crucially, *why*: the columns fail together (φ≈0.75), so the
lever is diversity, not quantity, and the simplest way to create diversity is geometrically blocked. This is a
clean, verified, mechanistic negative — more useful than a marginal positive — delivered with a methodology
that caught its own errors before they became claims. The grow-the-architecture programme continues, but
redirected: toward making columns *fail differently*, and toward capabilities a saturated recognition task
cannot see.

## References

- Hawkins, J., Lewis, M., Klukas, M., Purdy, S., & Ahmad, S. (2019). A Framework for Intelligence and Cortical Function Based on Grid Cells in the Neocortex. *Frontiers in Neural Circuits*.
- Lewis, M., Purdy, S., Ahmad, S., & Hawkins, J. (2019). Locations in the Neocortex. *Frontiers in Neural Circuits*.
- Thousand Brains Project (2024). The Thousand Brains Project. *arXiv:2412.18354*.
- Leadholm, N., Clay, V., Knudstrup, S., Lee, H., & Hawkins, J. (2025). Thousand-Brains Systems. *arXiv:2507.04494*; *Neural Computation* 38(6).
- Stanley, K. O. (2007). Compositional Pattern Producing Networks. *Genetic Programming and Evolvable Machines*.
- Risi, S., & Stanley, K. O. (2012). ES-HyperNEAT. *Artificial Life*.
- Najarro, E., Sudhakaran, S., & Risi, S. (2023). Neural Developmental Programs. *arXiv:2307.08197*.
- Mouret, J.-B., & Clune, J. (2015). Illuminating Search Spaces by Mapping Elites. *arXiv:1504.04909*.
