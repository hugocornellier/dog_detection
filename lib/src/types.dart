// Re-export shared types from animal_detection
export 'package:animal_detection/animal_detection.dart'
    show
        AnimalPoseModel,
        AnimalPoseLandmarkType,
        AnimalPoseLandmark,
        AnimalPose,
        animalPoseConnections,
        BoundingBox,
        Point,
        CropMetadata,
        Animal,
        PerformanceMode,
        PerformanceConfig;

import 'package:animal_detection/animal_detection.dart';

/// Dog landmark model variant for landmark extraction.
///
/// - [full]: Single model at 384px input resolution (bundled, ~55MB).
/// - [ensemble]: 3-model ensemble (256px + 320px + 384px) averaging predictions
///   for improved accuracy (~8% lower NME). The 256px and 320px models are
///   downloaded on-demand from GitHub Releases on first use (~110MB total download).
enum DogLandmarkModel {
  /// Full model at 384px input resolution (bundled with the package).
  full,

  /// 3-model ensemble (256px + 320px + 384px) with multi-scale + flip TTA.
  ensemble,
}

/// Detection mode controlling the full pipeline behavior.
///
/// - [full]: SSD body detection + species + body pose + face landmarks.
/// - [poseOnly]: Body detection + species + body pose only (no face detection).
/// - [faceOnly]: Face localizer + face landmarks only (legacy, no SSD).
enum DogDetectionMode {
  /// Full pipeline: SSD body detection + species + body pose + face landmarks.
  full,

  /// Body detection + species + body pose only (no face detection).
  poseOnly,

  /// Face-only mode: face localizer + face landmarks (legacy behavior, no SSD).
  faceOnly,
}

/// Dog face landmark types based on the DogFLW dataset topology.
///
/// 46 landmarks covering ear contours, eyes, nose bridge, nose ring,
/// and mouth/chin contour.
enum DogLandmarkType {
  /// Left ear contour point 0 (index 0).
  leftEar0,

  /// Right ear contour point 0 (index 1).
  rightEar0,

  /// Left ear contour point 1 (index 2).
  leftEar1,

  /// Right ear contour point 1 (index 3).
  rightEar1,

  /// Left ear contour point 2 (index 4).
  leftEar2,

  /// Right ear contour point 2 (index 5).
  rightEar2,

  /// Left ear contour point 3 (index 6).
  leftEar3,

  /// Right ear contour point 3 (index 7).
  rightEar3,

  /// Left ear contour point 4 (index 8).
  leftEar4,

  /// Right ear contour point 4 (index 9).
  rightEar4,

  /// Left ear contour point 5 (index 10).
  leftEar5,

  /// Right ear contour point 5 (index 11).
  rightEar5,

  /// Left ear contour point 6 (index 12).
  leftEar6,

  /// Right ear contour point 6 (index 13).
  rightEar6,

  /// Top of nose bridge (index 14).
  noseBridgeTop,

  /// Bottom of nose bridge / nose tip (index 15).
  noseBridgeBottom,

  /// Outer corner of left eye (index 16).
  leftEyeOuter,

  /// Outer corner of right eye (index 17).
  rightEyeOuter,

  /// Top of left eye (index 18).
  leftEyeTop,

  /// Top of right eye (index 19).
  rightEyeTop,

  /// Inner corner of left eye (index 20).
  leftEyeInner,

  /// Inner corner of right eye (index 21).
  rightEyeInner,

  /// Bottom of left eye (index 22).
  leftEyeBottom,

  /// Bottom of right eye (index 23).
  rightEyeBottom,

  /// Nose ring point 0 (index 24).
  noseRing0,

  /// Nose ring point 1 (index 25).
  noseRing1,

  /// Nose ring point 2 (index 26).
  noseRing2,

  /// Nose ring point 3 (index 27).
  noseRing3,

  /// Nose ring point 4 (index 28).
  noseRing4,

  /// Nose ring point 5 (index 29).
  noseRing5,

  /// Nose ring point 6 (index 30).
  noseRing6,

  /// Nose ring point 7 (index 31).
  noseRing7,

  /// Mouth/chin contour point 0 (index 32).
  mouthChin0,

  /// Mouth/chin contour point 1 (index 33).
  mouthChin1,

  /// Mouth/chin contour point 2 (index 34).
  mouthChin2,

  /// Mouth/chin contour point 3 (index 35).
  mouthChin3,

  /// Mouth/chin contour point 4 (index 36).
  mouthChin4,

  /// Mouth/chin contour point 5 (index 37).
  mouthChin5,

  /// Mouth/chin contour point 6 (index 38).
  mouthChin6,

  /// Mouth/chin contour point 7 (index 39).
  mouthChin7,

  /// Mouth/chin contour point 8 (index 40).
  mouthChin8,

  /// Mouth/chin contour point 9 (index 41).
  mouthChin9,

