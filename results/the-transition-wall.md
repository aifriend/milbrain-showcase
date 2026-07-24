# The wall is the model of the physics — not the horizon, and not the value

*The environment search left one design alive. This is what happened when we pushed on it properly, over four
experiments — including two corrections to our own published claims, and a decision **not** to build the
world we had just designed.*

Companion to [Structure, not count](compositional-planning.md), which ends where this begins.

---

## Where we were

An agent that plans needs two separate things: a sense of **how far it still has to go**, and an imagination
of **what its own moves will do**. The previous write-up ended by fixing the first one. Given a decent
estimate of remaining effort, the densest environment we built needed a lookahead of 3 rather than 12 — the
number that had condemned it was a property of our measuring stick, not the world.

But every one of those measurements was taken with **perfect knowledge of the physics**. The agent imagined
its moves using the environment's own rules. That is not a planner; that is a lookup. The honest question was
what happens when *both* halves are learned.

## The result: even a perfect sense of distance cannot rescue a learned model of the physics

We crossed the two factors — the estimate of remaining effort, and the model of what moves do — and measured
end-to-end planning success.

| what the agent uses to imagine its moves | with a *perfect* distance estimate |
|---|---|
| the environment's true rules | **100%** |
| a **learned** model | **7.6%** |

With true physics and a *learned* distance estimate, the agent solves 94–97% of tasks. So the distance
estimate is fine, and the lookahead is fine. **Swap in a learned model of the physics and everything
collapses**, even when the agent is handed a flawless sense of progress.

The mechanism is visible and slightly comic. The learned model produces *impossible* states — it imagines
shoving a block straight through another block — and it does this more the further ahead it plans (9% of its
imagined situations at one step, 49% at three, 89% at twelve). The planner then builds routes through those
impossible situations, commits, and reality refuses.

## The one thing it has to learn, and it is at chance

The environment withholds exactly one fact: *when you push a block, is the cell behind it occupied?* Everything
else — where things are, where the goal is, the boundaries — the agent can see.

Measured directly on that single bit, the reference learner scores **0.513** balanced accuracy. That is a coin
flip. Its apparently respectable ~70% per-step accuracy was almost entirely the easy cases it already knew;
on the bit that decides the task, it had learned nothing.

Two fixes helped, and neither was enough:

- **Give it a cleaner lesson** — train it on *only* the hard call instead of drowning that in easy ones:
  0.513 → **0.664**.
- **Stop it being timid** — it was simply mis-calibrated, refusing far too readily. Retuning where it draws
  the line lifts it to **0.720**, and raises the share of genuinely-free moves it correctly allows from 57%
  to 73%.

Reliable planning needs something around 0.90. We got 0.72.

## The uncomfortable finding: just trying the move beats planning

We then let the agent do something a pure planner never does — when it gets stuck, **execute** a move its
model says is blocked, and see what actually happens. Same step budget; the probes are paid for out of it.

| agent | success (perfect distance estimate) |
|---|---|
| ignores the rule entirely | 34.1% |
| best pure planner | 39.9% |
| **plans, but probes when stuck** | **69.3%** |
| perfect model (ceiling) | 100% |

Trying beats predicting, decisively.

**And that is deflating, not encouraging.** This environment was built to be non-reactive, and we had checked
that: simple reflex policies score 6–14% in it. But that only showed *goal-directed* reflexes fail. It never
showed the hidden fact was **expensive to find out** — and it isn't. One push costs one step, and a pull undoes
it. The agent can simply *buy* the fact instead of predicting it.

That is precisely the reason we rejected an earlier design: *a model of the world earns its keep only when
information is expensive to acquire physically.* The same flaw was in this environment all along, invisible
until someone tried probing.

## So we designed an eighth world — and then did not build it

The obvious response is to make information expensive: a bigger table, a travel budget, fragile objects,
irreversible mistakes. We drafted exactly that. An adversarial review returned **do not build** — the draft
stated each agent's outcome as a design property while fixing the single parameter that decided them, and it
attached the fragility to the wrong object, so the *test* stayed cheap.

Rather than argue about it, we **measured the price instead of choosing it**, in the environment we already
had. We swept the cost of a probe (1, 2, 4, 8, 16 steps, and finally *fatal*) against the tightness of the
budget, and asked whether any combination lets the predictive agent beat both the prober and the
rule-ignoring baseline.

**No combination does.** The reason is structural, and it is the most useful thing this experiment produced:

| probe cost | 1 step | 4 steps | 16 steps | fatal |
|---|---|---|---|---|
| prober | 63.7% | 62.9% | 50.8% | **33.0%** |
| pure planner | 33.0% | 33.0% | 33.0% | **33.0%** |

