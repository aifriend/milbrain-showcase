# Directions from the frontier — the grown-columns result read against the neuroscience literature

*A finding-driven synthesis: what the [column-count result](../results/growing-columns.md) means, which
neuroscience and machine-learning literatures it speaks to, and — the point of the document — the best
next experiments and a reading map to pursue them. This complements the broad
[neocortex research landscape](neocortex-research-landscape.md) (a survey) by being narrow and forward:
it starts from one measured result and asks where to go. Every source below was found by an adversarial
six-lens literature search and independently citation-verified (45 of 46 confirmed; the one correction is
flagged at the end).*

---

## 1. The finding, precisely

On 77-object sensorimotor recognition, grown cortical models of *N* ∈ {2, 3, 4} columns match the
hand-designed *N* = 5 model's **89.4 %** accuracy within noise. The grown **three-column** model is
formally accuracy-**equivalent** (paired TOST, ±2-point margin, Holm-corrected, *p* = 0.012) at **36 % of
the compute**, and was denied a pre-registered *pass* only by a wall-clock guard: it needs **~4 % more
integration steps** per episode. The result lives on three axes:

| axis | behaviour across *N* = 2 → 5 | one-line reading |
|---|---|---|
| **accuracy** | conserved (~89–90 %, differences within noise) | the task does not make column count accuracy-limiting |
| **voting compute** (O(*N*²)) | falls steeply with fewer columns (grown-3 = 36 %) | fewer columns ⇒ far less lateral-voting cost |
| **integration steps** (latency) | rises slightly with fewer columns (+4 % at *N* = 3) | fewer columns ⇒ slower evidence accumulation |

The scientific question this poses is **not** "why didn't growth win" but **"in what regime is column
count load-bearing for accuracy at all — where would *more* columns genuinely help?"** The literature
answers this with unusual unanimity.

## 2. The convergent verdict: the null is the *predicted* outcome

Six independent literatures — queried separately — return the **same** diagnosis: on a task within a
single column's capacity, with correlated columns, added columns buy **speed, capacity, and robustness,
not accuracy**. The milbrain null is the mainstream prediction, not an anomaly.

- **The Thousand Brains Theory says so directly.** Hawkins, Ahmad & Cui (2017) show a *single* column
  recognizes an object after ~11 sensations, and adding columns via lateral voting only cuts the
  *sensations-to-convergence* (≈4 with three columns), with rapidly diminishing returns — **same accuracy,
  reached faster**. A single column already learns hundreds of objects. The 2019 grid-cell framework and
  the Thousand Brains Project papers (Clay et al. 2024; Leadholm et al. 2025) make module count an
  explicit, application-driven scaling parameter that "makes the system faster and more efficient," and
  report no ablation where count changes accuracy. milbrain's grown-3-matches-designed-5-but-4 %-slower is
  almost a line-for-line confirmation of Hawkins et al. (2017).

- **Degeneracy theory.** Edelman & Gally (2001) define degeneracy as structurally *different* systems
  producing the *same* output — ubiquitous in biology. Prinz, Bucher & Marder (2004) are the empirical
  proof: >20 million model versions of a 3-cell circuit give near-identical activity from widely disparate
  parameters. The reading: the shipped task sits on a **degeneracy manifold** where accuracy is invariant
  to *N* while cost is not — and degeneracy's payoff is *robustness*, not clean-condition accuracy.

- **Efficient coding & wiring economy.** Barlow (1961) sets the norm: an efficient system carries no
  surplus capacity beyond the task's information content. Attwell & Laughlin (2001) and Lennie (2003) show
  that *signaling* dominates the cortical energy budget and that spikes are so costly that only a percent
  or so of neurons can be active at once — so biology is under strong pressure toward the **cheapest
  architecture that preserves function**. Chklovskii, Schikorski & Stevens (2002) show cortex sits near a
  "wiring catastrophe" where even 10 % excess wiring is untenable. Every added column adds *quadratically*
  many lateral connections — so equal accuracy at lower *N* is the energetically dominant solution, and a
  bits-per-joule objective (Levy & Baxter 1996) would flip grown-3's wall-clock-denied verdict into a win.

