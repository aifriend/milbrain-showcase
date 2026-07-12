# Research plan — growing the Thousand-Brains architecture

Operational research plan: the *how-do-I-actually-do-the-science* companion to the theory landscape —
research questions, falsifiable hypotheses, method, experimental protocol, and go/kill gates. Every prior-art / method / venue claim below was web-verified
(see `research/neocortex/` and the workflow findings in the session history); the one soft spot is
noted under Risks.

---

## 1. Research question and hypotheses

**RQ.** Can an *indirect developmental encoding* **grow** the learning-module (LM) architecture of a
Thousand-Brains system — the module count, the sensor→LM wiring, and the LM↔LM voting topology —
to match or beat the *hand-designed* architecture on embodied sensorimotor object recognition, at a
characterizable compute cost?

Falsifiable hypotheses (each with a measurable gate):

- **H1 — Realizability.** A genome → Monty-config pipeline can instantiate *valid, runnable*
  multi-LM architectures beyond Monty's two shipped topologies (1-LM surface, 5-LM distant).
  *Gate:* ≥1 non-shipped topology (e.g. 3-LM, or a 5-LM with a non-all-to-all vote matrix) trains
  and evaluates end-to-end without hand-editing configs. **This is the current engineering blocker.**
- **H2 — Parity.** An architecture found by the encoding reaches ≥ the hand-designed accuracy on the
  benchmark (`randrot_noise_10distinctobj`: documented 100%; multi-object/77-obj: 92.2%).
  *Gate:* grown ≥ hand-designed on the same benchmark + seeds, within the strict-metric CI.
- **H3 — Advantage (the thesis payoff).** Grown structure *beats* hand-designed on a harder axis —
  compositional objects, more objects, sample-efficiency, or **accuracy-per-FLOP** — or discovers a
  non-obvious connectivity a human wouldn't hand-write. *Gate:* a statistically significant win on
  ≥1 axis over both hand-designed and a scaled baseline.
- **H0 — Kill criterion.** If, after a well-tuned search with adequate compute, grown never matches
  hand-designed on *any* axis, the honest finding is "hand-design suffices at this scale" → pivot to
  *analysis of why* (the negative result is still publishable) rather than forcing a win.

## 2. Novelty and positioning (verified)

