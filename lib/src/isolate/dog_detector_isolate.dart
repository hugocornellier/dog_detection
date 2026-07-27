import 'dart:typed_data';

import 'package:opencv_dart/opencv_dart.dart' as cv;
import '../dog_detector.dart';
import '../types.dart';

/// Background-isolate wrapper for dog detection.
///
/// Deprecated: [DogDetector] now runs its pipeline in a background isolate that
/// it owns, so this wrapper is redundant. It remains as a thin delegate to
/// [DogDetector] and will be removed in the next major release.
///
/// Migration:
/// ```dart
/// // Before
/// final detector = await DogDetectorIsolate.spawn(mode: DogDetectionMode.full);
/// final cats = await detector.detectDogs(bytes);
/// final more = await detector.detectDogsFromMat(mat);
///
/// // After
/// final detector = DogDetector(mode: DogDetectionMode.full);
/// await detector.initialize();
/// final cats = await detector.detect(bytes);
/// final more = await detector.detectFromMat(mat);
/// ```
@Deprecated(
  'Use DogDetector instead, which now runs detection in a background isolate '
  'automatically. Will be removed in the next major release.',
)
class DogDetectorIsolate {
  DogDetectorIsolate._(this._delegate);

  final DogDetector _delegate;

  /// Returns true if the isolate is initialized and ready for detection.
  bool get isReady => _delegate.isReady;

  /// Spawns a new isolate with an initialized dog detection pipeline.
  ///
  /// Deprecated: construct a [DogDetector] and call `initialize()` instead.
  @Deprecated(
    'Use DogDetector(...)..initialize() instead. '
    'Will be removed in the next major release.',
  )
  static Future<DogDetectorIsolate> spawn({
    DogDetectionMode mode = DogDetectionMode.full,
    AnimalPoseModel poseModel = AnimalPoseModel.rtmpose,
    DogLandmarkModel landmarkModel = DogLandmarkModel.full,
    double cropMargin = 0.20,
    int interpreterPoolSize = 1,
    PerformanceConfig performanceConfig = const PerformanceConfig(),
    void Function(String model, int received, int total)? onDownloadProgress,
  }) async {
    final detector = DogDetector(
      mode: mode,
      poseModel: poseModel,
      landmarkModel: landmarkModel,
      cropMargin: cropMargin,
      interpreterPoolSize: interpreterPoolSize,
      performanceConfig: performanceConfig,
    );
    await detector.initialize(onDownloadProgress: onDownloadProgress);
    return DogDetectorIsolate._(detector);
  }

  /// Detects dogs in an encoded image in the background isolate.
  ///
  /// Deprecated: use [DogDetector.detect] instead.
  @Deprecated(
    'Use DogDetector.detect instead. Will be removed in the next major release.',
  )
  Future<List<Dog>> detectDogs(Uint8List bytes) => _delegate.detect(bytes);

  /// Detects dogs in a pre-decoded [cv.Mat] in the background isolate.
  ///
  /// The supplied Mat is NOT disposed by this method.
  ///
  /// Deprecated: use [DogDetector.detectFromMat] instead.
  @Deprecated(
    'Use DogDetector.detectFromMat instead. '
    'Will be removed in the next major release.',
  )
  Future<List<Dog>> detectDogsFromMat(cv.Mat image) =>
      _delegate.detectFromMat(image);

  /// Disposes the background isolate and releases all resources.
  ///
  /// Deprecated: use [DogDetector.dispose] instead.
  @Deprecated(
    'Use DogDetector.dispose instead. '
    'Will be removed in the next major release.',
  )
  Future<void> dispose() => _delegate.dispose();
}
