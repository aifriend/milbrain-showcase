# The specialists finally meet a strong opponent — and a tree wins

*Every architectural result in this programme had been measured against weak opponents — a nearest-neighbour
lookup or a plain small neural net. That is the kind of control that flatters structure. So we re-ran the
contest against the methods that actually win at this data size, with identical data and **equal tuning
budgets**, pre-registered in advance with **no predicted winner** — which was just as well.*

Companion to [The wall is the model of the physics](the-transition-wall.md), whose closed arc set the stage.

---

## Why this experiment

The agency arc's positive result — object-factored structure plans on novel arrangements where a monolith
collapses, and 10× the data does not rescue it — survived every control we threw at it, including a stronger
monolith function class. But there is a stronger sense of "strong opponent": not a better *version* of the
same weak learner, but the **algorithms that win small-data tabular problems for a living** — gradient-boosted
trees, modern set/attention architectures, expert mixtures. None of those had ever been run here.

The sharpest small-data problem the programme has produced is the one hidden bit from the slide-2d world:
*when you push a piece of furniture, is there something wedged directly behind it?* Every honest learner we
had built sat between chance (0.51) and 0.72 balanced accuracy on that bit, where reliable planning wants
~0.90. The one description that "solved" it was ruled [cheating](the-transition-wall.md) — it printed the
answer at a fixed position on the page.

The rule to be learned is, in one sentence, a **membership test**: *does the set of furniture positions
contain the cell two steps in the direction of the push?* That is notable because one family of architectures
— attention — is quite literally that operation: pose a question (from the action), match it against a set
(of positions). If structure was ever going to win somewhere, it was here.

## The rules, fixed before anything was fitted

- **Identical data for every arm** — the same ~475 decisive examples, drawn from the same frozen pool; a
  held-out block of scenes for scoring (6,000 sampled situations).
- **Equal tuning budget for every arm — 30 random configurations each**, drawn from pre-registered search
  spaces, selected on an inner split that never touches the held-out block. The full tuning log is part of
  the result, reported as an explicit dimension of each arm — because at this size, tuning can matter more
  than architecture (on about a third of datasets, by one large study).
- **The leak test from the previous arc is binding.** Any arm whose inputs let it *read* the answer at a
  fixed position — or whose trained internals learn to — is disqualified from the verdict and may only be
  reported as a labelled upper bound. New for this gate: the same test one layer deeper (inside the trained
  networks), and a behavioural check that a "set" arm's answer really does not depend on the order of the
  set.
- **A mandatory twin.** One expert-mixture arm must be compared against a single expert of *matched total
  size* fed identical input — a control borrowed from a result in deep RL, where "mixture" gains turned out
  to come from the input format, not the experts. Without the twin, a mixture win is uninterpretable.
- **No predicted winner.** Both obvious guesses — "trees will be hard to beat" and "mixtures will overfit at
  ~500 examples" — had failed a pre-check against the literature, so neither was registered.

The roster: a Set Transformer (the favourite — attention *is* the membership test), an Interaction-Network
GNN (2016-era message passing; if the specialists merely tie that, the novelty claim needs defending), an
expert mixture and its matched twin, a deliberately weak sum-pooling ablation, and the monoliths: a tuned
neural net, gradient-boosted trees, and a recent foundation model for small tables (TabPFN).

## The result

Balanced accuracy on the one hidden bit, held-out scenes (higher is better; 0.50 is a coin flip):

| arm | score |
|---|---|
| **gradient-boosted trees** | **0.870** |
| GNN (message passing) | 0.750 |
| tuned neural net | 0.621 |
| sum-pooling ablation | 0.614 |
| expert mixture | 0.587 |
| **Set Transformer (the favourite)** | **0.580** |
| matched single-expert twin | 0.516 |
| TabPFN | not run — its weights need an interactive license step this machine can't do (recorded, not hidden) |

**VERDICT (pre-registered): MONOLITH-WINS.** The best structural arm trails the trees by **0.12** with the
confidence interval clear of zero (−0.134 to −0.106). Every arm passed every leak check, so the table above
is the whole contest, honestly fought.

## Three things worth noticing

**The favourite finished below the old baseline.** The Set Transformer didn't just lose to the trees — it
scored **0.580, under the 0.664** of the project's plain reference learner. The reasoning that made it the
favourite was sound: the rule *is* a query-conditioned membership test, and attention *is* that operation.
What the result says is that **being expressible by an architecture is not the same as being findable at
~475 examples.** The 2016-era GNN did markedly better (0.750) — message passing over "which piece is where"
is apparently the easier bias to train here — but still nowhere near the trees.

**The experts did beat their twin — and it didn't matter.** The expert mixture outscored its matched single
expert by +0.071 (interval clear of zero), so the mixture mechanism itself is real here, not a formatting
artifact. Both arms, however, sit more than 0.28 below the trees. Structure-over-capacity is measurable
*within* the family and irrelevant *against* the opponent.

**Same facts, better reader.** The trees were given exactly the same input description as the old reference
learner — the plain sorted list, no special encoding. That description scores 0.664 with a fixed neural net
and **0.870 with a boosted tree**. After the previous arc established the wall was *not the format* of the
input, and this gate establishes it is *not the readout architecture*, what remains is the **learner class**
— and on this problem, at this size, the modern tabular learner is simply better at it.

## Does it plan better, though?

Accuracy on the bit is the primary number; the one the programme cares about is whether the agent escapes
the room. Each learner was wired back into the planner and measured end-to-end (against a baseline that
ignores the rule; the bar is recovering 20% of the gap to a perfect model):

| | perfect physics (ceiling) | rule-ignoring baseline | **trees** | GNN | others |
|---|---|---|---|---|---|
| with a learned sense of distance | 93.8% | 7.3% | **45.5% — clears the bar** | 24.4% — just misses | ≤ 13.8% |
| with a perfect sense of distance | 100% | 34.1% | **54.5% — clears the bar** | 40.3% | ≤ 31.8% |

Only the trees clear the bar, under both conditions — the accuracy winner also moves the number that
matters. And the limit, stated plainly: 45% is still a long way from the 94% ceiling. **The wall from the
previous arc stands. The best modern learner cuts the distance to it by about half — no more.**

## What this does and doesn't say

This is one world, one hidden fact, one data size. It says that *here*, specialists and structure-first
learners lost to gradient-boosted trees under a fair, tuning-equalized, leak-screened contest — the third
clean negative this programme has produced with its own instruments (after the column count and the voting
motif). It says nothing about attention, mixtures, or trees in general, and it does not touch the agency
arc's positive result, which is about *transfer given a composition rule* — a different question.

Two caveats are recorded with the numbers: TabPFN remains unrun (an environment limitation, mechanical to
fix — its protocol is frozen at a single default run, no tuning); and the inner-split scores used for tuning
(0.95+) overstate held-out performance for *every* arm — selection was paired and identical across arms, so
the ranking is the readable content, not the absolute tuning numbers.

## Where this leaves the programme

The original thesis — that growing the architecture would find something hand-design misses — has now been
tested at every scale this project can reach: the **count** (flat, and enumeration beats search), the
**wiring** (no better than random), and the **specialists** (beaten by a tree at matched data and tuning).
What survives untouched is the one positive result: object-factored structure *does* pay for compositional
planning and transfer — with the composition rule still supplied, not learned. The open questions that
remain are the ones the negatives cleared a path to: whether a value can be bootstrapped from experience
rather than taught by an oracle, and what environment could make a learned composition rule worth having.

*Full gate text, arm roster, tuning logs, and the result record live in the private implementation
repository.*
