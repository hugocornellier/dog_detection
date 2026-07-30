# Delegate benchmark models (not committed)

`integration_test/gpu_delegate_bench_test.dart` needs three variants of the same
landmark weights here. They are ~11 MB each and derived, so they are gitignored
rather than committed: 33 MB of regenerable binaries does not belong in a published
package.

Regenerate from `dogs-in-the-wild-ml`:

```bash
cd ~/PycharmProjects/dogs-in-the-wild-ml
EX=~/IdeaProjects/dog_detection/example/assets/gpubench

# 1. What ships today: Keras export with a dynamic batch dimension, so every
#    TRANSPOSE_CONV computes its output shape at run time.
cp artifacts/small_v3large_384_long/dog_face_landmarks_384_float16.tflite \
   $EX/landmarks_dynamic_v4.tflite

# 2. Static shapes (batch pinned to 1), deconv still carries a fused ReLU so the
#    opcode stays at TRANSPOSE_CONV version 4.
python scripts/reexport_static.py \
  --keras artifacts/small_v3large_384_long/best.keras \
  --out   $EX/landmarks_static_v4.tflite

# 3. Same, with the ReLU moved into a separate RELU op, dropping the opcode to
#    version 3.
python scripts/unfuse_transpose_conv_relu.py \
  --src $EX/landmarks_static_v4.tflite \
  --dst $EX/landmarks_static_v3.tflite
```

All three are numerically equivalent to the shipped model (max per-coordinate
difference 6.6e-07 over the full 480-image DogFLW test split). They differ only in
graph shape, which is what the benchmark isolates.