The intersection **{evolution / growth / indirect-developmental encoding} × {Thousand Brains /
Monty / HTM / reference-frame cortical column}** is **empty** in the published literature (adversarial
refutation returned `refuted: no`). TBP authors hand-design every architecture (explicitly, as a
design principle — [TBP 2024](https://arxiv.org/abs/2412.18354); [Leadholm et al.
2025](https://arxiv.org/abs/2507.04494), *Neural Computation* 38(6), 2026); the
neuroevolution/indirect-encoding community has never touched a reference-frame/grid-cell columnar
object model.

**Position it narrowly to stay safe:** this is a novel *combination*, not a novel primitive. Both
ingredients are mature — cite the nearest neighbors up front to show awareness:

- [Pugh & Stanley 2013](https://doi.org/10.1145/2463372.2463459), *evolving multimodal controllers
  with HyperNEAT* — closest on the indirect-encoding-of-behavior axis (GECCO).
- [Risi & Stanley 2012 (ES-HyperNEAT)](https://pubmed.ncbi.nlm.nih.gov/22938563/) — closest on
  *growing structure* via indirect encoding on geometric substrates (already in your vault).
- [Zyarah & Kudithipudi 2018](https://arxiv.org/abs/1812.10730) — HTM "neurogenesis" (local
  homeostatic replacement, **not** evolution/search); the closest "grown HTM."
- [Kvalsund & Lepperød 2025](https://arxiv.org/abs/2507.12473) — module-repetition / minicolumn
  review (conceptual, no growth).
- A 2025 NCA-in-biology review that links NCA development to cortical columns in prose — the
  **watch item**: someone could make the leap. Publish a flag early (§7).
- **Forum-surfaced neighbors (TBP Discourse, crawled 2026-07-12):**
  [thread 1128](https://forum.thousandbrains.org/t/1128) — a community HTM/TBT system with *learned*
  (not assumed-Euclidean) reference frames; and
  [thread 1146](https://forum.thousandbrains.org/t/1146) — Duchateau's "AATM" *coalition* binding
  architecture. Both are the nearest *live* work, but one learns the RF *geometry* and the other is
  an alternative *hand-designed* binding scheme — **neither evolves/grows the LM architecture.** Draw
  that line explicitly; these are the two a TBP-adjacent reviewer is most likely to raise.

## 3. Method

The phenotype is a **small discrete graph** (a handful of heavyweight LM units + their wiring), not a
dense weight tensor — so the encoding should generate *topology/connectivity*, not weights.

- **Primary encoding — connective-CPPN / ES-HyperNEAT.** Place candidate LMs on a 2D "cortical
  sheet"; a CPPN outputs the inter-LM vote/hierarchy adjacency (and sensor→LM assignment) as a
  function of module coordinates; threshold to discrete edges. ES-HyperNEAT additionally lets module
  count/placement emerge from the connectivity pattern
  ([Stanley 2007 CPPN](https://link.springer.com/article/10.1007/s10710-007-9028-8);
  [HyperNEAT 2009](https://doi.org/10.1162/artl.2009.15.2.15202); ES-HyperNEAT 2012). This directly
  fits the vault's algorithmic-growth thread (Hiesinger, Risi & Stanley).
- **Alternative encoding — Neural Developmental Program / HyperNCA.** A local growth rule that
  self-assembles the graph ([HyperNCA 2022](https://arxiv.org/abs/2204.11674);
  [NDP 2023](https://arxiv.org/abs/2307.08197)). Keep as a second arm — a diversity of encodings is a
  strength, and NDP is the more biologically "developmental" framing for a CCN/ALIFE audience.
- **Fitness.** Multi-objective: (1) recognition accuracy on the Monty benchmark (official metric =
  `correct`+`correct_mlh`; report strict separately), (2) **FLOPs via `tbp.floppy`** (efficiency is a
  feature, and the accuracy-per-FLOP axis is where grown structure can beat scaling). Sequential
  seeds (parallel corrupts shared output files).
- **Search.** Start single-objective evolution (μ+λ, already prototyped in our implementation). Add
  **quality-diversity (MAP-Elites**, [Mouret & Clune 2015](https://arxiv.org/abs/1504.04909) — in
  your vault) to map the architecture space and surface *diverse* good topologies, not one optimum —
  a stronger scientific artifact than a single winner.

## 4. The technical crux (Phase 0 — the real blocker)

Our current decoder handles only Monty's two *shipped*
topologies; arbitrary N / connectivity **raises**, because Monty v0.42.0 sets LM count via *named
Hydra config groups* (`1lm_1sm`, `5lm_5sm`) with matching pretrained models — not scalar overrides.
So Phase 0 is a **config-generation + pretraining harness**:

1. Programmatically emit the four coupled config groups for a given topology — `connectivity`
   (sm→lm + lm→lm vote matrices), `learning_module` (N EvidenceGraphLM entries), `sensor_module`,
   `motor_system` — as Hydra YAML or dataclass configs Monty accepts.
2. **Pretrain a matching model** for each new topology (Monty eval requires a model whose LM count
   matches). Reuse Monty's `supervised_pre_training_*` machinery, parameterized by the generated
   topology.
3. Verify one hand-picked non-shipped topology (e.g. 3-LM) trains + evals end-to-end. **This gate
   (H1) unblocks everything downstream** and is itself a concrete, demonstrable contribution.

## 5. Experimental protocol

- **Benchmarks (escalating):** `randrot_noise_10distinctobj` (parity), then 77-object, then
  compositional objects (`tbp.compositional_dataset`) for the generalization claim.
- **The three-way controlled comparison (the citable result):** *grown* vs *hand-designed* vs
  *scaled connectionist*, on the **same** benchmark + seeds. This is the concrete probe of the
  scaling-vs-structure disagreement logged in your vault.
- **Metrics:** accuracy (official + strict), rotation error, match-steps, FLOPs, sample-efficiency
  (accuracy vs #training rotations), and connectivity descriptors of the discovered architectures.
- **Controls / baselines:** hand-designed Monty (1-LM, 5-LM); **random** architecture search (the
  honest floor — does evolution beat random?); [Weight-Agnostic Neural Networks (Gaier & Ha
  2019)](https://arxiv.org/abs/1906.04358) and [DARTS (Liu et al. 2019)](https://arxiv.org/abs/1806.09055)
  as NAS reference points a committee will expect; MAP-Elites vs single-objective as an internal
  ablation.

## 6. Phased milestones with go/kill gates

| Phase | Deliverable | Gate (falsifiable) | Est. |
|---|---|---|---|
| **P0** Config-gen harness | generate + pretrain + eval one non-shipped topology | H1: 3-LM runs end-to-end | ~Y1 |
| **P1** Encoding + reproduction | CPPN/ES-HyperNEAT genome → topology; baselines wired; FLOP accounting | evolution beats **random** search on parity | ~Y1–2 |
| **P2** Grow-vs-design | the three-way comparison on 10/77 objects | H2 parity; H3 win on ≥1 axis **or** documented null | ~Y2–3 |
| **P3** Scale / transfer | compositional objects; optional real-sensor (`tbp.ultrasound_perception`) | generalization result; honest transfer limit | ~Y3–4 |

Each gate is a genuine decision point — if P1 evolution can't beat random, fix the encoding/fitness
before spending P2 compute; if P2 hits H0, pivot to the analysis paper.

## 7. Submission timeline (real deadlines, from today 2026-07-12)

Stake the novelty flag cheaply and early, then aim the archival method paper once P2 lands:

- **Near-term flag (non-archival):** **ALIFE 2026 Late-Breaking Abstract — deadline 20 Jul 2026**
  (8 days): a 2-pager on "growing Thousand-Brains architectures" (P0 vision + the working 5-LM
  reproduction). Then **NeurIPS 2026 workshops** (NeuroAI / NeurReps; CFP ~Sept–Oct 2026).
- **Archival method paper:** **GECCO 2027** (neuroevolution track; ~Jan 2027 deadline) for the
  encoding + P2 result. **CCN 2027** (~Feb) for the cognitive-neuro framing.
- **Journal:** *Artificial Life* / *Neural Networks* / *TMLR* for the consolidated three-way study.
- **Engage TBP directly:** the reproduction (this repo) + a proposed extension is the on-ramp to
  their open research community; upstream endorsement de-risks novelty and framing.

## 8. Risks

| Risk | Severity | Mitigation |
|---|---|---|
| **Scoop** (esp. the NCA-review authors making the cortical-column leap) | high | Publish the ALIFE LBA flag *now*; keep the framing narrow + specific to reference-frame Monty. |
| Novelty softness | low→resolved | Formal literature **and** TBP + Numenta forums both crawled (2026-07-12) — **no scoop**; digest logged in the vault. Nearest live neighbors (t/1128, t/1146) cited above. Re-check TBP Discourse **weekly** (the live venue; scheduled) since the gap is a decaying asset. |
| **Config-gen (P0) intractable** — Monty's coupled configs resist parameterization | high | Timebox P0; if generation is too brittle, restrict the search space to a *library* of pre-generated topologies (still a real, if smaller, contribution). |
| Compute — evolution × emulated CPU is slow | med | FLOP-aware fitness makes small nets a feature; Route-3 arm64-native spike; MAP-Elites parallelizable across machines (sequential *within* a shared output dir only). |
| Simulator ≠ world | med | Frame claims as computational; real-sensor transfer as the honest limit (P3). **Concrete anchor:** TBP's own zero-shot Monty on real RGB-D (YCB-V) hits ~12% correct — an *information wall* from single viewpoints, not a tuning gap (forum t/1157). Set transfer expectations by it. |
| Validation problem (a functional model ≠ the brain) | med | Claims are about architecture-growth for *capability*, not neural realism — pre-empt in the framing chapter (cf. Hiesinger/Koch in the landscape doc, and the TBT 2.0 paper's appendix on what would count as evidence for reference frames, forum t/1154). |

## 9. Reading anchors

Grounded in `research/neocortex/` (verified bibliography) and the vault. Core method line:
Stanley 2007 → HyperNEAT 2009 → **ES-HyperNEAT 2012** → NDP/HyperNCA 2022–23. Target model:
Hawkins/Lewis 2019 (reference frames) → TBP 2024 / Leadholm 2025 (Monty). Neighbors to cite for
positioning: Pugh & Stanley 2013, Zyarah & Kudithipudi 2018, Kvalsund & Lepperød 2025. Baselines:
Gaier & Ha 2019 (WANN), Liu 2019 (DARTS), Mouret & Clune 2015 (MAP-Elites).

---

### The one-paragraph version

Nobody has used indirect/developmental encoding to grow a Thousand-Brains architecture — verified,
adversarially, as of July 2026. The plan: build the config-generation harness that lets an arbitrary
LM topology be instantiated + pretrained + evaluated (P0, the current blocker and a contribution in
itself); encode the topology with a connective-CPPN / ES-HyperNEAT genome and evolve it against a
FLOP-aware fitness (P1, must beat random search); run the controlled grown-vs-designed-vs-scaled
comparison on Monty's own benchmarks (P2, the payoff — or an honest null); scale to compositional
objects (P3). Flag the novelty at ALIFE 2026 (LBA, 20 July) now, aim the method paper at GECCO 2027,
and engage the TBP community as collaborators.
