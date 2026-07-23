# Verifying four implementation-level claims — what survived, and what it cost to find out

*A companion to [directions at the implementation level](directions-implementation-level.md), which is an
**ideation** document. This one is a **verification** document, and the distinction is the point. Four
claims about how to evolve this project arrived as a confident, well-written AI-generated synthesis. Each
was checked against primary sources by four adversarial research passes (~420 agents, refute-by-default:
a claim survived only if independent verifiers **failed** to kill it). Two survived in altered form, one was
refuted, one was unsupported and partly inverted.*

> **A note on fairness, up front.** Every paper named below is real, and most of it is good work whose
> authors hedge appropriately in their own text. The inflation was in the *synthesis*, not in the research.
> Where a paper is quoted conceding a limitation, that is the authors being careful — and it is usually the
> sentence the synthesis dropped.

---

## The headline

**The failure mode was not fabrication. It was inflation of real work.** Three of four terminology claims
pointed at genuine peer-reviewed papers. What was wrong were the properties attached to them and, above
all, the *scale* implied.

Our own prior was that the terms were confabulated. That prior was **wrong**, and being wrong in that
direction is the useful part: the tell was never the vocabulary. It was the absence of numbers.

| claim | verdict |
|---|---|
| **Rectified Spectral Units (ReSUs)** | Term and mechanism **real**; scale wildly overstated; one property inverted |
| **Phaseless cortical microcircuits** | Phaseless learning **real**; "on par with ANNs" **refuted**; structurally **orthogonal** to this project |
| **Thalamic matrix neurons signal surprise** | **Unsupported**, and the key evidence runs the *opposite* way |
| **Genomic bottleneck ⇒ lower compute** | **Regularization, not compute** — one source is 9% *slower* |

---

## 1. ReSUs — real, and much smaller than advertised

Qin, Pughe-Sanford, Genkin, Ozdil, Greengard, Sengupta & Chklovskii, AAAI-26 (Proc. AAAI 40(3):2019–2028;
arXiv:2512.23146). Each unit projects a recent window of input history onto a canonical direction from
past–future CCA, then half-wave rectifies. That much is exactly as described.

**The scale.** The peak demonstration is a two-layer network whose first-layer units are each driven by a
**single pixel**, feeding one T4-analog unit, on 1-D rows of natural images. Keyword counts across the
arXiv and AAAI PDFs including supplementary material: `MNIST` 0, `CIFAR` 0, `accuracy` 0, `baseline` 0.
There is no task, no number, and no comparison to anything. Evaluation is qualitative resemblance to
*Drosophila* physiology. The authors: *"whether this approach generalizes to deeper networks remains an
open question."* Their own institution's press release calls it *"a proof-of-principle test."*

**The inverted property.** "Self-supervises by controlling its own training signal" reverses the
architecture — the paper states future inputs are *"used exclusively for learning,"* supplied by the
environment. Grep for "training signal": zero hits.

**The mechanism detail that actually matters here.** CCA is **symmetric and correlational**: it finds a
past-window projection correlated with a future-window projection. It does not emit a forecast. The
slow-feature-analysis equivalence to predicting the next input holds only for reversible, Gaussian series,
and Clark, Livezey & Bouchard (NeurIPS 2019) note *"most real-world systems including biological networks
... are time-irreversible."* **A ReSU stack yields better features, not a rollout model.**

## 2. Phaseless microcircuits — real, but not at the claimed scale, and orthogonal to us

Max, Jaras, Granier, Wilmes & Petrovici, PLoS Comput Biol 22(4):e1014164 (2026). *"Learning is phaseless
and always-on, as opposed to the vast majority of bio-plausible theories."* Genuine, and a real
distinction from Equilibrium Propagation and contrastive Hebbian learning, which need a relaxation phase.
The L2/3-as-error, L5-as-representation mapping is stated exactly as claimed — though the paper says *"we
hypothesize,"* so it is a modeling choice, not settled anatomy.

