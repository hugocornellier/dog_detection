## 2.0.0

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
