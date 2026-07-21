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
is one function class — data starvation was ruled out, and a different function class **has since been ruled
out too** (see below); and the table above is
a single configuration at n = 30, a ±18 point confidence interval — far too narrow to explain the 50-vs-3 gap,
but not by itself evidence that the result survives other conditions. The next section tests exactly that.

## Does it replicate? And does it extend to an object never seen?

A single favourable configuration is the standard way a result like this turns out to be nothing. So the same
contrast was re-run across **three objects × three obstacle sizes × three seeds** — 27 independent
configurations, with the decision rule fixed and published before any model was fitted.

| | result |
|---|---|
| configurations where the factored advantage held (≥20 pt) | **16 of 16** where the task is solvable at all |
| median advantage | **+47.9 points** |
| factored vs monolithic on novel arrangements | **54.4% vs 8.1%** |
| *same figures counting **every** configuration, including unsolvable ones* | *81.5%, median +29.2 pt* |

That last line is the one that matters. Eleven of the 27 configurations sit outside the planning regime
entirely — the obstacle is large enough that nothing solves the task — and they were excluded by a criterion
fixed in advance. But even counting them, the effect still holds in over four-fifths of configurations. **The
exclusion is not doing the work.** The original result was not a favourable-configuration artifact.

The sweep also mapped where planning is possible at all: the regime shrinks as the obstacle grows (at the
smallest obstacle 9 of 9 configurations are solvable, at the largest only 1 of 9), which incidentally shows the
originally-reported setting sat in the middle of the range rather than at its easy end.

**And the new object.** Object-factored structure makes a specific prediction that a monolithic model cannot:
a *new* object should need only its own free-space model, inheriting the composition rule unchanged, with **no
observation of it interacting with anything**. Tested by training interaction knowledge on one object and
handing the planner two objects it had never encountered:

| model, planning with a new object | success |
|---|---|
| factored, on its original training object (reference) | 41.7 % |
| **factored, new object, zero interaction data** | **28.5 %** |
| factored, new object, free-space model from only 500 pushes | 28.5 % |
| monolithic, applied to the new object | 4.2 % |
| monolithic, refit on the same free-space data | 1.4 % |
| **monolithic, *given* full interaction data on the new object** | **4.2 %** |

The prediction holds: the factored model plans for an object it has never seen interact with anything, beating
every monolithic arm in all six configurations — including one **handed** the interaction data it lacked. And
a free-space model from 500 pushes does as well as one from 2500, so the data it *does* need is genuinely
cheap.

Two honesty notes. This pass is **marginal**: the drop from 41.7% to 28.5% is 13.2 points against a
pre-registered tolerance of 15, and three of the six individual configurations exceed that tolerance on their
own. The rule was fixed in advance and is not being moved now that the numbers exist. Second, the factored
model is given the new object's **shape**, which its composition rule needs — defensible, because in the full
system that shape is exactly what the recognition side produces, but it is an architectural assumption rather
than something learned here.

### Was the monolith just a weak learner?

The obvious objection to all of this is that the monolithic model was a nearest-neighbour learner — perhaps
the deficit says more about that choice than about monolithic models. That objection has now been tested
directly, by re-running the decisive comparison unchanged except for the monolith's model: a two-layer neural
network, same features, same data, same planner, across 15 evaluable configurations.

| monolith's model | its success on novel arrangements | factored's advantage |
|---|---|---|
| nearest-neighbour (as originally reported) | 8.6 % | **+48.1 pt** (15/15 configurations) |
| **neural network** | 8.1 % | **+48.6 pt** (15/15 configurations) |

The gap does not move (−0.6 pt, *t* = −0.31). **The monolith's deficit is structural, not an artifact of its
function class** — which converts a caveat we had flagged as untested into a tested one.