**"V1→V5, on par with ANNs" does not survive.** The complete benchmark set is cart-pole on a 4-1 network,
a six-neuron match-to-sample task, Yin-Yang at 30-3, teacher imitation across 2–5 *generic* areas, and
generative MNIST. No CIFAR, no ImageNet, no convolutions. "On par" is scoped to *"an ANN of equivalent
size"*; on Yin-Yang the model only *"nearly reaches"* ANN accuracy.

### What the ceiling for this whole field actually is

Because the claim implied deep-learning-scale parity, we chased the real number.

**Payeur et al. (Nat Neurosci 24:1010–1019, 2021) is often cited for ImageNet-scale success. Its own
numbers refute parity:** 56.1% top-5 error on ImageNet, with supplementary Table S1 giving a
backprop/model error ratio of **0.71** — about **1.41× backprop's error**. The paper's figure caption makes
the distinction itself: CIFAR-10 *"reach[ed] the performance of the backpropagation algorithm"*; the
ImageNet panel says only that the network *"was able to learn to classify images."*

**The real ceiling among everything checked is Akrout et al., *Deep Learning without Weight Transport*
(NeurIPS 2019):** full-resolution ImageNet, ResNet-18 top-1 error — weight mirrors 30.2%, Kolen-Pollack
**29.2%**, backprop 30.1%; ResNet-50 — 23.4% / 23.9% vs backprop 22.9%. Near-parity, and the only result
where the backprop baseline is itself competitive.

**The most portable lesson from this pass:** with that single exception, *every* parity claim in this
literature is measured against a size-matched control the authors ran themselves, far below state of the
art. **"Matched backprop" usually means "matched a deliberately weak baseline."**

**Why it is orthogonal to milbrain regardless.** Every rule surveyed solves one problem: routing an error
signal backward through a deep network without biologically implausible weight transport. This is a
*functional* model — reference frames, voting columns, a shallow forward model. **There is no deep gradient
here to reroute.** And across every verified result the ceiling is a tie, never a win; the payoff is
mechanistic realism, and the price is real (difference target propagation reaches near-parity on
*downsampled* 32×32 ImageNet at roughly **26× backprop's wall-clock**).

## 3. Thalamic matrix neurons — unsupported, and inverted

The claim: matrix neurons burst-fire to surprise and *restart* cortical sequence representations, so they
could gate a learning rate.

**They signal arousal, not error.** The only paper isolating matrix cells by molecular identity — Honjoh
et al., Nat Commun 9:2100 (2018) — assigns them arousal and broad cortical activation. Greps: `mismatch` 0,
`prediction error` 0, `unexpected` 0, `plastic*` 0.

**And it cuts the other way.** *"VM cells tend to fire tonically in wake and REM sleep and **in burst mode
in NREM sleep**."* The claim needs matrix bursts to mean surprise. In the only matrix-specific dataset,
burst mode is the *sleep* mode.

**"Restart" is not an empirical finding — and tracing it corrected us.** In the experimental literature the
word is simply absent: Rikhye, Gilra & Halassa (Nat Neurosci 2018) greps give `reset` 0, `restart` 0,
`replay` 0, with positive controls firing (`switch` 63, `suppress` 80). That paper argues the opposite:
*"it would be computationally efficient to simply re-engage the same functional ensemble rather than
generate a new one de novo."*

We initially guessed the word had leaked from Bouret & Sara's **locus coeruleus** "network reset" (Trends
Neurosci 2005). **That guess was wrong**, and the correction is instructive. The claim traces cleanly to
Max Bennett, *An Attempt at a Unified Theory of the Neocortical Microcircuit in Sensory Cortex*, Frontiers
in Neural Circuits 14:40 (2020) — a **theory** paper, which does say *"it resets sequences within L2/3-PY
neurons"* and, on the cell identity, *"I speculate that these HTC cells are in fact the same as the
multiareal matrix cells."* Bennett labels his own epistemic status throughout: *"I propose," "I speculate,"
"Although far from conclusive..."*

