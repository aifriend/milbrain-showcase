# Directions at the implementation level — dendrites, bio-plausible backprop, neuromodulation

*A companion to [Directions from the frontier](directions-from-the-frontier.md). That document works at
Monty's **algorithm level** — capabilities the system lacks (acting, abstracting, composing, remembering).
This one works one level down, at **implementation**: proposals to make the computational **substrate**
more biophysically brain-like. **This is an ideation document, not results** — a proposal assessment. Its
value is a clear verdict on which implementation-level ideas add capability to a **functional** model like
Monty and which are realism aimed at a different kind of model. Every citation below was tool-verified
(32/32 confirmed); the two headline claims were independently fact-checked, and one correction lands on
this project's own earlier over-skepticism.*

> **Since this page was written, a later proposal revisited three of these four topics** — dendritic /
> temporal-filtering units, bio-plausible credit assignment, and the genomic bottleneck — asserting
> stronger versions of each. Four adversarial research passes checked those against primary sources, and
> the outcome **confirms this page's wording where it matters**: §4's careful framing of the genomic
> bottleneck as a *regularizer and transfer booster* is exactly what the literature supports, and the later
> proposal's stronger "equal accuracy at lower compute" reading is not. The new pass adds the actual
> published ceiling for bio-plausible credit assignment — far below what such proposals usually imply — and
> a control this project's own grown-3 result still owes. See
> **[Verifying four implementation-level claims](verifying-implementation-claims.md)**.

---

## The fork that organizes everything: two levels

Monty is a **functional** model by design: its unit is a whole cortical column ("learning module") written
in ordinary code, with no point neurons, no gradient training, and no neuromodulators. So a proposed
improvement can live at one of two levels:

- **Algorithm level** — *"can the system now do something it couldn't?"* (the [frontier directions](directions-from-the-frontier.md)).
- **Implementation level** — *"is this how the brain physically computes?"* — dendrites, bio-plausible
  learning rules, neuromodulatory gain.

The trap, specific to a functional model, is that implementation-level realism can add *biological
fidelity with zero capability delta* — the same "realistic but inert" pattern our own
[voting-topology experiment](../results/evolving-topology.md) fell into. The test that separates the two:
**does it let the system do something it provably couldn't, measured against a non-biological baseline?**
Below, four implementation-level ideas judged on exactly that.

## Fact-check first (with a correction to our own skepticism)

Two of these ideas came attached to specific recent-research claims. Both were checked against the
literature by tool, not opinion — and the check corrected *our* prior:

- **"A 2026 phaseless, always-on multi-area cortical microcircuit implementing biologically-plausible
  backpropagation with pyramidal error neurons" — CONFIRMED.** This is a real, correctly-described paper:
  Max, Jaras, Granier, Wilmes & Petrovici, *"'Backpropagation and the brain' realized in cortical error
  neuron microcircuits,"* *PLOS Computational Biology* (2026; bioRxiv 2025). It is multi-area, its learning
  is verbatim "phaseless and always-on" (no separate forward/backward passes), and it uses two pyramidal
  subpopulations per area — an *error* population (L2/3) and a *representation* population (L5). It extends
  the same group's Phaseless Alignment Learning (Max et al., *Nature Machine Intelligence*, 2024) and the
  Sacramento et al. (2018) dendritic-microcircuit lineage.
- **"Rectified Spectral Units (ReSU)" as a multi-compartment / dendritic unit — PARTIAL.** The unit is
  real (Qin, Pughe-Sanford, …, Chklovskii, arXiv:2512.23146, 2025; AAAI-26), so not fabricated — but the
  *dendritic/multi-compartment* description is a mislabel: the paper never mentions dendrites or
  compartments. A ReSU is a **spectral/temporal-filtering** unit (a rectified projection onto a
  canonical past–future direction) that **learns hierarchical features *without* error backpropagation**
  via a local self-supervised rule. It therefore belongs to the *learning-without-backprop* theme (below),
  not the dendritic one.

## 1. Dendritic / multi-compartment units — real neuroscience, wrong level for Monty

The dendritic-computation literature is strong and replicated: a single L5 pyramidal cell needs a 5–8-layer
temporal CNN to mimic it (Beniaguev, Segev & London 2021); a single human L2/3 neuron computes XOR via
graded dendritic calcium spikes (Gidon et al. 2020); single neurons are precise spatiotemporal pattern
recognizers (Beniaguev 2023; Shapira et al. 2025). But every one of these is a claim about the
**substrate** — a critique of the McCulloch–Pitts point neuron. **Monty has no point neurons.** Its module
is already at least as expressive as a deep net, already computes XOR, chains nonlinearities, and handles
time algorithmically (sensorimotor movement into reference frames). So none of this unlocks a capability
Monty lacks; it is realism relevant to a *different* program — biophysical/spiking re-implementations
(NEURON), or gradient-trained *dendritic ANNs* seeking parameter efficiency (Chavlis & Poirazi 2025), which
presuppose the very backprop Monty rejects.

**Verdict: realism-only for Monty; a sister-project (biophysical TBT) contribution, not an upgrade to the
functional algorithm.** One honest echo, though: the dendritic field's own lesson — expressivity is capped
by structural redundancy and *bought by heterogeneity* (Jones & Kording 2021) — is our column-level
[finding](../results/growing-columns.md) one level down. More on that convergence at the end.

## 2. Bio-plausible credit assignment — the realest gap, but it fights the premise