- **The speed–accuracy tradeoff.** The ~4 %-more-steps cost is the textbook signature of moving *along* a
  fixed SAT frontier, not shifting it (Gold & Shadlen 2007; Bogacz et al. 2006). Wohrer & Machens (2015)
  make it near-literal: ensemble size *K* and integration window *w* are **dual knobs on percept SNR**, so
  a *K*↓/*w*↑ swap at fixed accuracy is *predicted*. Biologically, consensus is attractor convergence whose
  timescale is set by recurrent coupling (Wong & Wang 2006) — so topology controls **speed** even where it
  leaves accuracy untouched, exactly the asymmetry milbrain measured.

- **Ensemble error correlation.** Voting is an ensemble, and ensemble error falls only in proportion to
  the *independence* of the voters (Tumer & Ghosh 1996). Columns viewing one rigid object from slightly
  displaced sensors — and sharing identical pretraining — produce **highly correlated** evidence, so the
  pooling benefit saturates after a handful of units (Zohary, Shadlen & Newsome 1994; Rosenbaum, Trousdale
  & Josić 2010). This is the mechanistic why: 2, 3, 5 columns all sit past the correlation knee.

- **Architecture-search rigor.** In NAS, when a benchmark is ceiling- or noise-limited, a properly tuned
  **random** architecture matches the best search method — the search *space* dominates the search
  *algorithm* (Li & Talwalkar 2019; Yu et al. 2020). milbrain's own diagnosis — 10-object ceiling-saturated,
  77-object noise-limited — is precisely the "benchmark does not discriminate" failure. A positive
  existence proof that grown *can* beat designed (Real et al. 2019, AmoebaNet) required three things
  milbrain lacks: large compute, a strictly controlled same-space comparison, and **a task with accuracy
  headroom**.

The convergence is the actual result of this review: **the null is robust and expected, and the way
forward is to change the regime, not the search operator.**

## 3. Where architecture becomes load-bearing — the regimes to move to

The same literatures name a small, consistent set of regime shifts that should convert the null into a
resolvable — and theory-predicted — accuracy signal. In rough order of leverage-per-effort:

1. **Decorrelate the columns (grow *diversity*, not count).** The single most-cited lever. Give each
   column a spatially distinct sensor patch, a different receptive field / feature channel, or an
   independent pretraining draw, so their errors decorrelate. Ensemble and pooling theory (Zohary 1994;
   Rosenbaum 2010; Tumer & Ghosh 1996) predict that *decorrelated* pooling keeps gaining where *correlated*
   pooling saturates; the mixture-of-experts continual-learning result (Li et al. 2024) generalizes it —
   undifferentiated added capacity is inert, specialized capacity is not. This reframes the growth target
   from "how many columns" to "how independent are the columns."

2. **Make evidence limited (occlusion / partial observability / noise / ambiguity).** The Thousand Brains
   heterarchy theory (Hawkins, Leadholm & Clay 2025) states voting helps only "when individual columns
   face uncertainty." Cap per-column coverage, occlude a fraction of the object, add per-observation sensor
   noise, or use finely confusable object sets — so a single column cannot reach the bound in the step
   budget. Grid-cell coding theory (Vágó & Ujfalussy 2018) frames multiple modules as a **noise-robust
   error-correcting code** whose benefit materializes under noise *if the modules are independent*. Active
   perception (Bajcsy, Aloimonos & Tsotsos 2018) predicts the payoff is in observation-limited settings.

3. **Exceed single-column capacity (scale the object set).** Hawkins et al. (2017/2019) bound accuracy by
   per-column object capacity, and Rakic's radial-unit hypothesis (2009) establishes that column *number*
   is the biologically scalable parameter — evolution expanded neocortex ~1000-fold in column count at
   near-constant column architecture, primarily buying tangential **capacity**, not per-object
   discrimination. Scaling from 77 to 300–1000+ objects should push few-column models past their storage
   limit and make count accuracy-limiting.

4. **Score under a fixed decision-time budget (anytime inference).** The one axis where grown-3 already
   "lost." Recast the metric as accuracy-at-fixed-step-budget and sweep from tight to generous. Under a
   tight budget more columns supply parallel evidence and should raise accuracy-at-budget (Hawkins et al.
   2017; Gold & Shadlen 2007) — converting the O(*N*²) voting cost into an accuracy advantage and turning
   milbrain's step penalty into a resolvable, theory-predicted win for higher *N*. **This needs no new
   task — only a re-scoring of data in hand.**

5. **Compositional / multi-object scenes.** Place several objects per episode so columns must anchor to
   different sub-objects and vote about *where* others should sense — the displacement/heterarchy mechanism
   (Hawkins, Leadholm & Clay 2025), with a biological substrate in object-vector cells (Høydal et al.
   2019). A single column cannot cover a composition, so more (specialized) columns become genuinely
   load-bearing for scene-level accuracy.

6. **Continual / class-incremental learning.** Grow the object library over sessions (CORe50; Lomonaco &
   Maltoni 2017); per-column capacity saturates so specialized added columns preserve accuracy — the
   ViT-vs-Monty continual-learning gap the TBP papers highlight.

## 4. The methodological gate before any "grown beats designed"

The NAS-rigor literature turns three requirements into non-negotiables for a dominance claim:

- **A random-architecture control arm** (Li & Talwalkar 2019; Yu et al. 2020). A "grown beats designed"
  claim is meaningless until a *random* column-count / random-voting arm is shown to underperform both —
  proving the axis is resolvable at all. Its absence is exactly why the current null is ambiguous between
  "growth is neutral" and "the task can't resolve architecture."
- **A latency-honest compute model.** `compute_total` is O(*N*²)-voting-dominated, so "cheaper" is nearly
  automatic for smaller *N*. Price the +4 % integration steps explicitly (per-step FLOPs; node-count-matched
  graphs) so the trade is scored on one currency.
- **Fresh-seed confirmation** of any winner (winner's-curse guard), and a direct **measurement of
  inter-column error correlation *r*** — the single number that, per Zohary (1994) and Wohrer & Machens
  (2015), predicts whether *N* can ever help before spending compute on a larger frontier.
- **Consider activity-dependent growth.** Biology grows *and* refines cortex under activity — an
  over-produced scaffold pruned by critical-period plasticity (Hensch 2005; Rakic 2009) — and NEAT
  complexification protects new structure before judging it (Stanley & Miikkulainen 2002). milbrain's
  fixed-*N*-then-identical-pretraining protocol may under-optimize added columns and cannot discover the
  task-appropriate *N*; adding columns *during* learning conditioned on error is both fairer and more
  faithful.

## 5. Recommended next experiments, prioritized

**Tier 1 — free or cheap; can sharpen or flip the current verdict with no new task.**

1. **Anytime re-scoring.** Recompute accuracy-at-fixed-step-budget for the existing grown-*N* data; plot
   the anytime curves. Tests whether grown-3's step cost becomes an accuracy loss under time pressure —
   and whether higher *N* already wins in the budgeted regime. *(data in hand)*
2. **Cost-normalized fitness.** Re-rank the same arms under accuracy-per-compute / bits-per-joule with an
   explicit O(*N*²) voting penalty; grown-3 (equal accuracy, 36 % compute) becomes the winner rather than a
   wall-clock-denied tie. *(re-analysis)*
3. **Measure inter-column error correlation *r*.** Compute pairwise vote/error correlation on the 77-object
   data and fit accuracy(*N*) and steps(*N*) to the *K*–*w* SNR model. High *r* would say the bottleneck is
   correlation, not count — *before* any larger sweep. *(cheap, diagnostic)*
4. **Random-architecture control.** Add a random-count / random-voting arm to close the NAS-rigor gap.
   *(cheap, mandatory for later claims)*

**Tier 2 — one task manipulation; the experiments most likely to make growth *resolvable*.**

5. **Decorrelation / heterogeneous columns** — *the single highest-leverage experiment.* Distinct sensor
   patches or feature channels per column; regress accuracy-gain-per-column on measured (1 − *r*). If gain
   tracks decorrelation, the design rule becomes "evolve diversity, not count."
6. **Occlusion / partial-observability sweep** — cap coverage / occlude a fraction *f*; sweep *f* and test
   whether accuracy(*N*) turns monotone-increasing.
7. **Noise × *N* surface** — graded sensor noise; test whether the per-column accuracy benefit *rises* with
   noise, as an error-correcting-voting (Condorcet-jury) account predicts.

**Tier 3 — the thesis-defining, higher-cost directions.**

8. **Capacity stress** — scale to 300–1000+ objects to push past single-column capacity.
9. **Compositional multi-object scenes** — object-vector-style displacement voting; the TBP-native route to
   non-redundant columns.
10. **Generative indirect encoding at scale** — grow column count *and* sparse voting topology jointly from
    a CPPN/ES-HyperNEAT genome under a multi-objective (accuracy + FLOPs) Pareto search, in a resolvable
    regime — the [research plan](research-plan.md)'s intended method, tested where indirect encoding is
    theoretically expected to pay off (larger *N*, geometric regularity).
11. **Activity-dependent growth + epistemic motor policy** — add columns during learning conditioned on
    error; replace the fixed movement policy with an information-gain policy (Mirza et al. 2016) that should
    cut steps-to-consensus most for low-*N* arms.

**If only one thing:** run the **decorrelation experiment (5) inside a noise-or-occlusion regime (6/7),
with a random control (4) and the anytime metric (1).** It targets the *mechanism* the whole literature
identifies (the correlation ceiling), is theory-predicted to convert the null into a positive, costs one
task manipulation, and yields a decisive result either way — decorrelated growth raises accuracy (the
thesis wins) or it does not (strong evidence the null generalizes). Both are publishable.

## 6. Reading map — sources to seed the deeper search

Grouped by theme; all citation-verified. Full entries with DOIs/URLs in [`references.bib`](../references.bib).

- **TBT & column count** — Hawkins, Ahmad & Cui 2017 · Hawkins et al. 2019 · Clay/Leadholm/Hawkins 2024 ·
  Leadholm et al. 2025 · Hawkins, Leadholm & Clay 2025 (heterarchy) · Mountcastle 1978 · Horton & Adams 2005.
- **Degeneracy & redundancy** — Edelman & Gally 2001 · Prinz, Bucher & Marder 2004 · Dalgleish et al. 2020
  (minimal ensembles for perception).
- **Efficient coding & wiring economy** — Barlow 1961 · Attwell & Laughlin 2001 · Lennie 2003 · Chklovskii,
  Schikorski & Stevens 2002 · Levy & Baxter 1996 · Samu, Seth & Nowotny 2014 (wiring cost → small-world).
- **Speed–accuracy & evidence accumulation** — Gold & Shadlen 2007 · Bogacz et al. 2006 · Wohrer & Machens
  2015 (*K*–*w* duality) · Wong & Wang 2006 (attractor consensus).
- **Ensemble / pooling correlation** — Tumer & Ghosh 1996 · Zohary, Shadlen & Newsome 1994 · Rosenbaum,
  Trousdale & Josić 2010 · Li et al. 2024 (MoE in continual learning).
- **Reference frames & sensorimotor** — Lewis et al. 2019 · Vágó & Ujfalussy 2018 (grid-cell error-correcting
  code) · Whittington et al. 2020 (Tolman-Eichenbaum Machine) · Høydal et al. 2019 (object-vector cells) ·
  Mirza et al. 2016 (active inference) · Bicanski & Burgess 2018 (egocentric↔allocentric).
- **Development & "growing" architecture** — Rakic 2009 (radial-unit hypothesis) · Hensch 2005 (critical
  periods).
- **Neuroevolution / indirect encoding & NAS rigor** — Stanley & Miikkulainen 2002 (NEAT) · Gauci & Stanley
  2009 (HyperNEAT) · Stanley, Clune, Lehman & Miikkulainen 2019 · Real et al. 2019 (AmoebaNet) ·
  Li & Talwalkar 2019 · Yu et al. 2020.
- **Task regimes / benchmarks** — Bajcsy, Aloimonos & Tsotsos 2018 · Barbu et al. 2019 (ObjectNet) ·
  Lomonaco & Maltoni 2017 (CORe50).

## 7. How this was built (and one honesty flag)

This synthesis came from a six-lens adversarial literature search (one lens each for degeneracy/efficiency,
TBT/column-count, speed–accuracy, ensemble voting, development/neuroevolution, and task-regime/benchmarks),
each grounded in the actual milbrain result, followed by an independent **citation-verification pass**:
every source was checked to be a real, retrievable work. Of 46 unique citations, **45 verified**; one was
mis-attributed — "Mosheiff et al. 2017, *Robust and efficient coding with grid cells*" is in fact
**Vágó & Ujfalussy (2018)**, *PLoS Computational Biology* — and is cited in its corrected form above. No
claim here rests on an unverified reference.

---

*This is a directions document, not a results claim: the experiments above are proposed, not run. What is
established is the [column-count result](../results/growing-columns.md) and the literature's convergent
reading of it — that the hand-designed column count is load-bearing for **latency and capacity**, not
clean-task **accuracy**, and that the resolvable next step is to move to a decorrelated, evidence-limited
regime with the rigor controls the architecture-search literature demands.*
