# Why more columns don't help — the correlation bottleneck

[Growing the column count](growing-columns.md) found something it couldn't yet explain: across grown
architectures of 2, 3, 4, and 5 cortical columns, **accuracy was flat** — every arm landed on ~89.4% on
the 77-object task. More columns bought efficiency shape (parallel voting vs. serial integration), but not
a single point of accuracy. That page ended on the obvious question: *why doesn't accuracy rise with N?*

This page answers it, from the data already in hand — **no new compute** — and the answer is specific and
measurable. **The columns make their mistakes on the *same* objects.** Their errors are correlated at
φ ≈ 0.75. Adding more of them adds redundancy, not capability. The bottleneck is inter-column *error
correlation*, not column *count*.

Every figure below was independently reproduced to ±0.000 by four adversarial verification passes — the
same discipline the [reproduction](reproduction.md) and [E1 verdict](growing-columns.md) were held to.

---

## The measurement

For each architecture we recorded, per episode, which columns identified the object correctly, and
computed the correlation of their *errors* across the 77 episodes.

| columns *N* | single-column accuracy | **error correlation φ** | Yule *Q* | P(all columns wrong) | oracle ceiling¹ | actual accuracy |
|---|---|---|---|---|---|---|
| 2 | 88.5 % | 0.798 | 0.990 | 9.7 % | 90.3 % | 89.6 % |
| 3 | 87.0 % | 0.746 | 0.977 | 9.4 % | 90.6 % | 89.4 % |
| 4 | 87.5 % | 0.754 | 0.978 | 8.6 % | 91.4 % | 89.6 % |
| 5 | 88.1 % | 0.753 | 0.981 | 7.3 % | 92.7 % | 89.4 % |

¹ *oracle ceiling* = the accuracy an ideal selector would reach if it always picked a correct column
whenever one existed (= 1 − P(all wrong)). It is the best **any** voting scheme over these columns could
achieve.

The columns' errors are correlated at **φ ≈ 0.75** — and Yule's *Q* ≈ 0.98 says that, relative to the
maximum the class balance allows, the co-occurrence of errors is near-total. The consequence is the whole
story: **the fraction of episodes where *every* column fails sits right at the single-column error rate**
(~7–10%), instead of collapsing toward what independent columns would give — about 1.5% at N = 2, and well
under 0.1% by N = 5. When these columns are wrong, they are wrong *together*. So the oracle ceiling barely
rises with N (~0.6 points per column) and stays ~11 points below 100%, and **the realized accuracy is flat
at ≈ 89.4% from two columns to five.** No number of identical columns breaks a shared-error floor.

That is the result: **on this task the accuracy bottleneck is error correlation among the columns, not
their number.** It is a concrete, falsifiable sharpening of "more columns, more robust": more columns are
more robust only to the extent their errors are *decorrelated*, and here they are not.

## Three checks that keep it honest

**The gap to the oracle is not a votes-counting bug you could just fix.** The oracle ceiling (up to 92.7%)
sits above the realized 89.4%, which tempts the idea that a cleverer vote-combination rule would recover
it. It would not: no *realizable* fusion rule we tested — trust the most confident column, plurality vote,
evidence-weighted vote — beats the current rule by more than ±0.5 points. The oracle gap is *clairvoyant*;
it needs to know which lone column is right, and when correlated columns err together they also err
*confidently*, so the correct minority column doesn't stand out. Correlation, not the fusion rule, is the
wall.

**The shared errors are only partly "just hard objects."** One could dismiss the correlation as a handful
of intrinsically ambiguous objects everything fails on. Partly real — a thin, feature-poor tail (a chain,
a fork, a knife; the top 15 objects carry ~72% of all the all-wrong episodes) — but not the whole story:
the *set* of all-wrong objects overlaps only about 25% between a two-column and a five-column model (≈ 6.5×
what chance would give, but far from identical). So roughly three-quarters of the shared-error mass is
**not** locked to the objects — it is genuinely decorrelatable in principle. It is simply a small quantity
on a near-ceiling task.

**Cost and latency, for completeness.** Because accuracy is conserved while all-to-all voting cost grows
with the square of the column count, the smallest architectures are strictly the most compute-efficient (a
two-column cortex reaches the same accuracy at ~1/6 the compute, a three-column at ~1/3). And the one
reservation the [frontier](growing-columns.md) raised about grown-3 — a ~4% wall-clock cost — turns out not
to be statistically robust (a paired test gives *p* ≈ 0.43); it was a hard threshold reading noise.

## The natural fix is harder than it looks

If correlation is the bottleneck, the obvious next experiment is to *decorrelate* the columns — make them
genuinely different — and see whether accuracy then climbs with N. The cheapest lever is geometric: today
the columns' sensory patches sit almost on top of one another (a ring spanning ~7% of a typical object), so
they see nearly the same thing; widen the ring and they sample different regions.

A deliberately cheap pilot tried exactly this and hit a wall worth reporting. A ring wide enough to
decorrelate the *median* object pushes the patch clean *off* the *small* objects — a die, marbles — where
it observes too few surface points to build an object model at all, and pretraining fails outright.
Widening the ring failed partway through the object set at the larger setting, and even a moderate setting
died on the single smallest object. There is **no global patch-spread** that is simultaneously on-object
for all 77 objects and meaningfully decorrelating, because the objects span a tenfold size range.

The lesson isn't that decorrelation can't work — it points toward levers that keep the patch *centered* on
the object (varying each column's spatial scale, or its feature channels) rather than moving it off. But it
means "just add different columns" is a genuine research programme with its own engineering, not a
configuration change — and it is exactly the kind of dead end worth finding for a couple of dollars rather
than a couple of days.

## Why it matters

- **For the Thousand Brains thesis.** On static object recognition, more columns do not buy accuracy, and
  the reason is measurable: the columns are near-duplicates whose errors co-occur. The lever for capability
  is column **diversity**, not column **count** — a sharper, testable claim than the intuition it replaces.
- **For anyone scaling brain-like ensembles.** Measure inter-module error correlation *before* you scale.
  A high value means every unit you add is redundancy, not capability, no matter how many you stack — the
  ensemble's real capacity is set by how independent its members' failures are. This connects directly to
  redundancy and efficient-coding accounts of cortex: cortical robustness is usually attributed to
  *diverse*, not merely *many*, columns.
- **Honest limits.** This is one task (near-ceiling static recognition of rigid objects) and one model
  family. Under occlusion, heavier sensor noise, or harder object sets the correlation could fall — and a
  higher-error regime is precisely where decorrelation *could* pay, and is the natural next test if the
  diversity levers above prove realizable. The finding here is a clean floor, not a universal law.

---

*Status: a **verified negative** that reframes the program. Column count is not the accuracy lever on this
task — inter-column error correlation is — and the simplest decorrelation lever is geometrically
self-defeating on small objects. The live question shifts from "how many columns?" to "how do we make
columns fail differently?" How this connects to cortical redundancy, efficient coding, and the
speed–accuracy tradeoff is developed in
[the directions report](../theory/directions-from-the-frontier.md). Full experimental detail, the
verification passes, and the analysis code live in the private implementation repository.*
