## 4.1.0

* Depend on `animal_detection ^4.1.1` and `flutter_litert ^3.9.1`. The
  flutter_litert release updates Android's CompiledModel runtime to LiteRT
  Next 2.2.0.
* The example app depends on `camera_desktop ^1.2.2`.
* No API changes.

## 4.0.0

* **Detections that are not dogs are now dropped instead of returned.** In `full`
  and `poseOnly` modes the species classifier's label is checked before a
  [Dog] is emitted. Previously every animal the body detector found was
  returned as a `Dog`, with dog face landmarks run on it, whatever the
  classifier said. A `Dog` that is not a dog breaks the guarantee its own type
  makes, so these are now filtered out. Callers who want every animal
  regardless of species should use `animal_detection` directly.
* **This is a behaviour change.** Code that counted on receiving one result per
  detected animal will see fewer results. Nothing else about the returned data
  changed.
* **Near-miss classes are recovered rather than lost.** The package now ships its
  own `species_mapping.json` rather than reading `animal_detection`'s. It maps
  the domestic block (ImageNet 151-268, 275) plus a `wild_canid` block
  (269-274: timber/white/red wolf, coyote, dingo, dhole), whose members are most often a domestic
  dog the classifier placed on a neighbouring class. Those are returned as
  `species: 'dog'`. Every other class resolves to `unknown_animal` and is
  dropped, which includes the clothing and object classes a person is most
  likely to be assigned.
* **`breed` is now null for the near-miss block.** The animal is still returned,
  but the label is withheld rather than naming an animal it probably is not.
  `breed` was already null when classification did not run; this adds a third
  case. See the dartdoc on [Dog.breed].
* Deliberately excluded: hyena (276), which is a feliform rather than a canid. The face
  landmark model never saw it and, being a regressor with no confidence
  output, would emit confident but meaningless landmarks with no signal that
  anything was wrong.
* Added `minSpeciesConfidence`, an optional second filter on classifier
  confidence. Defaults to `0.0`, meaning off. It is not comparable with
  cat_detection's value: the classifier is a 1000-class ImageNet model and this
  is one class's softmax probability, so mass splits across the 125 classes a
  dog occupies versus a different count for a cat. Tune it against your own
  imagery.
* `faceOnly` mode is unchanged. It runs no body detector and no classifier, so
  no species exists to gate on, and the caller has already asserted the subject.
* **Fixed: a cropped `cv.Mat` passed to `detectFromMat` returned no detections.**
  `Mat.data` ignores row stride, so a non-continuous Mat, which is what
  `mat.region(...)` returns, was read as though its rows were tightly packed
  and arrived scrambled. Passing a cropped view produced zero detections or
  nonsense labels; the same crop with `.clone()` worked. Non-continuous input
  is now packed automatically, so no `.clone()` is needed at the call site.
  `face_detection_tflite`, `pose_detection` and `hand_detection` already
  guarded against this; this brings the remaining packages in line.
* Fixed a gap inherited from `animal_detection`'s mapping: ImageNet class 268,
  `Mexican hairless`, was absent from the dog block. It resolved to
  `unknown_animal`, which was harmless before this release but would now cause
  that breed to be dropped. It is included here.
* **The bundled model files are now explicitly CC BY-NC 4.0, non-commercial
  use only.** The Dart source code remains Apache 2.0 and is unchanged. Only the
  licensing statement changed: nothing about the weights themselves is
  different from 3.0.1, and this does not retroactively grant or remove any
  right. It records the position accurately for the first time.
  `assets/models/dog_face_landmarks_full.tflite` and
  `assets/models/dog_face_localizer.tflite` are trained on DogFLW, which is
  CC BY-NC 4.0. The dataset's authors were asked directly how they wanted
  derived weights licensed, asked for CC BY-NC 4.0 to stay consistent with the
  source data, and granted permission to publish them on that basis. Using this
  package in a commercial product runs those weights, which that license does
  not permit; for commercial use, contact the dataset authors at the
  Tech4Animals Lab, University of Haifa. See the new `NOTICE` file.
