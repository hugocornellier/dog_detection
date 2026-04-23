import 'dart:typed_data';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:animal_detection/animal_detection.dart';
import 'types.dart';
import 'util/model_downloader.dart';

/// On-device dog detection using a unified multi-stage TensorFlow Lite pipeline.
///
/// Supports three modes:
/// - [DogDetectionMode.full]: SSD body detection + species classification +
///   body pose estimation + face localization + face landmarks.
/// - [DogDetectionMode.poseOnly]: Body detection + species + body pose only.
/// - [DogDetectionMode.faceOnly]: Face localizer + face landmarks only (legacy).
///
/// Uses [AnimalDetector] from the animal_detection package for body detection,
/// species classification, and pose estimation. Dog-specific face detection
/// and landmark extraction are handled directly.
///
/// Usage:
/// ```dart
/// final detector = DogDetector(mode: DogDetectionMode.full);
/// await detector.initialize();
/// final dogs = await detector.detect(imageBytes);
/// await detector.dispose();
/// ```
class DogDetector {
  static const String _packageVersion = '1.0.5';
  static const String _pipelineVersion = 'pipeline_v1';

  /// Version key for the default dog detection pipeline.
  ///
  /// Downstream caches can use this to invalidate stored detections when model
  /// weights, preprocessing, post-processing, thresholds, or coordinate
  /// conventions change.
  static const String modelVersion =
      'dog_detection:$_packageVersion:mode=full:poseModel=rtmpose:'
      'landmarkModel=full:$_pipelineVersion';

  /// Builds a version key for a specific dog detector configuration.
  static String modelVersionFor({
    DogDetectionMode mode = DogDetectionMode.full,
    AnimalPoseModel poseModel = AnimalPoseModel.rtmpose,
    DogLandmarkModel landmarkModel = DogLandmarkModel.full,
  }) {
    return 'dog_detection:$_packageVersion:mode=${mode.name}:'
        'poseModel=${poseModel.name}:landmarkModel=${landmarkModel.name}:'
        '$_pipelineVersion';
  }

  // Animal detection pipeline (full / poseOnly)
  AnimalDetector? _animalDetector;

  // Face pipeline (full / faceOnly)
  FaceLocalizerModel? _localizer;
  LandmarkModelRunnerBase? _lm;
  EnsembleLandmarkModelBase? _ensemble;

  /// Detection mode controlling pipeline behavior.
  final DogDetectionMode mode;

  /// Body pose model variant.
  final AnimalPoseModel poseModel;

  /// Dog face landmark model variant.
  final DogLandmarkModel landmarkModel;

  /// Margin fraction added to each side of the body bounding box before cropping.
  final double cropMargin;

  /// SSD detection score threshold.
  final double detThreshold;

  /// Number of TensorFlow Lite interpreter instances in the landmark model pool.
  final int interpreterPoolSize;

  /// Performance configuration for TensorFlow Lite inference.
  ///
  /// By default, auto mode selects the optimal delegate per platform:
  /// - iOS: Metal GPU delegate
  /// - Android/macOS/Linux/Windows: XNNPACK (2-5x SIMD acceleration)
  final PerformanceConfig performanceConfig;

  bool _isInitialized = false;

  /// Creates a dog detector with the specified configuration.
  DogDetector({
    this.mode = DogDetectionMode.full,
    this.poseModel = AnimalPoseModel.rtmpose,
    this.landmarkModel = DogLandmarkModel.full,
    this.cropMargin = 0.20,
    this.detThreshold = 0.5,
    int interpreterPoolSize = 1,
    this.performanceConfig = const PerformanceConfig(),
  }) : interpreterPoolSize = performanceConfig.mode == PerformanceMode.disabled
            ? interpreterPoolSize
            : 1;