  /// Mouth/chin contour point 10 (index 42).
  mouthChin10,

  /// Mouth/chin contour point 11 (index 43).
  mouthChin11,

  /// Mouth/chin contour point 12 (index 44).
  mouthChin12,

  /// Mouth/chin contour point 13 (index 45).
  mouthChin13,
}

/// Number of dog face landmarks (46 for the DogFLW model).
const int numDogLandmarks = 46;

/// Landmark index permutation for horizontal flip (DogFLW convention).
///
/// When an image is horizontally flipped, left/right landmarks swap.
/// Used internally by the ensemble model for flip test-time augmentation.
const List<int> dogLandmarkFlipIndex = [
  1,
  0,
  3,
  2,
  5,
  4,
  7,
  6,
  9,
  8,
  11,
  10,
  13,
  12,
  15,
  14,
  17,
  16,
  19,
  18,
  21,
  20,
  23,
  22,
  24,
  25,
  27,
  26,
  29,
  28,
  31,
  30,
  32,
  34,
  33,
  35,
  37,
  36,
  38,
  40,
  39,
  41,
  42,
  44,
  43,
  45,
];

/// A single dog face keypoint with 2D coordinates.
///
/// Coordinates are in the original image space (pixels).
class DogLandmark {
  /// The landmark type this represents
  final DogLandmarkType type;

  /// X coordinate in pixels (original image space)
  final double x;

  /// Y coordinate in pixels (original image space)
  final double y;

  /// Creates a dog face landmark with 2D coordinates.
  DogLandmark({
    required this.type,
    required this.x,
    required this.y,
  });

  /// Serializes this landmark to a map for cross-isolate transfer.
  Map<String, dynamic> toMap() => {
        'type': type.name,
        'x': x,
        'y': y,
      };

  /// Deserializes a landmark from a map.
  static DogLandmark fromMap(Map<String, dynamic> map) => DogLandmark(
        type: DogLandmarkType.values.firstWhere((e) => e.name == map['type']),
        x: (map['x'] as num).toDouble(),
        y: (map['y'] as num).toDouble(),
      );

  /// Converts x coordinate to normalized range (0.0 to 1.0)
  double xNorm(int imageWidth) => (x / imageWidth).clamp(0.0, 1.0);

  /// Converts y coordinate to normalized range (0.0 to 1.0)
  double yNorm(int imageHeight) => (y / imageHeight).clamp(0.0, 1.0);

  /// Converts landmark coordinates to a pixel point
  Point toPixel(int imageWidth, int imageHeight) {
    return Point(x.truncateToDouble(), y.truncateToDouble());
  }
}

/// Defines the standard skeleton connections between dog face landmarks.
const List<List<DogLandmarkType>> dogLandmarkConnections = [
  // Left ear closed contour
  [DogLandmarkType.leftEar4, DogLandmarkType.leftEar3],
  [DogLandmarkType.leftEar3, DogLandmarkType.leftEar2],
  [DogLandmarkType.leftEar2, DogLandmarkType.leftEar1],
  [DogLandmarkType.leftEar1, DogLandmarkType.leftEar0],
  [DogLandmarkType.leftEar0, DogLandmarkType.leftEar6],
  [DogLandmarkType.leftEar6, DogLandmarkType.leftEar5],
  [DogLandmarkType.leftEar5, DogLandmarkType.leftEar4],
  // Right ear closed contour
  [DogLandmarkType.rightEar4, DogLandmarkType.rightEar3],
  [DogLandmarkType.rightEar3, DogLandmarkType.rightEar2],
  [DogLandmarkType.rightEar2, DogLandmarkType.rightEar1],
  [DogLandmarkType.rightEar1, DogLandmarkType.rightEar0],
  [DogLandmarkType.rightEar0, DogLandmarkType.rightEar6],
  [DogLandmarkType.rightEar6, DogLandmarkType.rightEar5],
  [DogLandmarkType.rightEar5, DogLandmarkType.rightEar4],
  // Left eye closed quad
  [DogLandmarkType.leftEyeTop, DogLandmarkType.leftEyeInner],
  [DogLandmarkType.leftEyeInner, DogLandmarkType.leftEyeOuter],
  [DogLandmarkType.leftEyeOuter, DogLandmarkType.leftEyeBottom],
  [DogLandmarkType.leftEyeBottom, DogLandmarkType.leftEyeTop],
  // Right eye closed quad
  [DogLandmarkType.rightEyeTop, DogLandmarkType.rightEyeInner],
  [DogLandmarkType.rightEyeInner, DogLandmarkType.rightEyeOuter],
  [DogLandmarkType.rightEyeOuter, DogLandmarkType.rightEyeBottom],
  [DogLandmarkType.rightEyeBottom, DogLandmarkType.rightEyeTop],
];