* **Requires `animal_detection` 4.1.0**, which documents its own bundled
  SuperAnimal body-detection and pose models as academic/non-commercial only
  and non-transferable. That restriction is independent of the one above: it
  comes from the Mathis Laboratory's checkpoints rather than from DogFLW.
  In practice the whole pipeline is non-commercial, by two separate routes, and
  clearing one would not clear the other.
* The weights are now published on their own at
  https://huggingface.co/hugocornellier/dog-face-landmarks, alongside a higher-accuracy
  variant better suited to server-side use, and the training code is public at
  https://github.com/hugocornellier/dog-face-landmarks-training.
* Depend on `flutter_litert ^3.9.0`, `opencv_dart ^2.2.2`, and
  `dartcv4 ^2.3.1`. The direct `dartcv4` constraint exists only so resolution
  can never keep a `dartcv4` release whose iOS CMake hook hardcodes a 12.0
  deployment target, which Xcode 27 rejects; no Dart source imports it.
* Also require `hooks ^2.0.0`. The `dartcv4 2.3.1` link hook uses the hooks 2.x
  `LinkInput` API but still accepts hooks 1.x, so a lockfile that kept hooks
  1.x failed every profile and release build with a `recordedUses` compile
  error. The floor makes `pub get` move `hooks` forward (and with it
  `code_assets` and `objective_c`). No Dart source imports it either.
* Raise the floors to Dart 3.10 and Flutter 3.47.5. Earlier Flutter releases
  pin `meta 1.18.0` through `flutter_test`, which cannot coexist with
  `dartcv4 2.3.1`.
* Building for iOS with Xcode 27 needs an iOS 15 deployment target. Set the
  Runner target (and `platform :ios` in the Podfile) to 15.0 or newer and add
  this to the app's `pubspec.yaml`; hook user-defines are only honoured from
  the root package, so a dependency cannot supply it for you:

  ```yaml
  hooks:
    user_defines:
      dartcv4:
        ios:
          deployment_target: '15.0'
  ```

  Run `flutter clean` afterwards so the cached OpenCV build is regenerated.
* Remove the unused direct `meta` dependency.
* Verified with the hosted `animal_detection 4.1.0` and `flutter_litert 3.9.0`
  on macOS 27, Xcode 27, and the iOS 27 simulator.

## 3.0.1

* **Re-exported both face models with static shapes so GPU backends can run
  them.** Trained weights are unchanged; only the export path changed. The
  previous models were converted with `from_keras_model`, which leaves the
  batch dimension dynamic and emits SHAPE / STRIDED_SLICE / PACK in the graph
  tail. Every GPU backend refuses a graph with dynamic-sized tensors, so both
  stages ran on CPU on every platform, and switching between Interpreter and
  CompiledModel changed nothing because both fell back to the same CPU path.
  Converting from a batch-1 concrete function removes those ops
  (dog_face_localizer 689 to 597 ops, dog_face_landmarks_full 295 to 283).
  The landmark model additionally has its deconv ReLU moved out of
  TRANSPOSE_CONV into a separate RELU op, dropping the opcode from version 4
  to 3, which is what lets CompiledModel's GPU accelerator claim the head.
* Output parity against the 3.0.0 models is 0.0 (localizer) and 4.17e-07
  (landmarks), so detection quality is unchanged.
* **`useCompiledModel` now defaults to true.** The re-exported graphs are
  accepted by CompiledModel with the default `{gpu, cpu}` accelerator set,
  which is the fastest configuration measured on every Apple platform. The
  existing per-stage try/catch still falls back to the Interpreter if
  CompiledModel construction fails.
* **The landmark stage now defaults to the GPU delegate instead of auto.**
  XNNPACK claims the deconv region with a kernel slower than TFLite's built-in
  ruy one, so on the re-exported graph XNNPACK is slower than bare CPU. Auto
  resolves to XNNPACK on Android, macOS, Linux and Windows, so leaving it on
  auto would have made the landmark stage slower than 3.0.0. Pass
  `landmarkPerformanceConfig` to override. Platforms with no GPU delegate fall
  through to bare CPU, which measures the same as 3.0.0 on this graph.
* Require `animal_detection` ^3.0.1, which ships its live-camera APIs and
  updated native example and restores complete pub.dev package analysis.