  /// Initializes the detector by loading TensorFlow Lite models.
  ///
  /// Must be called before [detect] or [detectFromMat].
  /// If already initialized, disposes existing models before reinitializing.
  ///
  /// When [poseModel] is [AnimalPoseModel.hrnet], the HRNet model (~54.6 MB) is
  /// downloaded from GitHub Releases on first use and cached locally.
  ///
  /// When [landmarkModel] is [DogLandmarkModel.ensemble], the extra 256px and
  /// 320px models (~110 MB total) are downloaded on first use.
  ///
  /// [onDownloadProgress] is called during any model download with
  /// (modelName, bytesReceived, totalBytes).
  Future<void> initialize({
    void Function(String model, int received, int total)? onDownloadProgress,
    bool useIsolateInterpreter = true,
  }) async {
    if (_isInitialized) {
      await dispose();
    }

    final bool needsBody =
        mode == DogDetectionMode.full || mode == DogDetectionMode.poseOnly;
    final bool needsFace =
        mode == DogDetectionMode.full || mode == DogDetectionMode.faceOnly;

    if (needsBody) {
      _animalDetector = AnimalDetector(
        poseModel: poseModel,
        enablePose: true,
        cropMargin: cropMargin,
        detThreshold: detThreshold,
        performanceConfig: performanceConfig,
      );
      await _animalDetector!.initialize(
        onDownloadProgress: onDownloadProgress,
        useIsolateInterpreter: useIsolateInterpreter,
      );
    }

    if (needsFace) {
      _localizer = FaceLocalizerModel(
        inputSize: 224,
        modelPath:
            'packages/dog_detection/assets/models/dog_face_localizer.tflite',
      );
      await _localizer!.initialize(
        performanceConfig,
        useIsolateInterpreter: useIsolateInterpreter,
      );

      if (landmarkModel == DogLandmarkModel.ensemble) {
        _ensemble = EnsembleLandmarkModelBase(
          numLandmarks: numDogLandmarks,
          flipIndex: dogLandmarkFlipIndex,
          bundledModelPath:
              'packages/dog_detection/assets/models/dog_face_landmarks_full.tflite',
          getEnsembleModels: DogModelDownloader.getEnsembleModels,
          poolSize: interpreterPoolSize,
        );
        await _ensemble!.initialize(
          performanceConfig,
          onDownloadProgress: onDownloadProgress,
          useIsolateInterpreter: useIsolateInterpreter,
        );
      } else {
        _lm = LandmarkModelRunnerBase(
          inputSize: 384,
          numLandmarks: numDogLandmarks,
          modelPath:
              'packages/dog_detection/assets/models/dog_face_landmarks_full.tflite',
          poolSize: interpreterPoolSize,
        );
        await _lm!.initialize(
          performanceConfig,
          useIsolateInterpreter: useIsolateInterpreter,
        );
      }
    }

    _isInitialized = true;
  }