This is the most important entry, because the **gap it names is real and our algorithm-level roadmap needs
it**: TBT has no normative learning objective and no story for **credit assignment across a *hierarchy* of
columns**. When you stack columns into the deep compositional/heterarchical structures general intelligence
needs, how does a low column learn it made an error a high column cares about? The literature here is a
coherent family — Lillicrap et al. 2020 (the umbrella "NGRAD" argument), Sacramento et al. 2018 and Payeur
et al. 2021 (concrete cortical substrates; Payeur is the most on-point for the hierarchical gap),
Whittington & Bogacz 2017 and Millidge et al. 2020 (predictive coding *approximates* backprop), Scellier &
Bengio 2017 (equilibrium propagation), Lee et al. 2015 (target propagation).

Two honest cautions. **First, all of these are gradient machinery** — they show how the cortex could
*approximate backprop*, which presupposes training connection weights by descending a loss. Monty learns by
*structure-building* (inserting nodes into localist reference-frame graphs), not weight gradients. Importing
backprop is importing the paradigm TBT was defined against. **Second, there is a native-feeling exception:
predictive coding.** PC is a *message-passing* scheme (predictions down, errors up, settle) that maps
directly onto Monty's Cortical Messaging Protocol — and it provably approximates backprop (Whittington &
Bogacz 2017). So the TBT-faithful route to hierarchical credit assignment is **a precision-weighted
prediction-error channel in the CMP**, not a grafted backprop network. (That this exact mechanism surfaced
independently in the [algorithm-level review](directions-from-the-frontier.md) is a good sign.) Notably,
the ReSU result above is a second existence-proof that hierarchical features are learnable *without*
backprop at all.

**Verdict: keep the gap, reject the default fix. Build credit assignment as prediction-error through the
messaging protocol; treat imported backprop as the fallback, not the goal.**

## 3. Neuromodulation / adaptive gain — mostly aimed at problems Monty doesn't have

The stability–plasticity motivation (dopamine/ACh/NE gating learning) is largely a **category error** for
Monty: it stores each object as a *separate localist graph*, so it does not suffer the shared-weight
catastrophic forgetting that motivates the CLS/neuromodulation story. And mechanically, a **scalar gain on
voting cannot fix our correlated-vote finding** — multiplying every vote by *g* leaves their correlation
(the actual problem) unchanged; decorrelation needs an off-diagonal transform, not a scalar (Aston-Jones &
Cohen 2005). The valuable residue is narrow but real: **unexpected-uncertainty / change-point detection**
(Yu & Dayan 2005; Nassar et al. 2012) is a novelty signal Monty genuinely needs — "no hypothesis fits →
reset, this is a new object" — and the **explore/exploit** reading is really *active sensing*, which Monty
already realizes at the algorithm level as expected-information-gain movement. Doya's (2002) other
neuromodulator roles (reward-prediction error, discounting) map onto machinery Monty deliberately lacks.

**Verdict: mostly realism aimed at a non-problem; salvage exactly one piece — a surprise/change-point
detector to trigger hypothesis reset — and fold the rest into active sensing at the algorithm level.**

## 4. Genomic bottleneck / indirect encoding — the one that *is* capability, and it's ours

This is the exception that is genuinely capability-relevant, and it grounds the whole "grow the
architecture" thesis. The genome (~10⁹ bits) is orders of magnitude too small to specify the connectome
(~10¹⁵ bits), so it cannot store a blueprint — it stores **compressed wiring rules that unfold
developmentally** (Zador 2019; "algorithmic growth," Hiesinger 2021). The concrete ML payoff: a compact
generator (a CPPN / g-network) acts as a **regularizer and a transfer booster** — but Shuvaev, Lachi,
Koulakov & Zador (2024) find this **only for *complex*, not simple, tasks**, and Barabási et al. (2023)
show count-free scaling comes from *differentiating* neurons by identity and gradients. Stanley et al.
(2019) name the crux directly: indirect encodings earn their power from **repetition *with variation***,
not repetition.

**Verdict: capability-relevant and directly ours — but it re-derives, from the developmental side, the
exact caveat our data established: growth pays through *heterogeneity*, and only in the *complex-task*
regime.** This is the implementation-level foundation under [substrate C](directions-from-the-frontier.md)
(heterogeneous, error-gated growth), and its regime-dependence is independent confirmation that the
[frontier result's](../results/growing-columns.md) null was a saturated-task artifact, not a verdict on growth.

## The scale-invariant motif

The striking result of this pass is a single principle recurring at **every** level the literature touches:

| level | "replication is redundant; variation pays" |
|---|---|
| **genome → cortex** | indirect encoding boosts transfer only via *repetition-with-variation*, only on complex tasks (Shuvaev/Zador 2024; Stanley 2019; Barabási 2023) |
| **single neuron** | dendritic expressivity is capped by structural redundancy, bought by *heterogeneous* reuse (Jones & Kording 2021) |
| **cortical column** | our own result: identical voting columns are redundant; only *decorrelated* modules add accuracy |

"**Heterogeneity, not replication**" is not just the milbrain finding — it is a scale-invariant design
principle from genome to neuron to column. That is the deepest thing this document adds, and it sharpens the
whole program: *the lever is variation, at whatever level you build.*

## Bottom line for the roadmap

Of the four implementation-level ideas: **#1 (dendrites)** is a sister project, not this one; **#3
(neuromodulation)** is mostly a non-problem here, salvage a change-point detector; **#2 (bio-backprop)**
names a real gap best solved TBT-natively as prediction-error through the messaging protocol; **#4 (genomic
bottleneck)** is genuinely capability-relevant and is the developmental foundation of our own
heterogeneous-growth direction. And a note on method: two specific recent-research claims here were checked
by tool and *both corrected an earlier, too-skeptical dismissal* — a reminder that the discipline cuts
toward the reviewer as often as the reviewed.

---

*Ideation, not results. The algorithm-level companion — the capabilities (act / abstract / compose /
remember) that most move Monty toward general intelligence — is in
[Directions from the frontier](directions-from-the-frontier.md).*