Our search covered the **empirical** thalamus literature and missed the **theory** literature, which is
where the claim actually lived.

**This does not rescue the surprise claim, and the reason is exact.** Bennett's empirical anchor is that
*"areas of thalamus **rich in** matrix neurons... respond selectively to unexpected sensory stimuli."* That
is a regional proxy, not a recording of a molecularly identified population — precisely the inferential
step missing across this whole literature, where the functional claim attaches to nuclei and never to the
cell class. Bennett makes that step openly, as a proposal. What reached us had converted it into *"recent
findings identify."*

**One component is real, in weakened form.** Higher-order thalamic POm input *is* causally necessary for
whisker-evoked LTP in L2/3 barrel cortex (Gambino et al., Nature 515:116–119, 2014; mechanism in Williams &
Holtmaat, Neuron 2019; replicated by Zhang & Bruno, eLife 2019). But the causal variable is POm activation
driving NMDAR plateau potentials — **not burst firing mode** — and the gate is opened by **rhythmic,
predictable ~8 Hz stimulation**, i.e. sensory co-activation rather than unexpectedness.

## 4. Genomic bottleneck — regularization, not compute

Two different claims get conflated: that compressed "grown" architectures achieve **equal accuracy at lower
compute**, versus that compression acts as a **regularizer** improving generalization. Only the second is
supported.

- **Zador** (Nat Commun 10:3770, 2019): *"may act as a regularizer or an information bottleneck."* Hedged,
  no experiment attached; the efficiency argument is about **labeled examples**, not FLOPs.
- **Shuvaev, Lachi, Koulakov & Zador** (PNAS 121(38), 2024) report an explicit **null**: *"genomic
  compression did not affect the learning trajectory; the only speedup was due to the higher initial
  performance."*
- **Barabási et al.** (Nat Commun 14:2226, 2023): the only compute measurement in the paper is wall-clock,
  and the developmentally-encoded network is **9% slower** (97 s vs 89 s).
- **Clune, Stanley, Pennock & Ofria** (IEEE TEC 2011): the phenotype is the *same size* as the direct
  encoding's, so there is no inference saving, and the CPPN query is extra work. The authors disown the
  comparison themselves.

Every source measures **parameters or genome bits**, never FLOPs. And architecturally the compression is of
the *specification*: a small generator produces a full-size phenotype that runs and trains at full size.
Lower compute is not merely unmeasured in this literature — it is **unmotivated by the architecture**.

### What that means for our own grown-3 result

Our [column-count result](../results/growing-columns.md) — grown-3 accuracy-equivalent to designed-5 at
~36% compute — is a **real, measured saving**, but it comes from somewhere this literature never claims:
we actually run three columns instead of five. That is ordinary over-provisioning recovered, **not**
evidence for compact generative programs. The two should not be cited for one another.

Two results land harder still, directly on our claim:

- Blalock, Gonzalez Ortiz, Frankle & Guttag (MLSys 2020): *"pruning is more effective for architectures
  that are less efficient to begin with."*
- Li & Talwalkar (UAI 2019): random search with early stopping matches ENAS — so **equal accuracy alone
  does not license crediting the search mechanism**.

Applied to us: accuracy is conserved from *N* = 2 to 5, so **enumerating {2,3,4,5} would find 3.** What did
the evolutionary search buy? On our own data, possibly nothing.

---

## Consequences for the roadmap

### The control we already promised, and have not run

Checked before claiming this as new: a **random-architecture control arm** is already listed as
non-negotiable in [directions from the frontier](directions-from-the-frontier.md) §4 and again as Tier-1
item 4 — *"cheap, mandatory for later claims"* — citing the same Li & Talwalkar result. **It has not been
run.** This pass independently re-derived the requirement from the pruning and NAS literatures, which
raises its priority rather than adding to it.

It bites for the same reason the [assembly world](../results/compositional-planning.md) did: that design
passed a non-triviality check by 90 points and was then solved perfectly by a one-line heuristic. A result
that has never faced its trivialization control is not yet a result.

