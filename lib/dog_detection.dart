/// On-device dog detection and landmark estimation using TensorFlow Lite.
///
/// This library provides a Flutter plugin for dog detection using a unified
/// multi-stage TFLite pipeline: SSD body detection, species classification,
/// body pose estimation, face localization, and face landmark extraction.
///
/// **Quick Start:**
/// ```dart
/// import 'package:dog_detection/dog_detection.dart';
///
/// final detector = DogDetector(mode: DogDetectionMode.full);
/// await detector.initialize();
///
/// final dogs = await detector.detect(imageBytes);
/// for (final dog in dogs) {
///   print('Dog at ${dog.boundingBox} score=${dog.score}');
///   if (dog.pose != null) {
///     final tail = dog.pose!.getLandmark(AnimalPoseLandmarkType.tailEnd);
///     print('Tail: (${tail?.x}, ${tail?.y})');
///   }
///   if (dog.face != null && dog.face!.hasLandmarks) {
///     final nose = dog.face!.getLandmark(DogLandmarkType.noseBridgeBottom);
///     print('Nose: (${nose?.x}, ${nose?.y})');
///   }
/// }
///
/// await detector.dispose();
/// ```
///
/// **Main Classes:**
/// - [DogDetector]: Main API for dog detection. Runs the whole pipeline in a
///   background isolate it owns, so detection never blocks the UI thread.
/// - [Dog]: Top-level detection result with body, pose and face info
/// - [DogFace]: Detected dog face with bounding box and landmarks
/// - [DogLandmark]: Single face keypoint with 2D coordinates
/// - [BoundingBox]: Axis-aligned rectangle in pixel coordinates
///
/// **Detection Modes:**
/// - [DogDetectionMode.full]: SSD body detection + species + body pose + face landmarks
/// - [DogDetectionMode.poseOnly]: Body detection + species + body pose only
/// - [DogDetectionMode.faceOnly]: Face localizer + face landmarks only (legacy)
///
/// **Pose Model Variants:**
/// - [AnimalPoseModel.rtmpose]: RTMPose-S (11.6MB, bundled). Fast SimCC-based decoder.
/// - [AnimalPoseModel.hrnet]: HRNet-w32 (54.6MB, downloaded on demand). Most accurate.
///
/// **Face Landmark Model Variants:**
/// - [DogLandmarkModel.full]: Single model at 384px input resolution (bundled)
///   + flip TTA (18 passes). Extra models downloaded on-demand from GitHub Releases (~110MB)
///
/// **Skeleton Connections:**
/// - [dogLandmarkConnections]: Face landmark skeleton edges (DogFLW topology)
/// - [animalPoseConnections]: Body pose skeleton edges (SuperAnimal topology)
library;

export 'src/types.dart';
export 'src/dog_detector.dart' show DogDetector;

// Deprecated: DogDetector now owns its background isolate, making this wrapper
// redundant. Kept for one major release to give consumers time to migrate.
export 'src/isolate/dog_detector_isolate.dart' show DogDetectorIsolate;

// Re-export everything from animal_detection that consumers need
export 'package:animal_detection/animal_detection.dart'
    show
        AnimalDetector,
        Animal,
        AnimalPoseModel,
        AnimalPose,
        AnimalPoseLandmark,
        AnimalPoseLandmarkType,
        BoundingBox,
        Point,
        CropMetadata,
        animalPoseConnections,
        ModelDownloader,
        PerformanceMode,
        PerformanceConfig,
        Mat,
        imdecode,
        IMREAD_COLOR;

export 'src/dart_registration.dart';