  /// Initializes the detector from pre-loaded model bytes.
  ///
  /// Used by [DogDetectorIsolate] to initialize within a background isolate
  /// where Flutter asset loading is not available.
  Future<void> initializeFromBuffers({
    Uint8List? localizerBytes,
    Uint8List? landmarkBytes,
    Uint8List? ensemble256Bytes,
    Uint8List? ensemble320Bytes,
    Uint8List? bodyDetectorBytes,
    Uint8List? classifierBytes,
    String? speciesMappingJson,
    Uint8List? poseModelBytes,
    bool useIsolateInterpreter = true,
  }) async {
    if (_isInitialized) {
      await dispose();
    }

    final bool needsBody =
        mode == DogDetectionMode.full || mode == DogDetectionMode.poseOnly;
    final bool needsFace =
        mode == DogDetectionMode.full || mode == DogDetectionMode.faceOnly;

    if (needsBody) {
      if (bodyDetectorBytes == null) {
        throw ArgumentError(
          'bodyDetectorBytes is required for full/poseOnly mode',
        );
      }
      if (classifierBytes == null) {
        throw ArgumentError(
          'classifierBytes is required for full/poseOnly mode',
        );
      }
      if (speciesMappingJson == null) {
        throw ArgumentError(
          'speciesMappingJson is required for full/poseOnly mode',
        );
      }
      if (poseModelBytes == null) {
        throw ArgumentError(
          'poseModelBytes is required for full/poseOnly mode',
        );
      }

      _animalDetector = AnimalDetector(
        poseModel: poseModel,
        enablePose: true,
        cropMargin: cropMargin,
        detThreshold: detThreshold,
        performanceConfig: performanceConfig,
      );
      await _animalDetector!.initializeFromBuffers(
        bodyDetectorBytes: bodyDetectorBytes,
        classifierBytes: classifierBytes,
        speciesMappingJson: speciesMappingJson,
        poseModelBytes: poseModelBytes,
        useIsolateInterpreter: useIsolateInterpreter,
      );
    }

    if (needsFace) {
      if (localizerBytes == null) {
        throw ArgumentError(
          'localizerBytes is required for full/faceOnly mode',
        );
      }
      if (landmarkBytes == null) {
        throw ArgumentError(
          'landmarkBytes is required for full/faceOnly mode',
        );
      }

      _localizer = FaceLocalizerModel(
        inputSize: 224,
        modelPath:
            'packages/dog_detection/assets/models/dog_face_localizer.tflite',
      );
      await _localizer!.initializeFromBuffer(
        localizerBytes,
        performanceConfig,
        useIsolateInterpreter: useIsolateInterpreter,
      );

      if (landmarkModel == DogLandmarkModel.ensemble) {
        if (ensemble256Bytes == null || ensemble320Bytes == null) {
          throw ArgumentError(
            'ensemble256Bytes and ensemble320Bytes are required for ensemble mode',
          );
        }
        _ensemble = EnsembleLandmarkModelBase(
          numLandmarks: numDogLandmarks,
          flipIndex: dogLandmarkFlipIndex,
          bundledModelPath:
              'packages/dog_detection/assets/models/dog_face_landmarks_full.tflite',
          getEnsembleModels: DogModelDownloader.getEnsembleModels,
          poolSize: interpreterPoolSize,
        );
        await _ensemble!.initializeFromBuffers(
          bytes256: ensemble256Bytes,
          bytes320: ensemble320Bytes,
          bytes384: landmarkBytes,
          performanceConfig: performanceConfig,
          useIsolateInterpreter: useIsolateInterpreter,
        );
      } else {
        _lm = LandmarkModelRunnerBase(
          inputSize: 384,
          numLandmarks: numDogLandmarks,
          modelPath:
              'packages/dog_detection/assets/models/dog_face_landmarks_full.tflite',
          poolSize: interpreterPoolSize,
        );
        await _lm!.initializeFromBuffer(
          landmarkBytes,
          performanceConfig,
          useIsolateInterpreter: useIsolateInterpreter,
        );
      }
    }

    _isInitialized = true;
  }

  /// Returns true if the detector has been initialized and is ready to use.
  bool get isInitialized => _isInitialized;

  /// Returns true if the ensemble models are already cached locally.
  static Future<bool> isEnsembleCached() =>
      DogModelDownloader.isEnsembleCached();

  /// Returns true if the HRNet model is already cached locally.
  static Future<bool> isHrnetCached() => ModelDownloader.isHrnetCached();

  /// Releases all resources used by the detector.
  Future<void> dispose() async {
    await _animalDetector?.dispose();
    _localizer?.dispose();
    _lm?.dispose();
    _ensemble?.dispose();
    _animalDetector = null;
    _localizer = null;
    _lm = null;
    _ensemble = null;
    _isInitialized = false;
  }

  /// Detects dogs in an image from raw bytes.
  Future<List<Dog>> detect(Uint8List imageBytes) async {
    if (!_isInitialized) {
      throw StateError('DogDetector not initialized. Call initialize() first.');
    }
    try {
      final mat = cv.imdecode(imageBytes, cv.IMREAD_COLOR);
      if (mat.isEmpty) {
        return <Dog>[];
      }
      try {
        return await detectFromMat(
          mat,
          imageWidth: mat.cols,
          imageHeight: mat.rows,
        );
      } finally {
        mat.dispose();
      }
    } catch (e) {
      return <Dog>[];
    }
  }

  /// Detects dogs in an OpenCV Mat image.
  Future<List<Dog>> detectFromMat(
    cv.Mat image, {
    required int imageWidth,
    required int imageHeight,
  }) async {
    if (!_isInitialized) {
      throw StateError('DogDetector not initialized. Call initialize() first.');
    }

    if (mode == DogDetectionMode.faceOnly) {
      return _detectFaceOnly(image, imageWidth, imageHeight);
    }

    return _detectWithBody(image, imageWidth, imageHeight);
  }