**A refinement that gives the control a positive outcome too.** Score it not on the column *count* but on
what the search found. If enumeration with the standard topology also reaches grown-3's compute figure, the
search added nothing. If it does not, the search discovered a **connectivity or voting motif** enumeration
cannot reach — and *that*, not the number 3, would be the finding. Both arms pre-registered, equal
evaluation budget.

### A third axis for column diversity

The [correlation bottleneck](../results/correlation-bottleneck.md) established that inter-column error
correlation (φ ≈ 0.75) is the real ceiling, and that the obvious geometric lever is a dead end: the objects
span a tenfold size range, so *"there is no global patch-spread that is simultaneously on-object for all 77
objects and meaningfully decorrelating."* It named the surviving family — levers that keep the patch
**centered** on the object, *"varying each column's spatial scale, or its feature channels."*

**A heterogeneous temporal integration window is a third member of that family, and it has the required
property: it never moves the patch off the object.** That is the whole strength of the connection, and it
rests on our own measurement rather than on ReSU's results. The endpoint (φ) is already measured, so the
experiment is pre-registerable and cheap to falsify.

**Confidence: low.** Nothing in the verified literature shows heterogeneous temporal filters decorrelate
anything; ReSU is unvalidated at any useful scale; and spatial scale and feature channel are
already-named alternatives that may well dominate on cost. One candidate among three, to be ranked by
cost — not a mandate.

### Why surprise-gated learning cannot fix the composition failure

Our [environment search](../results/compositional-planning.md) established that in environments whose
constraints are *ordering* constraints, a competent agent encounters violations **0% of the time**.

A learning-rate gate is **multiplicative on an observed prediction error**. Zero times any gain is zero.
This is a coverage failure of the *data distribution*, and every mechanism that survived verification
operates downstream of it — reweighting collected experience, protecting existing representations, or
re-instantiating a learned mapping. **None generates observations.** The proposal is also self-undermining:
"a surprise triggers a high-rate learning event" presupposes surprise events occur, which is what the 0%
finding denies.

*A correction to our own earlier reasoning:* we first suggested curiosity-driven exploration might
manufacture the missing violations. That is too loose — prediction-error-based curiosity computes its bonus
from a prediction error too, so it inherits the same blindness. The interventions that attack a coverage
failure are **count-based or state-coverage exploration, or deliberate constraint-violation probing**.

### Compounding error is per-step geometry

**0.75¹⁰ = 0.056**, against an observed ten-step success of ~6%.

The collapse is per-step geometry to two significant figures, leaving no residual for a better learner to
capture. Credit assignment determines how well the *one-step* objective is fit, and none of these rules fits
it better than backprop. For scale: 0.90¹⁰ = 0.35 and 0.95¹⁰ = 0.60.

> **⚠ Second correction, 2026-07-23 — the evidence offered above is circular, and separately the "no
> residual" clause is false as written.** Two defects, found while re-checking this section:
>
> **(1) That "~6% observed" is not an observation.** It is *derived* elsewhere in our own notes as
> `≈0.76¹⁰ ≈ 6%` — so "0.75¹⁰ = 0.056 against an observed ~6%" compares one calculation to a nearly
> identical calculation and reports the match as though a prediction had met a measurement. The underlying
> claim may still be true; **the evidence given for it here is not evidence.** (We had also already retired
> the `M3^H` statistic elsewhere, for the related reason that two defensible versions of it disagreed by a
> factor of eighteen.)
>
> **(2) A better learner did capture a large residual, in this very environment.** Swapping the one-step
> model from a k-NN to an MLP moved per-step balanced accuracy only 0.617 → 0.642, but moved end-to-end
> planning gap recovery **7.9% → 50.1%** (paired t = 5.02, better in 6 of 6 seeds). A 2.5-point per-step
> gain produced a six-fold planning gain. So "no residual for a better learner to capture" is wrong as
> stated — the honest scope is the narrow one: *bio-plausible credit-assignment rules* do not fit the
> one-step objective better than backprop, and our system is not gradient-trained, so they buy us nothing.
>
> Taken with the 2026-07-22 correction below, the section's original headline survives only in this much
> reduced form. We are leaving the original text visible rather than rewriting it, because the shape of the
> error — an arithmetic identity presented as an empirical confirmation — is the more useful thing to
> publish.