At an infinite price the prober lands *exactly* on the planner — because it **becomes** the planner. It uses
the same model and only deviates when stuck; make deviating fatal and it stops deviating.

**You cannot win by taxing your competitor into becoming you.** Pricing the test removes the prober's
advantage without adding anything to the model's. A world built on travel costs and fatal mistakes would
demonstrate only that probing had been priced out — a fact about the price, not about the model. So we did not
build it, and the eighth world is not worth building on this rationale.

## Three corrections to ourselves

**We reported a result off one column.** We wrote that the improved learner "loses to a model that ignores the
rule." That was true in one of the two conditions we ran and false in the other — with a *learned* distance
estimate it clearly beats that baseline. We had the numbers and headlined the more striking half. The
corrected version is sharper anyway: *optimism beats a cautious-but-imperfect learner only when the distance
estimate can cheaply throw out impossible situations.* A perfect estimate rejects them for free; a learned one
does not, and there the model's caution earns its keep.

**We printed a number without its unit.** A probe count was a per-seed average reported as though it were a
total, and we read it as "the agent rarely probes." It probes about four times per episode. This is the same
class of error we had corrected elsewhere in the project a day earlier.

**A prediction we registered in advance was simply wrong.** We expected a tight budget to punish the
rule-ignoring baseline, since it wastes moves on pushes that fail. The gap is flat across a threefold range of
budgets. These are deterministic policies in a deterministic world: the baseline does not thrash and run out,
it re-derives the same failing plan. Only the prober benefits from a bigger budget at all. Budget scarcity is
not a lever on a deterministic planner.

## What is actually left

One thing survives all of it. Under a *learned* distance estimate, the model's caution is worth about **8.5
points** over ignoring the rule — and that advantage is unchanged by probe price or budget. It is therefore
not about the economics of information at all. It is about something narrower and more interesting: a learned
sense of progress **cannot recognise an impossible situation**, and scores one as though it were ordinary. The
model's job there is not to predict the physics but to stop the planner from walking into places that cannot
exist.

## We measured that, and it is worse than it sounds

We showed the judge situations that **cannot physically exist** — furniture occupying the same space, because
the agent's imagination shoved one piece through another. A good judge would flag them. Ours flagged **none**.
Worse: **51% of impossible situations it rated better than a typical real one.** The cause is mundane — in all
its training it had only ever been shown situations that can actually occur, so on an impossible one it simply
guessed, confidently.

## The fix that was honest, and the one that cheated

The tempting fix is to *tell* the judge which situations are impossible. We refused it as the candidate,
because you can spot an impossible situation here by **counting the furniture** — so a judge trained to reject
them has been handed the very rule the agent was supposed to discover.

Instead: train **five copies** of the judge on the same ordinary situations, and watch whether they **agree**.
Nobody tells them anything about physics. On real situations they agree closely; on impossible ones they
**scatter — two and a half times more disagreement**. That is the first mechanism in this project that
detects hallucinated situations *without being told the rule*.

We ran the cheating version too, labelled as an upper bound. **It lost.** Forcing the judge to shout
"terrible!" at impossible situations wrecked its ordinary sense of distance — with that judge, even a perfect
imagination planned far worse (97% → 78%). So the shortcut was both dishonest and inferior, which is not the
usual direction of that trade.

## And then the ablation deflated our own headline

Five judges do two things at once: they **average away** individual mistakes, and they **disagree** usefully.
Our first write-up credited the gain to the disagreement. Before publishing, we ran the clean test — same five
judges, ignoring their disagreement entirely.

| where the improvement came from | |
|---|---|
| plain averaging | **~72%** |
| the disagreement signal | **~28%** |

So "self-doubt more than doubles a rule-ignorant agent" is **wrong as we first attributed it**. A five-judge
ensemble does; most of that is ordinary variance reduction. The 2.5× detection result stands untouched — what
changed is how much of the *planning* gain it explains.

Worth one contrast: elsewhere in this project, adding near-identical experts bought nothing, because they made
the same mistakes together. Here, five judges differing only by random seed disagreed enough that averaging was
the *bigger* win. Same move, opposite result, different substrate — which is precisely why the ablation was
worth running rather than assuming.

**What is left is narrower and sharper than when we started:** a separate advisor that models what the world
*refuses* is still not redundant with a judge that knows when it is *uncertain*. Those are two different kinds
of knowing, and only one of them can be had for free.

That question needs no new world. It is the one we are left holding.

---

*Every result here was pre-registered before the data existed, and each experiment reports its own falsified
predictions. The reviews that reshaped these experiments — one of which caught a metric that would have
declared success on an agent that solves 4% of tasks — are part of the record, not an appendix to it.*
