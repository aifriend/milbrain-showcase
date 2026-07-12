# Reproduction record — results

The "tested and proved" gate. Filled in **from an actual run** on 2026-07-11.

| Field | Value |
|---|---|
| Monty ref (pinned) | `v0.42.0` (commit `61fcea3d`) |
| Env route | containerized, CPU-only (emulated) |
| Rendering | headless software rendering |
| Experiment | `randrot_noise_10distinctobj_surf_agent` |
| Date run | 2026-07-11 |
| Episodes | 100 (10 distinct YCB objects × 10 eval epochs) |
| **Accuracy (official metric)** | **100%** — `Correct (%)` counts `correct` + `correct_mlh`, per the benchmark's own definition. Strict `correct`-only = 99–100% per run. |
| **Documented reference (v0.42.0)** | **100.00% Correct, 0.00% MLH, 30 match steps, 12.85° rotation error, 100 episodes** — verified from the raw `benchmarks/ycb_10objs.csv` (identical across v0.38.0–v0.42.0). |
| N=5 variance study | Official metric: 5×100%. Strict `correct`: **99.2% ± 1.17** (seeds 99/100/100/100/97), **0 misrecognitions** in 500 episodes. |
| Match to docs? | **Exact.** 100% = docs 100%, independently corroborated by match-steps (30 = 30) and rotation error (≈13° vs 12.85°). |
| Mean sensorimotor steps | 30.0 per episode |
| Mean time | 4.8 s/episode (~8 min total, emulated CPU) |
| Pose error (`rotation_error`) | mean ≈13°, max ≈180° (symmetric objects) — separate pose metric, not recognition |
| Objects | banana, bowl, c_lego_duplo, dice, golf_ball, mug, mustard_bottle, potted_meat_can, spoon, strawberry |
| Output | `~/tbp/results/monty/projects/monty_runs/randrot_noise_10distinctobj_surf_agent/eval_stats.csv` |

**Verdict:** ✅ **REPRODUCED (exact)** — Monty recognizes all 10 objects under random 3D rotation +
sensor noise; accuracy, match-steps, and rotation error all match the documented benchmark.
Legitimacy checked (rotations + noise genuinely applied; not the trivial `base` condition).

### Correction (2026-07-12): the "95%" was never real

An earlier version of this file cited a **published 95%** and built a "we exceed the docs / version
drift" story on it. That number was a **WebFetch page-summary hallucination**. The raw benchmark
table (`benchmarks/ycb_10objs.csv`, verified by `curl` at v0.42.0 / v0.40.0 / v0.38.0) reports
**100.00% Correct, 0.00% MLH, 30 match steps, 12.85° rotation error** for this row — and `95`
appears **nowhere** in the 10-object table. So this is an **exact reproduction**, not an
outperformance.

The N=5 study still stands as a consistency check: official metric 5×100%; strict `correct`
99.2% ± 1.17 (seed 4 dropped to 97% via 3 MLH fallbacks); **0 misrecognitions** in 500 episodes.
Root cause of the earlier error: a number taken from a fetch-summary and never checked against the
raw source — the exact failure mode this project is meant to guard against. Seed 0 produced a
wandb-offline dashboard; the detailed one-episode run captured per-step evidence for the viz.