  /// Pipeline for [DogDetectionMode.faceOnly]: legacy face-only behavior.
  Future<List<Dog>> _detectFaceOnly(
    cv.Mat image,
    int imageWidth,
    int imageHeight,
  ) async {
    final BoundingBox? bbox = await _localizer!.detect(image);
    if (bbox == null) return <Dog>[];

    final DogFace face =
        await _runFaceLandmarks(image, bbox, imageWidth, imageHeight);

    return [
      Dog(
        boundingBox: bbox,
        score: 1.0,
        face: face,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
      ),
    ];
  }

  /// Pipeline for [DogDetectionMode.full] and [DogDetectionMode.poseOnly].
  ///
  /// Uses [AnimalDetector] for SSD detection, species classification, and pose
  /// estimation, then runs face detection on each detected dog.
  Future<List<Dog>> _detectWithBody(
    cv.Mat image,
    int imageWidth,
    int imageHeight,
  ) async {
    // Stage 1-3: Run animal detection (SSD + species + pose)
    final animals = await _animalDetector!.detectFromMat(
      image,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );
    if (animals.isEmpty) return <Dog>[];

    final dogs = <Dog>[];

    for (int i = 0; i < animals.length; i++) {
      final animal = animals[i];
      DogFace? face;

      // Stage 4: face detection (full mode only)
      if (mode == DogDetectionMode.full) {
        // Expand bbox for the face crop (same margin as used for pose)
        final (cx1, cy1, cx2, cy2) = ImageUtils.expandBox(
          animal.boundingBox.left,
          animal.boundingBox.top,
          animal.boundingBox.right,
          animal.boundingBox.bottom,
          cropMargin,
          imageWidth,
          imageHeight,
        );

        final int cropW = cx2 - cx1;
        final int cropH = cy2 - cy1;
        if (cropW >= 1 && cropH >= 1) {
          final expandedCrop = image.region(cv.Rect(cx1, cy1, cropW, cropH));
          try {
            // Detect face in the dog crop space
            final BoundingBox? faceBboxInCrop =
                await _localizer!.detect(expandedCrop);

            if (faceBboxInCrop != null) {
              // Offset face bbox from crop space to original image space
              final faceBboxInImage = BoundingBox.ltrb(
                faceBboxInCrop.left + cx1,
                faceBboxInCrop.top + cy1,
                faceBboxInCrop.right + cx1,
                faceBboxInCrop.bottom + cy1,
              );

              face = await _runFaceLandmarks(
                image,
                faceBboxInImage,
                imageWidth,
                imageHeight,
              );
            }
          } finally {
            expandedCrop.dispose();
          }
        }
      }

      dogs.add(Dog(
        boundingBox: animal.boundingBox,
        score: animal.score,
        species: animal.species,
        breed: animal.breed,
        speciesConfidence: animal.speciesConfidence,
        face: face,
        pose: animal.pose,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
      ));
    }

    return dogs;
  }

  /// Crops the face region from [image] using [faceBbox] and runs landmark estimation.
  Future<DogFace> _runFaceLandmarks(
    cv.Mat image,
    BoundingBox faceBbox,
    int imageWidth,
    int imageHeight,
  ) async {
    final int cropSize = landmarkModel == DogLandmarkModel.ensemble
        ? _ensemble!.inputSize
        : _lm!.inputSize;

    final (faceCrop, meta) = ImageUtils.cropAndResize(
      image,
      faceBbox,
      cropMargin,
      cropSize,
    );

    final List<DogLandmark> landmarks;
    try {
      if (landmarkModel == DogLandmarkModel.ensemble) {
        final coords = await _ensemble!.predictRaw(faceCrop, meta);
        landmarks = [
          for (int i = 0; i < coords.length; i++)
            DogLandmark(
                type: DogLandmarkType.values[i],
                x: coords[i].$1,
                y: coords[i].$2),
        ];
      } else {
        final coords = await _lm!.predictRaw(faceCrop, meta);
        landmarks = [
          for (int i = 0; i < coords.length; i++)
            DogLandmark(
                type: DogLandmarkType.values[i],
                x: coords[i].$1,
                y: coords[i].$2),
        ];
      }
    } finally {
      faceCrop.dispose();
    }

    return DogFace(boundingBox: faceBbox, landmarks: landmarks);
  }
}