One honest boundary. In a *separate* setting that trains on a better-conditioned distribution — balanced, and
drawn from the planner's own states rather than random exploration — a neural monolith improves markedly,
recovering roughly half the ground between an interaction-blind model and the factored one. So the data
*distribution* buys something that sheer data volume did not. It still leaves the monolith well short, and it
does not touch the comparison above, which holds distribution fixed. But it means "a better learner cannot
help at all" would be the wrong lesson to take from this.

### One correction this forced

Across all 27 configurations the monolithic model never exceeded 12.5% **in either band** — familiar
arrangements included — and the version handed interaction data on a new object reached only 4.2%. So the
tidy story "the monolith learns the familiar case and then fails to generalize" is **not what the data shows**.
It never worked anywhere. The accurate claim is narrower and blunter:

> Object-factored structure solves this task where a monolithic learner cannot do it at all.

That does not weaken the headline — the factored model's novel-arrangement success and the failure of 10× data
to close the gap both stand, now across 27 configurations instead of one — but the mechanism is different from
the intuitive one, and reporting the intuitive version would have been wrong.

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
- **Honest limits.** Three objects, three obstacle sizes, three seeds — 27 configurations, so no longer a
  single-setting result, but still a 2D quasi-static world with one obstacle at a time and 24 episodes per
  cell. The composition rule is supplied, not discovered, and the factored model is given object geometry. The
  new-object result is a marginal pass whose mean hides real per-configuration spread. What is established is
  a replicated *inductive-bias* result plus a well-measured *impossibility* in this specific world — not a
  general law about learned composition, which remains open in settings with more predictable contact.
  Multi-object scenes (three or more) remain untested.

---

## Epilogue — we followed that pointer, and it did not lead anywhere yet

The page above ends by relocating the question to a choice of *world*. That search has since run, and the
honest report is that it failed — in ways worth writing down.

**Seven environment designs were screened against criteria fixed in advance. None could host the question.**
Each failed differently: contact too unpredictable, the rule never encountered, the task solvable without
learning anything, the planning horizon too long for any learner to keep a plan coherent.

Three things did survive, and they are the reason the exercise was not wasted.

**Interaction-forcing is a property of density.** How often the interaction actually decides an outcome tracks
how crowded the environment is, not how the task is described. Predicted in advance from one world's rejection,
then confirmed by changing *only* occupancy in another: the rule went from deciding 1% of moments to 36%.

**Some worlds can never teach their own rule.** Where constraints are about *ordering* — do this before that —
an agent that respects them never encounters a violation. The evidence a learner would need appears exactly
0% of the time in the experience of an agent competent enough to generate it. Such an environment can look
ideal on every other measure and still be unable to teach the thing it is built around.

**A world can pass every check and still be trivial.** One design cleared the non-triviality test by ninety
points and was then found to be solved *perfectly* by a one-line rule that learns nothing — sorting parts by
distance and placing the nearest first. Every result measured in it was withdrawn. The check had asked whether
*ignoring* the interaction hurt; it never asked whether some trivial *positive* strategy just worked.

**And the question the search was meant to settle is still open.** Two attempts to determine whether the
required properties can hold simultaneously both failed, and in both the *measuring instrument* produced the
verdict rather than the environment: first a horizon probe that stopped counting below the true value, so
every world read identically; then a fix that constrained the horizon directly, which guaranteed the answer
before the run began. **We are not claiming the properties are jointly unsatisfiable.** We are reporting that
we could not build an instrument able to decide it, which is a different and less satisfying statement.

The search is paused rather than concluded. What it produced is a method — measure the environment before
investing in a model, test a trivial strategy before believing a learned one, and decide in advance what a
broken measurement would look like — and the finding that this is harder to do correctly than it appears.

---

*Status: a **positive structural result with a load-bearing caveat**, plus three pre-registered negatives that
locate the caveat's cause in the environment rather than the model. The programme's live question moves from
"can we learn the composition rule here?" — measured, and no — to "what world makes compositional structure
both necessary and learnable?", with the world itself now a pre-registered choice rather than an assumption.
Full experimental detail, the gates as they were committed, and the analysis code live in the private
implementation repository.*
