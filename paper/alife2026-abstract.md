# Growing the Thousand-Brains Architecture: Indirectly-Encoded Developmental Topologies for Sensorimotor Object Recognition

**Jose B. López**  ·  *[affiliation — TODO]*  ·  *[email — TODO]*

## Motivation

The Thousand Brains Theory (TBT) recasts the neocortex as thousands of near-identical cortical
columns, each learning object models in reference frames and reaching consensus by voting
(Hawkins et al., 2019; Lewis et al., 2019). Its open-source implementation, **Monty** (Thousand
Brains Project, 2024; Leadholm et al., 2025), realizes this as a sensorimotor system of sensor
modules and *learning modules* (LMs) that exchange messages over a cortical messaging protocol.
Yet the **architecture** — how many LMs, how sensors map to them, and the LM↔LM voting topology —
is entirely *hand-designed*, by explicit project principle (interpretable, hand-iterated systems).

This mirrors a tension in developmental neuroscience: biological cortex is **grown** by local rules,
not wired from a blueprint (the protomap/protocortex debate; algorithmic growth). We therefore ask:
*can an indirect developmental encoding grow the TBT architecture rather than hand-specify it, and
does grown structure match or beat the hand-designed one on embodied object recognition?* To our
knowledge — an adversarial literature search in July 2026 — the intersection of
**{evolutionary / indirect-developmental encoding}** and **{Thousand-Brains / reference-frame
cortical models}** is *unoccupied*: mature neuroevolution and indirect encoding (Stanley, 2007; Risi
& Stanley, 2012; Najarro et al., 2023) on one side, and hand-built reference-frame models on the
other, have not met.

## Work in progress: an evaluable substrate

As a foundation we independently reproduced Monty's sensorimotor benchmark and built a
**genome → configuration → run** pipeline. On `randrot_noise_10distinctobj` (10 YCB objects under
random 3-axis rotation with sensor noise), our containerized reproduction matches the documented
**100%** recognition — corroborated by two orthogonal quantities, mean match-steps (30 vs 30) and
pose error (≈13° vs 12.85°) — across five independent seeds (strict-convergence 99.2%±1.2; **zero
misrecognitions in 500 episodes**). We then implemented a decoder mapping a compact architecture
genome (module count, inter-LM connectivity, voting topology) onto Monty's shipped topologies and
executing it. A decoded **five-LM** architecture runs end-to-end — all five learning modules active
and voting, 100% recognition — demonstrating that the genome → phenotype → fitness loop is closed on
a real embodied system, not a surrogate.

## Proposed approach

We propose to grow the LM topology with a **connective indirect encoding**. Candidate LMs are placed
on a two-dimensional cortical sheet; a compositional pattern-producing network (CPPN; Stanley, 2007)
outputs the sensor→LM and LM↔LM adjacency as a function of module coordinates, thresholded to a
discrete graph. **ES-HyperNEAT** (Risi & Stanley, 2012) additionally lets module count and placement
emerge from the connectivity pattern — a direct analogue of algorithmic growth; a neural
developmental program (Najarro et al., 2023) is a second, more explicitly morphogenetic arm.
Fitness is **multi-objective** — recognition accuracy on Monty's benchmark *and* inference FLOPs —
so efficiency is selected for and the accuracy-per-compute axis, where structured priors may beat
scaling, becomes measurable. We will use quality-diversity search (MAP-Elites; Mouret & Clune, 2015)
to *illuminate* the space of good architectures rather than return a single optimum.

The immediate obstacle, and our next milestone, is a **configuration-generation harness**: because
Monty specifies LM count through coupled, named configuration groups with matching pretrained models,
realizing an *arbitrary* grown topology requires generating those groups and pretraining a matching
model. This is the concrete gate that unlocks the search, and closing it is itself a demonstrable
contribution.

## Relevance to artificial life

This is a developmental, self-organizing account of a cortical architecture: the phenotype — a
network of voting columns — is *grown* from a compact genotype by a local rule and evaluated by
embodied sensorimotor behavior. It gives ALIFE a concrete, neuroscience-grounded, benchmarked testbed
for the morphogenetic-encoding question — *does life-like grown structure outperform designed
structure?* — and connects the field's developmental-encoding tradition to the current NeuroAI debate
on structured priors versus scale. We report the reproduction and the working genome→run
infrastructure here, and present the developmental-encoding approach and the config-generation
milestone as the path forward.

*[Figure 1 — the learned 3D reference-frame object models and step-by-step evidence accumulation from
our reproduction: candidate objects' evidence over sensorimotor steps, the target overtaking
competitors and converging past threshold.]*

## References

- Hawkins, J., Lewis, M., Klukas, M., Purdy, S., & Ahmad, S. (2019). A Framework for Intelligence and
  Cortical Function Based on Grid Cells in the Neocortex. *Frontiers in Neural Circuits*.
- Lewis, M., Purdy, S., Ahmad, S., & Hawkins, J. (2019). Locations in the Neocortex: A Theory of
  Sensorimotor Object Recognition Using Cortical Grid Cells. *Frontiers in Neural Circuits*.
- Thousand Brains Project (2024). The Thousand Brains Project: A New Paradigm for Sensorimotor
  Intelligence. *arXiv:2412.18354*.
- Leadholm, N., Clay, V., Knudstrup, S., Lee, H., & Hawkins, J. (2025). Thousand-Brains Systems:
  Sensorimotor Intelligence for Rapid, Robust Learning and Inference. *arXiv:2507.04494*;
  *Neural Computation* 38(6).
- Stanley, K. O. (2007). Compositional Pattern Producing Networks: A Novel Abstraction of Development.
  *Genetic Programming and Evolvable Machines*.
- Risi, S., & Stanley, K. O. (2012). An Enhanced Hypercube-Based Encoding for Evolving the Placement,
  Density, and Connectivity of Neurons (ES-HyperNEAT). *Artificial Life*.
- Najarro, E., Sudhakaran, S., & Risi, S. (2023). Towards Self-Assembling Artificial Neural Networks
  through Neural Developmental Programs. *arXiv:2307.08197*.
- Mouret, J.-B., & Clune, J. (2015). Illuminating Search Spaces by Mapping Elites. *arXiv:1504.04909*.
- Pugh, J. K., & Stanley, K. O. (2013). Evolving Multimodal Controllers with HyperNEAT. *GECCO*.