* Measured on macOS M4 Max, flutter_litert 3.9.0, 25 iterations after 8 warmup,
  median of `sync_p50_ms`:

  | stage | 3.0.0 best | 3.0.1 best |
  | --- | --- | --- |
  | localizer | 7.94 ms (XNNPACK) | 1.69 ms (CompiledModel {gpu, cpu}) |
  | landmarks | 26.64 ms (XNNPACK) | 3.85 ms (CompiledModel {gpu, cpu}) |

## 3.0.0

* Add opt-in LiteRT Next CompiledModel support to `DogDetector.initialize()`
  and the new `DogDetector.create()`. `useCompiledModel` defaults to false;
  `accelerators` defaults to GPU with CPU fallback and `precision` to fp32.
* Route the selected backend through the worker isolate and every active stage:
  animal body detection, species classification, body pose, face localization,
  and face landmarks. Each compiled graph is numerically verified; unsafe
  graphs retry on CPU or fall back only that stage to Interpreter.
* Add a macOS full-pipeline parity integration test comparing body boxes and
  scores, species, every pose point, the face box, and all 46 face landmarks in
  Interpreter, CompiledModel CPU, and requested GPU+CPU modes.
* Remove the deprecated `DogDetectorIsolate`. `DogDetector` has owned its
  background isolate since 2.0.0 and is now the package's only detector class.
* Require `animal_detection` ^3.0.0 and keep `flutter_litert` ^3.8.0.
* Add `detectFromCameraFrame()` and `detectFromCameraImage()`, keeping camera
  pixel conversion, rotation, downscaling, and inference in the detector
  worker. The native example now matches the face, pose, and hand examples with
  live camera, still image, and smoothed video-file demos.

## 2.1.0

* **Default precision is now `Precision.fp32` instead of `fp16`.** This changes
  numeric output. `flutter_litert` 3.8.0 changed its own default for the same
  reason: across 29 published detection models measured on five GPUs, fp16
  matched a plain-CPU reference for only about a fifth of them, while fp32
  matched every model that compiled. These graphs emit pixel-space coordinates
  and landmark positions, and fp16 carries about three decimal digits of
  mantissa, so the error lands directly on output geometry. The cost is real and
  worth stating plainly: fp32 is a median 29.9% slower on GPU across those five
  GPUs, with Apple M4 the lone exception at 6.5% faster. Pass
  `precision: Precision.fp16` explicitly to restore the previous behaviour,
  ideally per model and validated on your target GPU.
* Pin `flutter_litert` to `^3.8.0`.

## 2.0.0

* Documented `DogDetectionMode.faceOnly` properly. Behavior is unchanged, but
  it was described only as "legacy behavior, no SSD". It runs the face localizer
  on the whole letterboxed image, which is the input the localizer was trained
  on, and skips the roughly 23MB of body-stage models entirely. The localizer
  emits a single box, so the mode returns at most one face however many dogs are
  present, and the returned `Dog` has no species, breed or pose.

* **Removed** `DogLandmarkModel.ensemble`. Swapping the bundled 384px model to
  MobileNetV3Large left the ensemble mixing backbones: the two downloaded
  members are still EfficientNetV2S, so the published accuracy figure, measured
  when all three members shared a backbone, no longer described what the mode
  actually ran. Re-validating it was not worthwhile. The EfficientNetV2S members
  measured 156 ms and 242 ms per inference against the bundled model's 83 ms, so
  the mode cost roughly 960 ms/frame and 109 MB of downloads. Unlike the single
  bundled model it was never re-measured after the swap, so it was returning
  results of unknown quality. `DogDetector.isEnsembleCached()` is removed with
  it. `DogLandmarkModel.full` is unchanged and remains the default.

  The `v0.0.1-models` GitHub release is retained so existing 1.x installations
  keep working.

* `DogDetector` now runs the whole pipeline in a background isolate that it owns.
  `initialize()` loads the model assets on the main isolate (where `rootBundle`
  is available) and transfers them into a worker it spawns, so detection no
  longer runs on the calling thread. This makes `DogDetector` the single entry
  point for the package.

* **Deprecated** `DogDetectorIsolate`. It is now a thin delegate to
  `DogDetector` and will be removed in the next major release. Migration is a
  rename: `DogDetectorIsolate.spawn(...)` becomes `DogDetector(...)` plus
  `await initialize()`, `detectDogs` becomes `detect`, and `detectDogsFromMat`
  becomes `detectFromMat`. `onDownloadProgress` moves from `spawn()` to
  `initialize()`.

