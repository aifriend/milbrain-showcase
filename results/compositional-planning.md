# Structure, not count — object-factored models buy compositional planning

The [correlation bottleneck](correlation-bottleneck.md) closed the recognition arc with a negative: on static
object recognition, column **count** buys nothing, because the columns fail together. That page ended by
relocating the question — to capabilities a saturated recognition task cannot measure, chief among them
*acting on a world the agent changes*.

This page reports what happened when the programme followed that pointer. The result is the first **positive**
architectural finding in this project, and it is about a different axis than the one that failed:

> **Column *count* bought nothing for perception. Object-factored *structure* buys compositional planning —
> transfer to novel arrangements that a monolithic learner cannot match even with ten times the data.**

It comes with a caveat that three separate experiments tried and failed to remove, and those failures turn out
to be the more interesting half of the story: they locate the binding constraint not in the learner, but in the
**world**.

---

## The setting

A 2D quasi-static tabletop world: an agent pushes a rigid object toward a target pose, one discrete push at a
time, with a static obstacle in the scene. Two model families compete, and the comparison is deliberately
stacked to be fair — **same planner, same object-relative features, same data budget**:

- **Factored** — one model per object, storing push → displacement *in that object's own reference frame*
  (so it is rotation-equivariant by construction), plus a rule for composing an object with an obstacle.
- **Monolithic** — the same features and planner, but one model that must learn the *joint* interaction
  (object + obstacle together) from experience.

Everything below was gated: each rung's pass/fail criteria were written down and committed to version control
**before** the model was fitted, so a failed prediction could not be quietly re-described as a success. Three
of the six rungs failed, and are reported as failures.

## Getting to a task where planning is actually required

A planning result is only meaningful if the task genuinely needs planning — and the honest first finding was
that it did not. In free space, a *greedy* one-step policy solved the push-to-pose task outright (100%), so a
learned model driving multi-step lookahead would have been solving a problem that did not exist.

Adding an obstacle did not fix it either. Across obstacle sizes, lookahead never beat greedy: the task passed
straight from "greedy solves it" to "nothing solves it," with no regime in between. The mechanism is a
horizon-vs-geometry mismatch — a push moves ~4 cm, so a three-step lookahead sees ~12 cm ahead, while a wall
big enough to create a local minimum needs a detour far longer than that to escape. By the time the trap
exists, it is already deeper than the planner can see.

What unlocked it was an asymmetry that favours the factored model on its merits: it predicts **analytically**,
in tens of microseconds, where a physics rollout costs ~0.3 ms. Long horizons are therefore affordable to the
structured model and essentially not to the simulator (a horizon-12 plan step would cost the oracle ~216
seconds). With a proper long-horizon planner:

| planner | success |
|---|---|
| greedy (1-step) | 16.7 % |
| **long-horizon (12-step)** | **50.0 %** |

**+33 points — a regime where planning is both required and achievable.** That is the precondition the
decisive test needed, and the structure is what paid for it.

## The decisive test

With the regime established, the two families were compared on **transfer to novel arrangements**. The
train/test split is on the *target's orientation offset* relative to the route — chosen deliberately, because
splitting on world bearing would have been vacuous: the monolith's inputs are target-relative, so that
distribution is identical across bands and it would "transfer" for free. This split instead moves the obstacle
into an unseen part of the model's own input space.

| model (n = 30 per cell) | familiar arrangements | **novel arrangements** |
|---|---|---|
| **factored** (per-object model + composition rule) | **53.3 %** | **50.0 %** |
| monolithic (same features, same planner, same data) | 10.0 % | 3.3 % |
| **monolithic with 10× the data** | 3.3 % | 6.7 % |
| greedy (context) | 3.3 % | — |

The factored model **transfers** — 50% on novel arrangements against 53% on familiar ones, a difference well
inside noise — while the monolithic learner collapses to near-zero. And the arm that exists to pre-empt the
obvious objection does its job: **ten times the data does not rescue the monolith.** The deficit is
**structural, not data starvation**, which is the strongest form the claim can take.

## What this does *not* show

The factored model's transfer is substantially **by construction**: its per-object table is orientation-
invariant, and its composition rule is exact geometry. That is the point — an inductive bias is *supposed* to
be by construction — but it means the informative content is narrower than "structure wins." It is:
*the monolithic alternative, given the same features, the same planner, and ten times the data, cannot recover
what the structure supplies for free.*

Three further caveats stated plainly: the composition rule is **hand-given, not learned**; the monolithic arm
is one function class (data starvation is ruled out, a different function class is not); and at n = 30 the
binomial confidence interval is ±18 points — wide enough that the 53-vs-50 transfer gap is noise (which is what
"transfers" means here), though far too narrow to explain the 50-vs-3 gap.

## Three attempts to learn the composition rule — all failed

The hand-given composition rule is the load-bearing caveat, so the programme attacked it directly, three times,
with three different representations. Each failed, and each failure was diagnosed to a mechanism rather than
filed as "didn't work."

