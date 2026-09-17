<h1 align="center">dog_detection</h1>

<p align="center">
<a href="https://flutter.dev"><img src="https://img.shields.io/badge/Platform-Flutter-02569B?logo=flutter" alt="Platform"></a>
<a href="https://dart.dev"><img src="https://img.shields.io/badge/language-Dart-blue" alt="Language: Dart"></a>
<br>
<a href="https://pub.dev/packages/dog_detection"><img src="https://img.shields.io/pub/v/dog_detection?label=pub.dev&labelColor=333940&logo=dart" alt="Pub Version"></a>
<a href="https://pub.dev/packages/dog_detection/score"><img src="https://img.shields.io/pub/points/dog_detection?color=2E8B57&label=pub%20points" alt="pub points"></a>
<a href="https://github.com/hugocornellier/dog_detection/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-Apache_2.0-007A88.svg?logo=apache" alt="License"></a>
</p>

![Demo](assets/screenshots/demo.png)

On-device dog detection using TFLite models. Detects dogs in images with breed identification, body pose estimation, face localization, and 46-point facial landmarks, all running locally with no remote API.

## Features

- Dog body detection with bounding box (SSD-based)
- Breed identification with confidence score
- Body pose estimation via SuperAnimal keypoints
- Face localization and 46-point facial landmark extraction (DogFLW)
- Truly cross-platform: compatible with Android, iOS, macOS, Windows, and Linux
- Detection always runs in a background isolate that `DogDetector` owns, so the UI never blocks
- Configurable performance with XNNPACK, GPU, and CoreML acceleration

## Quick Start

```dart
import 'package:dog_detection/dog_detection.dart';

final detector = DogDetector(mode: DogDetectionMode.full);
await detector.initialize();

final dogs = await detector.detect(imageBytes);
for (final dog in dogs) {
  print('${dog.species} at ${dog.boundingBox}');
  // breed is null when the classifier landed on a near-miss class
  if (dog.breed != null) print('Breed: ${dog.breed}');
  print('Pose keypoints: ${dog.pose?.landmarks.length}');
  print('Face landmarks: ${dog.face?.landmarks.length}');
}

await detector.dispose();
```

## Dog Face Landmarks (46-Point)

The `landmarks` property returns a list of 46 `DogLandmark` objects representing key points on the detected dog face.

### Landmark Groups

| Group | Count | Points |
|-------|-------|--------|
| Left ear | 7 | Ear outline and tip |
| Right ear | 7 | Ear outline and tip |
| Left eye | 4 | Eye corners and center |
| Right eye | 4 | Eye corners and center |
| Nose bridge | 2 | Bridge top and bottom |
| Nose ring | 8 | Nostril outline |
| Mouth/chin | 14 | Lips, jaw, and chin |

### Accessing Landmarks

```dart
final DogFace face = faces.first;

// Iterate through all landmarks
for (final landmark in face.landmarks) {
  print('${landmark.type.name}: (${landmark.x}, ${landmark.y})');
}
```

## Species Filtering

Only dogs are returned. In `full` and `poseOnly` modes the species classifier's
label is checked before a result is emitted, and any animal identified as
something else is dropped. A `Dog` that is not a dog would break the guarantee
its own type makes, so an image containing other animals yields only the dogs.