* `DogDetector.detectFromMat` now takes `imageWidth` and `imageHeight` as
  optional named arguments, defaulting to the Mat's own `cols` and `rows`.
  Existing call sites that pass them keep working.

* `DogDetector.initialize()` no longer accepts `useIsolateInterpreter`, and
  `initializeFromBuffers` is no longer part of the public API. The worker
  isolate owns interpreter creation, so neither had a meaningful effect on the
  public class. The buffer-based entry point now lives on the internal
  `DogDetectorCore`.

* `detThreshold` is now honored on the isolate path. The previous
  `DogDetectorIsolate` never forwarded it to the isolate, so a custom threshold
  was silently ignored and the pipeline ran at the 0.5 default.

* The example app now uses `DogDetector` with default (accelerated) performance
  settings instead of `DogDetectorIsolate` with `PerformanceConfig.disabled`.

* Require animal_detection 2.0.0, which replaces its boxed nested input and
  output tensors with reused flat `Float32List`s handed to TFLite as
  `ByteBuffer`s. Measured on this pipeline over a 3264x2448 photo in profile
  mode with `PerformanceMode.auto`, poseOnly drops from 48.2 ms/frame to
  15.1 ms, a 3.2x speedup on the shared body pipeline. The full pipeline goes
  from 452.1 ms/frame to 114.5 ms, though that figure also includes the
  landmark model swap below rather than the tensor change alone.

* Landmark and pose coordinates shift slightly. animal_detection 2.0.0 fixes
  `ImageUtils.cropAndResize` describing an integral crop with pre-truncation
  floats, which placed landmarks about 0.61px right and 0.52px down of ground
  truth. Measured over the 311-image CatFLW (measured on cat_detection; the same fix applies here) holdout with real localizer boxes,
  that cost 0.255 NME_IOD, rising to 1.14 at the 95th percentile, with 72% of
  images improving. `_pipelineVersion` is bumped to `pipeline_v3` accordingly,
  so downstream caches re-evaluate stored detections.

* `AnimalPoseModel.hrnet` now works. animal_detection was requesting
  `superanimal_hrnet_w32_256_float16.tflite` while its release publishes
  `superanimal_hrnet_w32_float16.tflite`, so selecting HRNet failed with an
  HTTP 404 on first use and had never worked.

## 1.5.0

* Replace the bundled dog face landmark model with a MobileNetV3Large backbone
  (128-channel deconv head) trained on DogFLW at the same 384px input. The asset
  drops from 54.6 MiB to 11.0 MiB (57.3 MB -> 11.6 MB), a 4.9x reduction, and
  accuracy improves slightly. Evaluated over all 480 DogFLW test images in
  absolute image-pixel space at the training crop geometry, NME_IOD is 8.04
  versus 8.21 for the previous EfficientNetV2S model. Every facial region is
  equal or better except mouth (+0.10); both ears, both eyes, nose bridge and
  nostrils improve. TFLite `invoke()` also measured about 4x faster on desktop
  CPU with XNNPACK (134 ms vs 546 ms at 4 threads).

  The input/output signature (float32 `[1, 384, 384, 3]` -> float32 `[1, 92]`)
  is unchanged, so this is a drop-in replacement requiring no caller changes.

  Caveat on the accuracy figures: DogFLW's test split is also used as the
  validation set during training (early stopping and best-weight restoration
  monitor it), so both numbers are optimistic in absolute terms. The new model
  was also given a longer fine-tuning schedule (400 epochs vs 200), so the
  improvement is not purely architectural.
* Bump the pipeline component of `DogDetector.modelVersion` to `pipeline_v2` so
  downstream caches holding detections produced by the old model re-evaluate.
* Declare the bundled models' input resolutions as named constants rather than
  repeating integer literals at each call site. A mismatch between the literal
  and the bundled model is not reported as an error by the interpreter, which
  resizes the input tensor and then emits garbage coordinates, so the two call
  sites for each model could previously drift apart silently.
