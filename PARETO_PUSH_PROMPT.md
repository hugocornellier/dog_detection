# Dog landmark model: push the Pareto frontier at ~11MB

You are working on the dog facial landmark model that ships in the
`dog_detection` Flutter package. Your job is to make it better **without giving
anything up**.

## The constraint, stated precisely

Three axes: **size**, **accuracy**, **speed**. You must:

1. Keep the TFLite file at **roughly 11MB**. Not a hard ceiling to game, but this
   is a mobile package and a 54MB model is not acceptable. Treat ~11-13MB as the
   band; anything beyond that has to be justified.
2. **Never regress accuracy or speed.** A win is one of:
   - same speed, better accuracy
   - same accuracy, faster
   - better on both

**This is a Pareto requirement, not a trade.** Giving up 1% accuracy to gain 20%
speed does **not** count and will be rejected. If you can only find trades, say
so plainly rather than presenting one as a win.

## Baseline you must beat (measured, not inferred)

The shipped model is `dog_detection/assets/models/dog_face_landmarks_full.tflite`.
I verified by SHA-256 that it is exactly
`~/PycharmProjects/dogs-in-the-wild-ml/artifacts/small_v3large_384_long/dog_face_landmarks_384_float16.tflite`.

| property | value |
|---|---|
| size | **11.0 MB** (float16) |
| backbone | MobileNetV3Large |
| head | heatmap, 128 channels, dropout 0.1 |
| input | 384x384x3 float32 |
| output | 92 values = 46 landmarks x (x,y), normalized to the crop |
| ops | 295, of which 4 are `TRANSPOSE_CONV` |
| **val NME_IOD** | **8.564** |
| train NME_IOD | 5.397 (so a ~3.17 train/val gap) |
| epochs | 400 (the `_long` preset) |
| dataset | DogFLW, 3853 train / 480 val |
| latency reference | ~91 ms median, TF Python, XNNPACK, 4 threads, M4 Max |

Two caveats about that latency figure, both important:

- It comes from the **Python** TF runtime, so it is only valid for comparing
  candidates against each other **inside the training repo**. Do not compare it
  to any number from the Flutter side.
- The authoritative latency is measured in the Flutter package, where macOS has
  just been fixed (a bazel-built dylib restored ruy multithreading; the
  equivalent cat model went 83.7ms to 26.8ms). So real device latency is far
  below 91ms. If you need an on-device number, measure it in `dog_detection`
  rather than extrapolating.

There is also a known TFLite conversion cost: Keras val NME 0.0280 vs TFLite
sample NME 0.0304. Any candidate must be judged **after** conversion, not on the
Keras number, or you will report a win that does not ship.

## Read these first, in this order

Everything is in `~/PycharmProjects/dogs-in-the-wild-ml`:

1. **`LANDMARK_DETECTION_REPORT.md`** — the living journal. Every experiment
   across 6+ rounds, what worked, what failed, why. This is the single most
   valuable file. Read the "What Worked" / "What Didn't Work" ranked lists and
   the per-landmark error analysis.
2. **`FRESH_CLAUDE_PROMPT.md`** — a previous prompt aimed at a *different* goal
   (pure NME chasing at any size, targeting the paper's 6.52 via ensembles).
   Read it for the analysis, but **its objective is not yours**: it pursues
   12-forward-pass ensembles and 54MB EfficientNetV2S models, which violate both
   the size and speed constraints here.
3. **`NME_PUSH_PLAN.md`** — diagnosis of why this architecture sits where it
   does. Note its date (2026-02-28) and that its baseline is 9.11, now stale.
4. `artifacts/nme_push_results.md` and `artifacts/nme_push_v2_results.md`.

**Treat every "recommended next step" in those documents as stale.** The journal
itself warns that its recommendations section lists things already tried and
failed. Verify against the experiment tables before acting on any suggestion.

## Key context that shapes what is worth trying

- The 54.6MB **EfficientNetV2S** line (`tight_margin_*` artifacts) reaches ~8.82
  single-model, i.e. barely better than the 11MB MobileNetV3Large at 8.564. The
  small backbone is *already competitive*. Do not assume scaling up the backbone
  is the answer; the evidence says it is not, and it breaks the size budget.
- **Ears dominate the error.** Ear NME runs 12-14 against ~5 for eyes, with ear
  tips at 15-18. Any accuracy win almost certainly comes from ears.
- The train/val gap (~3.17) is documented as **structural**, not fixable by
  regularization. Several regularization experiments failed. Do not redo them.
- The head is heatmap-based with SoftArgmax coordinate extraction. The journal
  argues at length that heatmap-MSE supervision plus subpixel-argmax extraction
  (as DeepLabCut does) is the biggest untapped gap. Check the experiment tables
  for whether this was actually run to completion, since one attempt died to a
  machine crash.

## Directions that fit *this* objective

Ranked by how well they respect the Pareto constraint. This is a starting point,
not a script; your own reading may beat it.

**Free accuracy (no speed or size cost):**
- Better coordinate extraction at inference. `scripts/eval_experiments.py`
  already implements a beta sweep and `argmax_with_refinement` (parabolic
  subpixel fit). If it has not been run against `small_v3large_384_long`, that is
  the cheapest possible win: pure post-processing, zero size, negligible latency.
- Heatmap-MSE supervision instead of coordinate-MSE-through-SoftArgmax. Changes
  training only, so inference cost is identical.

**Free speed (no accuracy cost):**
- The 4 `TRANSPOSE_CONV` ops in the deconv head are runtime-shaped (their output
  shape is computed by `PACK`), which is expensive and also triggers an upstream
  LiteRT CompiledModel bug. Static output shapes may be both faster and better
  behaved. Check whether static shapes are achievable via the export path.
- Head width. 128 heatmap channels may be more than needed; if accuracy holds at
  96 or 64, that is size and latency for free.
- Input resolution is 384. The `tight_margin_*` line ran 256 and 320. If a lower
  input holds accuracy, latency drops roughly quadratically. Check the journal
  for what resolution actually cost.

**Riskier, verify carefully:**
- int8 or dynamic-range quantization: big size and speed wins, but usually costs
  accuracy, and accuracy loss is disqualifying here. Only viable if it comes out
  neutral.
- Distillation from the 54.6MB EfficientNetV2S models into the 11MB architecture.
  Costs nothing at inference. But the teacher is only ~0.26 NME better, so the
  ceiling is low.

## How to report

For every candidate, give a table with **all three axes** and be explicit about
which are measured versus estimated:

| candidate | size | val NME_IOD (TFLite) | latency (same harness as baseline) | verdict |
|---|---|---|---|---|

Rules for the report:
- Judge accuracy on the **converted TFLite** model, not Keras.
- Measure latency with the **same** harness and thread count as the baseline, in
  the same process if possible. Never compare across runtimes.
- State the val split explicitly. The 480-image DogFLW val set is small, so a
  0.05 NME difference may be noise. Say when a result is within noise instead of
  claiming a win.
- **Report failures.** A direction that did not work is useful and belongs in the
  journal. Do not quietly drop it.
- Append findings to `LANDMARK_DETECTION_REPORT.md` so the next session inherits
  them.

## Ground rules

- Do not change anything in `~/IdeaProjects/dog_detection` unless a candidate has
  actually won on all three axes and you are shipping it. Training work belongs
  in the Python repo.
- If a change wins, the shipped `.tflite` must be swapped **and** the reference
  metrics in `dog_detection` updated in the same change.
- If nothing wins, that is a legitimate outcome. Say so, document why, and leave
  the baseline alone. Do not ship a trade dressed up as an improvement.