If you want every animal regardless of species, use
[animal_detection](https://pub.dev/packages/animal_detection) directly. It is
already a dependency of this package.

`minSpeciesConfidence` adds an optional second filter on classifier confidence:

```dart
final detector = DogDetector(minSpeciesConfidence: 0.35);
```

It defaults to `0.0`, meaning off, and is worth raising if you see confident
misidentifications. People are the common case, because the underlying
1000-class ImageNet classifier has no person category and must assign every crop
to some animal or object class. Note the value is not comparable with the
sibling package's: it is one class's softmax probability, and probability mass
splits across however many classes a species occupies.

`faceOnly` mode is unaffected. It runs no classifier, so there is no species to
check, and the caller has already asserted the subject.

## Breed Identification

In `full` and `poseOnly` modes, each detected dog may include a predicted breed
label and confidence score from the species classifier.

`breed` is null when no breed is known: in `faceOnly` mode, which runs no
classifier, or when the classifier's top class fell in the near-miss block
(wolf, coyote, dingo or dhole). Those are still returned as dogs, since the likeliest explanation is a
domestic dog placed on a neighbouring class, but the label is withheld rather
than naming an animal the subject probably is not. Always null-check it.

```dart
final dogs = await detector.detect(imageBytes);
for (final dog in dogs) {
  if (dog.breed != null) {
    print('Breed: ${dog.breed}');
    print('Confidence: ${(dog.speciesConfidence! * 100).toStringAsFixed(1)}%');
  }
}
```

## Bounding Boxes

The `boundingBox` property returns a `BoundingBox` object representing the dog face bounding box in absolute pixel coordinates.

```dart
final BoundingBox boundingBox = face.boundingBox;

// Access edges
final double left = boundingBox.left;
final double top = boundingBox.top;
final double right = boundingBox.right;
final double bottom = boundingBox.bottom;

// Calculate dimensions
final double width = boundingBox.right - boundingBox.left;
final double height = boundingBox.bottom - boundingBox.top;

print('Box: ($left, $top) to ($right, $bottom)');
print('Size: $width x $height');
```

## Model Details

| Model | Size | Input | Purpose |
|-------|------|-------|---------|
| Face localizer | 16 MB | 224×224 | Dog face detection and bounding box |
| Landmark model (full) | 11 MB | 384×384 | 46-point facial landmark extraction |

## Configuration Options

The `DogDetector` constructor accepts several configuration options:

```dart
final detector = DogDetector(
  mode: DogDetectionMode.full,               // Detection mode
  poseModel: AnimalPoseModel.rtmpose,        // Body pose model variant
  landmarkModel: DogLandmarkModel.full,      // Face landmark model variant
  cropMargin: 0.20,                          // Margin around detected body for crop
  detThreshold: 0.5,                         // SSD detection confidence threshold
  interpreterPoolSize: 1,                    // TFLite interpreter pool size
  performanceConfig: const PerformanceConfig(), // Auto acceleration
);
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `mode` | `DogDetectionMode` | `full` | Detection mode |
| `poseModel` | `AnimalPoseModel` | `rtmpose` | Body pose model variant |
| `landmarkModel` | `DogLandmarkModel` | `full` | Face landmark model variant |
| `cropMargin` | `double` | `0.20` | Margin around detected body crop (0.0-1.0) |
| `detThreshold` | `double` | `0.5` | SSD detection confidence threshold |
| `interpreterPoolSize` | `int` | `1` | TFLite interpreter pool size |
| `performanceConfig` | `PerformanceConfig` | `auto` | Interpreter hardware acceleration config |

## Detection Modes

| Mode | Features | Speed |
|------|----------|-------|
| **full** | Body detection + breed ID + body pose + face landmarks | Standard |
| **poseOnly** | Body detection + breed ID + body pose (no face) | Faster |
| **faceOnly** | Face localizer + face landmarks only (legacy, no SSD) | Fastest |

## Background Isolate Detection

Detection always runs in a background isolate. `DogDetector` spawns and owns that
isolate during `initialize()`, so the whole pipeline (decode, SSD, species, pose,
localizer, landmarks) stays off the main thread and the UI is never blocked.
There is nothing extra to opt into:

```dart
import 'package:dog_detection/dog_detection.dart';

// initialize() loads the models and spawns the worker isolate
final detector = DogDetector(mode: DogDetectionMode.full);
await detector.initialize();

// Runs in the background isolate; the UI thread stays free
final dogs = await detector.detect(imageBytes);

for (final dog in dogs) {
  print('${dog.breed} at ${dog.boundingBox}');
  print('Face landmarks: ${dog.face?.landmarks.length}');
}

// Tears down the isolate and frees the native interpreters
await detector.dispose();
```

Model bytes are transferred into the isolate with `TransferableTypedData`, so the
~70MB of weights in the default configuration move without being copied.

## Performance

### Hardware Acceleration

The package automatically selects the best acceleration strategy for each platform:

| Platform | Default Delegate | Speedup | Notes |
|----------|-----------------|---------|-------|
| **macOS** | XNNPACK | 2-5x | SIMD vectorization (NEON on ARM, AVX on x86) |
| **Linux** | XNNPACK | 2-5x | SIMD vectorization |
| **iOS** | Metal GPU | 2-4x | Hardware GPU acceleration |
| **Android** | XNNPACK | 2-5x | ARM NEON SIMD acceleration |
| **Windows** | XNNPACK | 2-5x | SIMD vectorization (AVX on x86) |

No configuration needed, just call `initialize()` and you get the optimal performance for your platform.

### Advanced Performance Configuration

```dart
// Auto mode (default), optimal for each platform
await detector.initialize();

// Force XNNPACK (all native platforms)
final detector = DogDetector(
  performanceConfig: PerformanceConfig.xnnpack(numThreads: 4),
);
await detector.initialize();

// Force GPU delegate (iOS recommended, Android experimental)
final detector = DogDetector(
  performanceConfig: PerformanceConfig.gpu(),
);
await detector.initialize();

// CPU-only (maximum compatibility)
final detector = DogDetector(
  performanceConfig: PerformanceConfig.disabled,
);
await detector.initialize();
```

### LiteRT Next CompiledModel

CompiledModel is opt-in and covers the active body, classification, pose,
face-localizer, and face-landmark stages:

```dart
// Try GPU first, with verified CPU/stage fallback.
await detector.initialize(useCompiledModel: true);

// Pin CompiledModel to CPU.
await detector.initialize(
  useCompiledModel: true,
  accelerators: {Accelerator.cpu},
);
```

Every requested compiled graph is compared with a plain-CPU Interpreter before
use. A numerically unsafe GPU graph retries on CompiledModel CPU; if that also
fails, only that stage uses Interpreter. Interpreter remains the default and
`Precision.fp32` is used unless explicitly overridden.

## Live Camera Detection

For real-time detection, pass each `camera` package image directly to the
detector. Packing happens on the caller, while color conversion, rotation,
downscaling, and inference stay in the detector worker isolate.

```dart
final dogs = await detector.detectFromCameraImage(
  cameraImage,
  rotation: rotation,
  isBgra: Platform.isMacOS,
  maxDim: 640,
);
```

For lower-level integrations, use `prepareCameraFrame(...)` followed by
`detectFromCameraFrame(...)`.

## Credits

Models trained on the [DogFLW dataset](https://github.com/martvelge/DogFLW) by
Martvel et al., Tech4Animals Lab, University of Haifa.

DogFLW is licensed
[CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/). Obtain the
dataset from
[Kaggle](https://www.kaggle.com/datasets/georgemartvel/dogflw) under its own
terms.

The five `sample_dog_*.png` files in `example/assets/samples/` are DogFLW
images with the dataset's ground-truth landmarks rendered on them. They remain
licensed CC BY-NC 4.0 and are **not** covered by this repository's Apache 2.0
license; see
[`example/assets/samples/README.md`](example/assets/samples/README.md). They
are excluded from the published pub.dev archive.

```bibtex
@article{martvel2025dog,
  title={Dog facial landmarks detection and its applications for facial analysis},
  author={Martvel, George and Zamansky, Anna and Pedretti, Giulia and Canori,
          Chiara and Shimshoni, Ilan and Bremhorst, Annika},
  journal={Scientific Reports},
  volume={15},
  number={1},
  pages={21886},
  year={2025},
  publisher={Nature Publishing Group UK London}
}
```

## Weights and training code

The models in this package are published separately, with the full training
pipeline that produced them:

- **Weights:** [huggingface.co/hugocornellier/dog-face-landmarks](https://huggingface.co/hugocornellier/dog-face-landmarks)
  also carries a higher-accuracy variant (8.77 NME_IOD against 8.56 for the
  bundled one) that is too slow for phones but better suited to server-side use.
- **Training code and experiment journal:**
  [github.com/hugocornellier/dog-face-landmarks-training](https://github.com/hugocornellier/dog-face-landmarks-training)

## License

The Dart source code is **Apache 2.0**; see [`LICENSE`](LICENSE).

**The bundled model files are an exception.**
`assets/models/dog_face_landmarks_full.tflite` and
`assets/models/dog_face_localizer.tflite` are licensed
[**CC BY-NC 4.0**](https://creativecommons.org/licenses/by-nc/4.0/),
**non-commercial use only**. See [`NOTICE`](NOTICE).

This means using this package in a commercial product is not something this
license permits, because doing so runs those weights. The Dart code stays
Apache 2.0 and can be used commercially with weights you supply yourself.

The reason is that the weights are trained on DogFLW, which is CC BY-NC 4.0. Its
authors were asked directly how they wanted derived weights licensed, asked for
CC BY-NC 4.0 to stay consistent with the dataset, and granted permission to
publish on that basis. Commercial permission is not this package author's alone
to give: for that, contact the dataset authors at the Tech4Animals Lab,
University of Haifa.

## Example

The [sample code](https://pub.dev/packages/dog_detection/example) includes
matching live-camera, still-image, and video-file demos. All three paint body
pose and 46-point face landmarks; video output uses temporal smoothing and can
be replayed in the app.