**1. Learn the blocking boundary directly.** A learned classifier predicting "is this push blocked?" reached
**75.7% per-step agreement** with the exact rule — which sounds respectable and is catastrophic. Long-horizon
planning compounds per-step error geometrically: at 76% per step, a ten-step imagined rollout is fully correct
about **6%** of the time. The planner confidently imagines routes straight *through* solid matter, executes
them, and reality stops it. The bar is set by the horizon, and it is brutal — usable long-horizon composition
needs per-step accuracy well above 95%.

**2. Learn the obstacle's shape instead.** Rather than learn the abstract blocking boundary, learn the
obstacle's occupancy in its own reference frame by *carving*: a successful push proves the swept region was
empty. One structural bet paid off cleanly — an obstacle model built purely from free-space experience
**never once hallucinated a route through solid matter** (0.00% false-free at every data volume), which is the
fatal direction to be wrong in. But the estimate **got worse with more experience**: overlap with the true
shape fell from 0.50 to 0.29 as data grew fourfold. The mechanism is that carving is **monotone** — a region
once marked free is never unmarked — so under noisy dynamics every additional push is another chance to punch a
*permanent* hole. Errors accumulate irreversibly instead of averaging out. (The classical fix — probabilistic
occupancy with revisable, log-odds evidence — is named and untried.)

**3. Attack the ceiling itself.** Every arm above shares a crude contact schema: *overlap ⇒ the object stops*.
That is wrong physics — real contact **slides** an object along an obstacle — so the hand-given rule was a
ceiling nothing could beat, and a learned continuous contact model should have raised it. Instead it predicted
contact **worse than simply saying "it stops"** (error 0.043 vs 0.026), and tripling the training data moved
that error by **0.0001**. So this was not sparsity. The measured reason is the finding: within a single small
cell of relative pose, *even at a fixed action*, contact outcomes spread by **±2.6 cm** — the scale of an entire
push — and the crude schema's error is **2.6 cm**. They are the same number. "It stops" is already sitting on
the noise floor; the predictable part of contact here is just *"you don't get far,"* which the crude schema
already encodes.

*(One prediction made in advance was confirmed on the way: because poses *inside* an obstacle are never
observed, a learned model has no evidence there, predicts free motion, and a planner that rewards
best-position-anywhere will creep straight through solid matter — measured at 10–13% of imagined plans. Pricing
that ignorance explicitly cut it to ~1%.)*

## The real conclusion: the world is the constraint, not the learner

Put the failures together and they close like a pincer:

- **What the task demands.** Planning only exists in this world at a horizon of ~12 steps, and compounding
  means that horizon demands roughly **95% per-step** model validity to keep a plan coherent.
- **What the world permits.** Learned models here cap out at **76–85%** per step, with their errors in the
  fatal direction — and the contact measurement shows the residual is not predictable *at all* at the
  resolution the data supports, because the variability is intrinsic to the contact, not a deficiency of the
  model.

The bar the task sets sits above the ceiling the world allows. That gap is not closed by a better learner, and
recognising this is what makes the three failures informative rather than merely discouraging: **the honest
next move is a world whose contact is more predictable, or whose tasks demand a shorter horizon — not a fourth
attempt at learning composition in this one.**

There is a pleasing symmetry with the recognition result. There, the ceiling was set by a statistic of the
*data* (columns whose errors are correlated at φ ≈ 0.75). Here, it is set by a statistic of the *physics*
(contact whose variability equals the signal). In both arcs, the thing that stopped progress was a property of
the environment, measurable in advance — which is a cheap check worth running before buying a bigger model.

## Why it matters

- **For the Thousand Brains thesis.** This is the first result in this project where brain-like architecture
  earns its keep. Object-centred reference frames — the theory's core commitment — are not merely a tidy way to
  store perception; they make *planning* transfer to arrangements never seen, where an equally-informed
  monolithic model fails. Reference frames pay off in **action**, on the axis the static recognition task was
  structurally unable to test.
- **For model-based planning generally.** Derive your per-step accuracy target *from* your horizon before
  blaming the planner: at horizon 12, a "90% accurate" model is already unusable. And errors in the fatal
  direction (predicting free where the world is blocked) matter far more than average error — a metric that
  averages over both will hide exactly the failure that kills you.
- **Honest limits.** One object, one obstacle configuration, one training seed, n = 30 per cell (±18 pt), in a
  2D quasi-static world. The composition rule is supplied, not discovered. What is established is a
  well-measured *inductive-bias* result plus a well-measured *impossibility* in this specific world — not a
  general law about learned composition, which remains open in settings with more predictable contact.

---

*Status: a **positive structural result with a load-bearing caveat**, plus three pre-registered negatives that
locate the caveat's cause in the environment rather than the model. The programme's live question moves from
"can we learn the composition rule here?" — measured, and no — to "what world makes compositional structure
both necessary and learnable?", with the world itself now a pre-registered choice rather than an assumption.
Full experimental detail, the gates as they were committed, and the analysis code live in the private
implementation repository.*