> **⚠ Corrected 2026-07-22 — this section originally ended "all the leverage is in per-step accuracy."
> That was too strong, and a later experiment showed why.** The exponent is a lever too. Ten chained steps
> is not a property of the task; it is a property of a planner that must *see the goal* inside its own
> rollout. Give the planner an estimate of remaining effort to stop at instead, and the same environment
> needs a **3**-step lookahead rather than 12 — measured, and it survives a genuinely *learned* estimate
> (0.76 moves error, structured, and the structure costs ~2 points). So per-step accuracy is where all the
> *learner-side* leverage is, and the claim against credit-assignment rules stands unchanged; but the
> **planner** has a second lever, and we had missed it. See the correction in
> [compositional planning](../results/compositional-planning.md).

---

## What this pass did *not* establish

Stated rather than softened, because a verification document that hides its own gaps is worse than none.

- **Eight algorithm families produced zero verified claims**: Equilibrium Propagation and its scaled
  variants, predictive-coding approximations to backprop, Forward-Forward, Greedy InfoMax and decoupled
  greedy learning, direct feedback alignment at scale, SoftHebb, and anything from 2023–2026. **Akrout is
  the ceiling among what was checked, not a demonstrated field-wide maximum.**
- **Payeur's published version is paywalled**; all its numbers here come from the bioRxiv preprint, and an
  Author Correction exists that could not be accessed.
- **Gambino 2014 is paywalled with no open deposit** — the burst-scoping is a claim of non-*attribution*
  from the abstract, the authors' later restatement, and citing groups, not from a full-text search.
- **Search budgets were exhausted** in several verifiers, so field-wide negatives are bounded by the
  searches actually run.
- Several adjacent works named in the original brief — Yu & Dayan (2005), Keller & Mrsic-Flogel (2018),
  mismatch negativity, dopaminergic reward-prediction error — **were never retrieved** and are not relied
  on here.

Three further claims arrived during review and were held back pending verification. **All three have since
been traced, and all three resolve in the direction above** — one of them by correcting us:

- **The matrix-neuron hypothesis** is Bennett (2020), a theory article, self-labelled speculation. It
  **corrected our account of where the wording came from** (see §3) while leaving the verdict intact.
- **The high-threshold-bursting / alpha-rhythm account of matrix firing** is the same source and the same
  status — a proposal, not an independent finding. It also has to answer an awkward datum: in the only
  matrix-specific recording (Honjoh et al. 2018), burst mode is the **NREM sleep** mode.
- **"Jacobian lens / J-space"** was conceded rather than verified — the researchers reportedly say they
  have found *"the room, not the door"* and cannot say what decides which concepts reach the workspace. So
  "verified" was premature on the authors' own account. It stays off this site until it has a pass of its
  own.

**The rule this earns:** a claim sourced to a *Hypothesis and Theory* article is a **prediction to be
tested**, not evidence to build on. That is a respectable thing to be, and Bennett is scrupulous about
saying so. The failure was one layer up, where the hedges were stripped. Ask what **article type** a claim
came from before asking whether it is true.

---

## The transferable part

Adversarial checking pushed **toward the papers being more modest than the claims allowed, never less** —
in all four passes, without exception. So the cheap diagnostic is not *"is this term real?"* Three of these
four terms were real. It is:

> **Where are the numbers, and what is the baseline?**

Three of the four claims collapse the moment that question is asked. The fourth collapses on a single grep.

---

*This is a verification record, not a results claim. What it establishes is which of four proposed
directions rest on evidence — and the answer, for a project whose binding constraint was already located in
the environment rather than the learner, is that none of them changes what the system can do.*