* `DogDetectorIsolate.spawn` now defaults `performanceConfig` to
  `PerformanceMode.auto` (Metal on iOS, XNNPACK elsewhere) instead of
  `PerformanceConfig.disabled`. The isolate is the documented path for live
  camera work, so the previous default silently opted the most
  performance-sensitive callers out of hardware acceleration while the plain
  `DogDetector` constructor already defaulted to auto. Measured on the
  equivalent cat_detection pipeline over a 3264x2448 photo in profile mode,
  acceleration off ran 1716 ms/frame versus 438 ms/frame with auto, a 3.9x
  difference. Callers who relied on the old behaviour should pass
  `PerformanceConfig.disabled` explicitly.

## 1.4.0

* Update animal_detection -> 1.4.0, which replaces its shipped 12,944-line SSD
  anchor table with runtime generation. Detection output is unchanged: verified
  against the real model over 9 images at 100 runs each with identical detection
  counts, bit-identical scores, and a worst-case box coordinate delta of
  9.3e-05 px. The shared library drops from 15,222 to 2,355 lines and the
  compiled binary shrinks by about 32 KB.
* Update flutter_litert -> 3.6.0.

## 1.3.3

* Update flutter_litert -> 3.5.0

## 1.3.2

* Update flutter_litert -> 3.4.1
* Update animal_detection -> 1.3.2

## 1.3.1

* Update flutter_litert -> 3.3.1

## 1.3.0

* Update flutter_litert -> 3.2.0
* Require animal_detection 1.3.0

## 1.2.3

* Update flutter_litert -> 3.1.1

## 1.2.2

* Update flutter_litert -> 3.1.0

## 1.2.1

* Update flutter_litert -> 2.8.3

## 1.2.0

* Update flutter_litert -> 2.8.0
* Complete Swift Package Manager migration: example apps build via SPM without CocoaPods

## 1.1.1

* Remove unused Darwin podspecs for Dart-only iOS/macOS plugin registration.
* Require animal_detection 1.1.1.

## 1.1.0

* Update animal_detection -> 1.1.0
* Update flutter_litert -> 2.5.8

## 1.0.12

* Update flutter_litert -> 2.5.5 

## 1.0.11

* Update flutter_litert to 2.5.3

## 1.0.10

* Update flutter_litert -> 2.5.2

## 1.0.9

* Update flutter_litert -> 2.5.0

## 1.0.8

* Update flutter_litert -> 2.4.1

## 1.0.7

* Update flutter_litert -> 2.4.0

## 1.0.6

* Update flutter_litert -> 2.3.0

## 1.0.5

* Add public `DogDetector.modelVersion` and `DogDetector.modelVersionFor(...)` APIs for downstream cache invalidation.

## 1.0.4

* Update flutter_litert -> 2.2.0

## 1.0.3

* Update flutter_litert -> 2.1.0

## 1.0.2

* Update flutter_litert to 2.0.13
* Update animal_detection to 1.0.2

## 1.0.1

* Update flutter_litert -> 2.0.12 

## 1.0.0

* First stable release. On-device dog face detection and 46-point facial landmark prediction using TensorFlow Lite. Supports Android, iOS, macOS, Windows, and Linux with automatic hardware acceleration.

## 0.0.10

* Update documentation

## 0.0.9

* Update flutter_litert 2.0.8 -> 2.0.10

## 0.0.8

* Enable auto hardware acceleration by default (XNNPACK on all native platforms, Metal GPU on iOS)
* Update flutter_litert 2.0.6 -> 2.0.8
* Update animal_detection 0.0.5 -> 0.0.6

## 0.0.7

* Fix Android hang on sequential detect calls

## 0.0.6

* Fix isolate hanging on sequential detect calls

## 0.0.5

* Update animal_detection 0.0.3 -> 0.0.4

## 0.0.4

* Fix Xcode build warnings by declaring PrivacyInfo.xcprivacy as a resource bundle in iOS and macOS podspecs

## 0.0.3

* Refactor to use shared animal_detection utils

## 0.0.2

- Added homepage and repository to pubspec.yaml

## 0.0.1

- Initial release
- Dog face detection with bounding box
- 46 facial landmark extraction (ears, eyes, nose, mouth/chin)
- DogDetector and DogDetectorIsolate APIs
- Support for iOS, Android, macOS, Windows, Linux