/// Detected dog face with bounding box and optional landmarks.
class DogFace {
  /// Bounding box of the detected face in pixel coordinates
  final BoundingBox boundingBox;

  /// List of 46 landmarks. Empty if face landmarks were not run.
  final List<DogLandmark> landmarks;

  /// Creates a detected dog face with a bounding box and optional landmarks.
  const DogFace({
    required this.boundingBox,
    required this.landmarks,
  });

  /// Serializes this face to a map for cross-isolate transfer.
  Map<String, dynamic> toMap() => {
        'boundingBox': {
          'left': boundingBox.left,
          'top': boundingBox.top,
          'right': boundingBox.right,
          'bottom': boundingBox.bottom
        },
        'landmarks': landmarks.map((l) => l.toMap()).toList(),
      };

  /// Deserializes a dog face from a map.
  static DogFace fromMap(Map<String, dynamic> map) => DogFace(
        boundingBox: BoundingBox.ltrb(
          (map['boundingBox']['left'] as num).toDouble(),
          (map['boundingBox']['top'] as num).toDouble(),
          (map['boundingBox']['right'] as num).toDouble(),
          (map['boundingBox']['bottom'] as num).toDouble(),
        ),
        landmarks: (map['landmarks'] as List<dynamic>)
            .map((l) => DogLandmark.fromMap(l as Map<String, dynamic>))
            .toList(),
      );

  /// Gets a specific landmark by type, or null if not found
  DogLandmark? getLandmark(DogLandmarkType type) {
    try {
      return landmarks.firstWhere((l) => l.type == type);
    } catch (_) {
      return null;
    }
  }

  /// Returns true if this face has landmarks
  bool get hasLandmarks => landmarks.isNotEmpty;

  @override
  String toString() {
    final String landmarksInfo = landmarks
        .map((l) =>
            '${l.type.name}: (${l.x.toStringAsFixed(2)}, ${l.y.toStringAsFixed(2)})')
        .join('\n');
    return 'DogFace(\n'
        '  landmarks=${landmarks.length},\n'
        '  coords:\n$landmarksInfo\n)';
  }
}

/// Top-level result for a single detected dog.
///
/// Uses [AnimalPose] from the animal_detection package for body pose data.
class Dog {
  /// Body bounding box in pixel coordinates (original image space)
  final BoundingBox boundingBox;

  /// SSD detector confidence score (0.0 to 1.0)
  final double score;

  /// Predicted species label (e.g. "dog"), or null if classification was not run
  final String? species;

  /// Predicted breed label, or null if classification was not run
  final String? breed;

  /// Species classifier confidence (0.0 to 1.0), or null if not run
  final double? speciesConfidence;

  /// Face detection and landmark result, or null if not run / not found
  final DogFace? face;

  /// Body pose keypoints, or null if pose estimation was not run
  final AnimalPose? pose;

  /// Width of the original image in pixels
  final int imageWidth;

  /// Height of the original image in pixels
  final int imageHeight;

  /// Creates a top-level dog detection result.
  const Dog({
    required this.boundingBox,
    required this.score,
    this.species,
    this.breed,
    this.speciesConfidence,
    this.face,
    this.pose,
    required this.imageWidth,
    required this.imageHeight,
  });

  /// Serializes this result to a map for cross-isolate transfer.
  Map<String, dynamic> toMap() => {
        'boundingBox': {
          'left': boundingBox.left,
          'top': boundingBox.top,
          'right': boundingBox.right,
          'bottom': boundingBox.bottom
        },
        'score': score,
        'species': species,
        'breed': breed,
        'speciesConfidence': speciesConfidence,
        'face': face?.toMap(),
        'pose': pose?.toMap(),
        'imageWidth': imageWidth,
        'imageHeight': imageHeight,
      };

  /// Deserializes a dog detection result from a map.
  static Dog fromMap(Map<String, dynamic> map) => Dog(
        boundingBox: BoundingBox.ltrb(
          (map['boundingBox']['left'] as num).toDouble(),
          (map['boundingBox']['top'] as num).toDouble(),
          (map['boundingBox']['right'] as num).toDouble(),
          (map['boundingBox']['bottom'] as num).toDouble(),
        ),
        score: (map['score'] as num).toDouble(),
        species: map['species'] as String?,
        breed: map['breed'] as String?,
        speciesConfidence: (map['speciesConfidence'] as num?)?.toDouble(),
        face: map['face'] != null
            ? DogFace.fromMap(map['face'] as Map<String, dynamic>)
            : null,
        pose: map['pose'] != null
            ? AnimalPose.fromMap(map['pose'] as Map<String, dynamic>)
            : null,
        imageWidth: map['imageWidth'] as int,
        imageHeight: map['imageHeight'] as int,
      );

  @override
  String toString() =>
      'Dog(score=${score.toStringAsFixed(3)}, species=$species, breed=$breed, face=${face != null}, pose=${pose != null})';
}
