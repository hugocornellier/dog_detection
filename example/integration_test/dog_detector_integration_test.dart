// Comprehensive integration tests for DogDetector.
//
// These tests cover:
// - Initialization and disposal
// - Detection from Mat (detectFromMat)
// - detect() bytes API
// - Boxes-only mode
// - Landmark validation (46 landmarks, all types present, finite coordinates)
// - Error recovery after empty-result input
// - Result consistency / determinism
// - Configuration parameters (cropMargin, PerformanceConfig)
// - DogDetectorIsolate (spawn, detect, detectFromMat, re-spawn)
//
// Run with:
//   flutter test integration_test/ --dart-define=...
// or via a connected device/simulator.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:dog_detection/dog_detection.dart';

/// Minimal valid 1x1 black PNG (used for error-recovery tests).
class _TestUtils {
  static Uint8List createTinyBlackPng() {
    return Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
      0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
      0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, // Width: 1, Height: 1
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, // Bit depth, color type
      0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, // IDAT chunk
      0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, // Image data
      0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, // IEND chunk
      0x42, 0x60, 0x82,
    ]);
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------------
  // 1. DogDetector - Initialization
  // ---------------------------------------------------------------------------

  group('DogDetector - Initialization', () {
    testWidgets('should initialize successfully', (tester) async {
      final detector = DogDetector();
      await detector.initialize();
      expect(detector.isInitialized, true);
      await detector.dispose();
    });

    testWidgets('should report isInitialized as true after init',
        (tester) async {
      final detector = DogDetector();
      expect(detector.isInitialized, false);
      await detector.initialize();
      expect(detector.isInitialized, true);
      await detector.dispose();
    });

    testWidgets('should report isInitialized as false before init',
        (tester) async {
      final detector = DogDetector();
      expect(detector.isInitialized, false);
      // No dispose needed, detector was never initialized.
    });

    testWidgets('should throw StateError when detect called before init',
        (tester) async {
      final detector = DogDetector();
      final bytes = _TestUtils.createTinyBlackPng();

      expect(
        () => detector.detect(bytes),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('not initialized'),
        )),
      );
    });

    testWidgets('should throw StateError when detectFromMat called before init',
        (tester) async {
      final detector = DogDetector();
      final mat = cv.Mat.zeros(100, 100, cv.MatType.CV_8UC3);

      try {
        expect(
          () => detector.detectFromMat(
            mat,
            imageWidth: mat.cols,
            imageHeight: mat.rows,
          ),
          throwsA(isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('not initialized'),
          )),
        );
      } finally {
        mat.dispose();
      }
    });

    testWidgets('should allow re-initialization', (tester) async {
      final detector = DogDetector();
      await detector.initialize();
      expect(detector.isInitialized, true);

      await detector.initialize();
      expect(detector.isInitialized, true);

      await detector.dispose();
    });

    testWidgets('should handle multiple dispose calls', (tester) async {
      final detector = DogDetector();
      await detector.initialize();
      await detector.dispose();
      expect(detector.isInitialized, false);

      // Second dispose should not throw.
      await detector.dispose();
      expect(detector.isInitialized, false);
    });
  });

  // ---------------------------------------------------------------------------
  // 2. DogDetector - Detection from Mat
  // ---------------------------------------------------------------------------

  group('DogDetector - Detection from Mat', () {
    testWidgets('should detect dog from sample image', (tester) async {
      final detector = DogDetector();
      await detector.initialize();

      final ByteData data = await rootBundle
          .load('packages/dog_detection/assets/samples/sample_dog_1.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final mat = cv.imdecode(bytes, cv.IMREAD_COLOR);
      expect(mat.isEmpty, isFalse);

      try {
        final List<Dog> results = await detector.detectFromMat(
          mat,
          imageWidth: mat.cols,
          imageHeight: mat.rows,
        );
        expect(results, isNotEmpty);
      } finally {
        mat.dispose();
      }

      await detector.dispose();
    });

    testWidgets('should return valid bounding box', (tester) async {
      final detector = DogDetector();
      await detector.initialize();

      final ByteData data = await rootBundle
          .load('packages/dog_detection/assets/samples/sample_dog_1.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final mat = cv.imdecode(bytes, cv.IMREAD_COLOR);

      try {
        final List<Dog> results = await detector.detectFromMat(
          mat,
          imageWidth: mat.cols,
          imageHeight: mat.rows,
        );
        expect(results, isNotEmpty);

        final dog = results.first;
        expect(dog.boundingBox.right, greaterThan(dog.boundingBox.left));
        expect(dog.boundingBox.bottom, greaterThan(dog.boundingBox.top));
        expect(dog.boundingBox.left, greaterThanOrEqualTo(0));
        expect(dog.boundingBox.top, greaterThanOrEqualTo(0));
      } finally {
        mat.dispose();
      }

      await detector.dispose();
    });

    testWidgets('should have correct imageWidth and imageHeight',
        (tester) async {
      final detector = DogDetector();
      await detector.initialize();

      final ByteData data = await rootBundle
          .load('packages/dog_detection/assets/samples/sample_dog_1.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final mat = cv.imdecode(bytes, cv.IMREAD_COLOR);

      try {
        final List<Dog> results = await detector.detectFromMat(
          mat,
          imageWidth: mat.cols,
          imageHeight: mat.rows,
        );
        expect(results, isNotEmpty);

        final dog = results.first;
        expect(dog.imageWidth, mat.cols);
        expect(dog.imageHeight, mat.rows);
      } finally {
        mat.dispose();
      }

      await detector.dispose();
    });

    testWidgets('should detect landmarks when mode is full', (tester) async {
      final detector = DogDetector(
        mode: DogDetectionMode.full,
      );
      await detector.initialize();

      final ByteData data = await rootBundle
          .load('packages/dog_detection/assets/samples/sample_dog_1.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final mat = cv.imdecode(bytes, cv.IMREAD_COLOR);

      try {
        final List<Dog> results = await detector.detectFromMat(
          mat,
          imageWidth: mat.cols,
          imageHeight: mat.rows,
        );
        expect(results, isNotEmpty);
        expect(results.first.face!.hasLandmarks, true);
      } finally {
        mat.dispose();
      }

      await detector.dispose();
    });

    testWidgets('should return 46 landmarks', (tester) async {
      final detector = DogDetector(
        mode: DogDetectionMode.full,
      );
      await detector.initialize();

      final ByteData data = await rootBundle
          .load('packages/dog_detection/assets/samples/sample_dog_1.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final mat = cv.imdecode(bytes, cv.IMREAD_COLOR);

      try {
        final List<Dog> results = await detector.detectFromMat(
          mat,
          imageWidth: mat.cols,
          imageHeight: mat.rows,
        );
        expect(results, isNotEmpty);
        expect(results.first.face!.landmarks.length, numDogLandmarks);
      } finally {
        mat.dispose();
      }

      await detector.dispose();
    });

    testWidgets('should have all landmark types present', (tester) async {
      final detector = DogDetector(
        mode: DogDetectionMode.full,
      );
      await detector.initialize();

      final ByteData data = await rootBundle
          .load('packages/dog_detection/assets/samples/sample_dog_1.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final mat = cv.imdecode(bytes, cv.IMREAD_COLOR);

      try {
        final List<Dog> results = await detector.detectFromMat(
          mat,
          imageWidth: mat.cols,
          imageHeight: mat.rows,
        );
        expect(results, isNotEmpty);

        final face = results.first.face!;
        for (final type in DogLandmarkType.values) {
          final landmark = face.getLandmark(type);
          expect(landmark, isNotNull, reason: 'Missing landmark: $type');
          expect(landmark!.type, type);
        }
      } finally {
        mat.dispose();
      }

      await detector.dispose();
    });
  });

  // ---------------------------------------------------------------------------
  // 3. DogDetector - detect() bytes API
  // ---------------------------------------------------------------------------

  group('DogDetector - detect() bytes API', () {
    testWidgets('should detect dogs from image bytes', (tester) async {
      final detector = DogDetector();
      await detector.initialize();

      final ByteData data = await rootBundle
          .load('packages/dog_detection/assets/samples/sample_dog_1.png');
      final Uint8List bytes = data.buffer.asUint8List();

      final List<Dog> results = await detector.detect(bytes);

      expect(results, isNotEmpty);
      expect(results.first.boundingBox.right,
          greaterThan(results.first.boundingBox.left));
      expect(results.first.imageWidth, greaterThan(0));
      expect(results.first.imageHeight, greaterThan(0));

      await detector.dispose();
    });

    testWidgets('should handle PNG bytes correctly', (tester) async {
      final detector = DogDetector();
      await detector.initialize();

      final ByteData data = await rootBundle
          .load('packages/dog_detection/assets/samples/sample_dog_2.png');
      final Uint8List bytes = data.buffer.asUint8List();

      final List<Dog> results = await detector.detect(bytes);

      expect(results, isNotEmpty);

      await detector.dispose();
    });

    testWidgets('should produce matching results to detectFromMat',
        (tester) async {
      final detector = DogDetector();
      await detector.initialize();

      final ByteData data = await rootBundle
          .load('packages/dog_detection/assets/samples/sample_dog_1.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final mat = cv.imdecode(bytes, cv.IMREAD_COLOR);
      expect(mat.isEmpty, isFalse);

      try {
        final List<Dog> fromBytes = await detector.detect(bytes);
        final List<Dog> fromMat = await detector.detectFromMat(
          mat,
          imageWidth: mat.cols,
          imageHeight: mat.rows,
        );

        expect(fromBytes.length, fromMat.length);

        for (int i = 0; i < fromBytes.length; i++) {
          expect(fromBytes[i].face?.landmarks.length,
              fromMat[i].face?.landmarks.length);
        }
      } finally {
        mat.dispose();
      }

      await detector.dispose();
    });

    testWidgets('should return empty list for invalid bytes', (tester) async {
      final detector = DogDetector();
      await detector.initialize();

      final invalidBytes = Uint8List.fromList([0, 1, 2, 3, 4, 5]);
      final results = await detector.detect(invalidBytes);

      expect(results, isEmpty);

      await detector.dispose();
    });
  });

  // ---------------------------------------------------------------------------
  // 4. DogDetector - Boxes Only Mode
  // ---------------------------------------------------------------------------

  group('DogDetector - Boxes Only Mode', () {
    testWidgets('should return dog with no face in poseOnly mode',
        (tester) async {
      final detector = DogDetector(mode: DogDetectionMode.poseOnly);
      await detector.initialize();

      final ByteData data = await rootBundle
          .load('packages/dog_detection/assets/samples/sample_dog_1.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final mat = cv.imdecode(bytes, cv.IMREAD_COLOR);

      try {
        final List<Dog> results = await detector.detectFromMat(
          mat,
          imageWidth: mat.cols,
          imageHeight: mat.rows,
        );
        expect(results, isNotEmpty);

        final dog = results.first;
        expect(dog.face, isNull);

        // getLandmark should return null for any type.
        expect(dog.face?.getLandmark(DogLandmarkType.noseBridgeBottom), isNull);
      } finally {
        mat.dispose();
      }

      await detector.dispose();
    });

    testWidgets('should still have valid bounding box in poseOnly mode',
        (tester) async {
      final detector = DogDetector(mode: DogDetectionMode.poseOnly);
      await detector.initialize();

      final ByteData data = await rootBundle
          .load('packages/dog_detection/assets/samples/sample_dog_1.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final mat = cv.imdecode(bytes, cv.IMREAD_COLOR);

      try {
        final List<Dog> results = await detector.detectFromMat(
          mat,
          imageWidth: mat.cols,
          imageHeight: mat.rows,
        );
        expect(results, isNotEmpty);

        final bbox = results.first.boundingBox;
        expect(bbox.right, greaterThan(bbox.left));
        expect(bbox.bottom, greaterThan(bbox.top));
        expect(bbox.left, greaterThanOrEqualTo(0));
        expect(bbox.top, greaterThanOrEqualTo(0));
      } finally {
        mat.dispose();
      }

      await detector.dispose();
    });
  });

  // ---------------------------------------------------------------------------
  // 5. DogDetector - Error Recovery
  // ---------------------------------------------------------------------------

  group('DogDetector - Error Recovery', () {
    testWidgets('should recover after empty-result input (1x1 black image)',
        (tester) async {
      final detector = DogDetector();
      await detector.initialize();

      // A 1x1 black Mat is valid but produces no detections.
      final tiny = cv.Mat.zeros(1, 1, cv.MatType.CV_8UC3);
      final emptyResults = await detector.detectFromMat(
        tiny,
        imageWidth: 1,
        imageHeight: 1,
      );
      tiny.dispose();
      expect(emptyResults, isNotNull);

      // Should work normally after a no-detection run.
      final ByteData data = await rootBundle
          .load('packages/dog_detection/assets/samples/sample_dog_1.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final mat = cv.imdecode(bytes, cv.IMREAD_COLOR);
      try {
        final List<Dog> results = await detector.detectFromMat(
          mat,
          imageWidth: mat.cols,
          imageHeight: mat.rows,
        );
        expect(results, isNotEmpty);
      } finally {
        mat.dispose();
      }

      await detector.dispose();
    });
  });

  // ---------------------------------------------------------------------------
  // 6. DogDetector - Result Consistency
  // ---------------------------------------------------------------------------

  group('DogDetector - Result Consistency', () {
    testWidgets('should produce deterministic results (same image twice)',
        (tester) async {
      final detector = DogDetector();
      await detector.initialize();

      final ByteData data = await rootBundle
          .load('packages/dog_detection/assets/samples/sample_dog_1.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final mat1 = cv.imdecode(bytes, cv.IMREAD_COLOR);
      final mat2 = cv.imdecode(bytes, cv.IMREAD_COLOR);

      try {
        final List<Dog> first = await detector.detectFromMat(
          mat1,
          imageWidth: mat1.cols,
          imageHeight: mat1.rows,
        );
        final List<Dog> second = await detector.detectFromMat(
          mat2,
          imageWidth: mat2.cols,
          imageHeight: mat2.rows,
        );

        expect(first.length, second.length);

        for (int i = 0; i < first.length; i++) {
          expect(first[i].face?.landmarks.length,
              second[i].face?.landmarks.length);

          final firstLandmarks = first[i].face?.landmarks ?? [];
          final secondLandmarks = second[i].face?.landmarks ?? [];
          for (int j = 0; j < firstLandmarks.length; j++) {
            expect(
              firstLandmarks[j].x,
              closeTo(secondLandmarks[j].x, 1e-3),
              reason: 'Landmark x not deterministic at face=$i lm=$j',
            );
            expect(
              firstLandmarks[j].y,
              closeTo(secondLandmarks[j].y, 1e-3),
              reason: 'Landmark y not deterministic at face=$i lm=$j',
            );
          }
        }
      } finally {
        mat1.dispose();
        mat2.dispose();
      }

      await detector.dispose();
    });
  });

  // ---------------------------------------------------------------------------
  // 7. DogDetector - Configuration
  // ---------------------------------------------------------------------------

  group('DogDetector - Configuration', () {
    testWidgets('should respect cropMargin parameter', (tester) async {
      final detectorTight = DogDetector(cropMargin: 0.05);
      final detectorWide = DogDetector(cropMargin: 0.40);

      await detectorTight.initialize();
      await detectorWide.initialize();

      final ByteData data = await rootBundle
          .load('packages/dog_detection/assets/samples/sample_dog_1.png');
      final Uint8List bytes = data.buffer.asUint8List();

      // Both detectors should detect successfully with different margins.
      final tightResults = await detectorTight.detect(bytes);
      final wideResults = await detectorWide.detect(bytes);

      expect(tightResults, isNotEmpty,
          reason: 'Tight margin detector returned no results');
      expect(wideResults, isNotEmpty,
          reason: 'Wide margin detector returned no results');

      // Both should produce 46 landmarks.
      expect(tightResults.first.face!.landmarks.length, numDogLandmarks);
      expect(wideResults.first.face!.landmarks.length, numDogLandmarks);

      await detectorTight.dispose();
      await detectorWide.dispose();
    });

    testWidgets('should work with PerformanceConfig.disabled', (tester) async {
      final detector = DogDetector(
        performanceConfig: PerformanceConfig.disabled,
      );
      await detector.initialize();

      final ByteData data = await rootBundle
          .load('packages/dog_detection/assets/samples/sample_dog_1.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final List<Dog> results = await detector.detect(bytes);

      expect(results, isNotEmpty);

      await detector.dispose();
    });

    testWidgets('should expose configured mode and landmarkModel',
        (tester) async {
      final detector = DogDetector(
        mode: DogDetectionMode.poseOnly,
        landmarkModel: DogLandmarkModel.full,
        cropMargin: 0.15,
      );
      await detector.initialize();

      expect(detector.mode, DogDetectionMode.poseOnly);
      expect(detector.landmarkModel, DogLandmarkModel.full);
      expect(detector.cropMargin, 0.15);

      await detector.dispose();
    });
  });

  // ---------------------------------------------------------------------------
  // 8. DogDetector - Landmark Validation
  // ---------------------------------------------------------------------------

  group('DogDetector - Landmark Validation', () {
    testWidgets('all landmarks should have finite x,y coordinates',
        (tester) async {
      final detector = DogDetector(
        mode: DogDetectionMode.full,
      );
      await detector.initialize();

      final ByteData data = await rootBundle
          .load('packages/dog_detection/assets/samples/sample_dog_1.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final List<Dog> results = await detector.detect(bytes);

      expect(results, isNotEmpty);

      for (final dog in results) {
        for (final landmark in dog.face?.landmarks ?? []) {
          expect(landmark.x.isFinite, true,
              reason: 'x is not finite for ${landmark.type}');
          expect(landmark.y.isFinite, true,
              reason: 'y is not finite for ${landmark.type}');
        }
      }

      await detector.dispose();
    });

    testWidgets('landmarks should be within image bounds', (tester) async {
      final detector = DogDetector(
        mode: DogDetectionMode.full,
      );
      await detector.initialize();

      final ByteData data = await rootBundle
          .load('packages/dog_detection/assets/samples/sample_dog_1.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final mat = cv.imdecode(bytes, cv.IMREAD_COLOR);

      try {
        final List<Dog> results = await detector.detectFromMat(
          mat,
          imageWidth: mat.cols,
          imageHeight: mat.rows,
        );
        expect(results, isNotEmpty);

        final dog = results.first;
        for (final landmark in dog.face?.landmarks ?? []) {
          expect(landmark.x, greaterThanOrEqualTo(0),
              reason: '${landmark.type}.x is negative');
          expect(landmark.x, lessThanOrEqualTo(dog.imageWidth.toDouble()),
              reason: '${landmark.type}.x exceeds imageWidth');
          expect(landmark.y, greaterThanOrEqualTo(0),
              reason: '${landmark.type}.y is negative');
          expect(landmark.y, lessThanOrEqualTo(dog.imageHeight.toDouble()),
              reason: '${landmark.type}.y exceeds imageHeight');
        }
      } finally {
        mat.dispose();
      }

      await detector.dispose();
    });

    testWidgets('should handle different sample images (orientations)',
        (tester) async {
      final detector = DogDetector(
        mode: DogDetectionMode.full,
      );
      await detector.initialize();

      final samplePaths = [
        'packages/dog_detection/assets/samples/sample_dog_1.png',
        'packages/dog_detection/assets/samples/sample_dog_2.png',
        'packages/dog_detection/assets/samples/sample_dog_3.png',
      ];

      for (final path in samplePaths) {
        final ByteData data = await rootBundle.load(path);
        final Uint8List bytes = data.buffer.asUint8List();
        final mat = cv.imdecode(bytes, cv.IMREAD_COLOR);
        expect(mat.isEmpty, isFalse, reason: 'Failed to decode $path');

        try {
          final List<Dog> results = await detector.detectFromMat(
            mat,
            imageWidth: mat.cols,
            imageHeight: mat.rows,
          );

          // Whether detected or not, the call must not crash. If detected,
          // verify coordinate consistency.
          for (final dog in results) {
            expect(dog.imageWidth, mat.cols);
            expect(dog.imageHeight, mat.rows);
            for (final landmark in dog.face?.landmarks ?? []) {
              expect(landmark.x.isFinite, true,
                  reason: 'x not finite for ${landmark.type} in $path');
              expect(landmark.y.isFinite, true,
                  reason: 'y not finite for ${landmark.type} in $path');
            }
          }
        } finally {
          mat.dispose();
        }
      }

      await detector.dispose();
    });

    testWidgets('normalized coordinates should be in 0.0–1.0 range',
        (tester) async {
      final detector = DogDetector(
        mode: DogDetectionMode.full,
      );
      await detector.initialize();

      final ByteData data = await rootBundle
          .load('packages/dog_detection/assets/samples/sample_dog_1.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final List<Dog> results = await detector.detect(bytes);

      expect(results, isNotEmpty);

      final dog = results.first;
      for (final landmark in dog.face?.landmarks ?? []) {
        final xNorm = landmark.xNorm(dog.imageWidth);
        final yNorm = landmark.yNorm(dog.imageHeight);
        expect(xNorm, greaterThanOrEqualTo(0.0));
        expect(xNorm, lessThanOrEqualTo(1.0));
        expect(yNorm, greaterThanOrEqualTo(0.0));
        expect(yNorm, lessThanOrEqualTo(1.0));
      }

      await detector.dispose();
    });

    testWidgets('toPixel() should match truncated x,y', (tester) async {
      final detector = DogDetector(
        mode: DogDetectionMode.full,
      );
      await detector.initialize();

      final ByteData data = await rootBundle
          .load('packages/dog_detection/assets/samples/sample_dog_1.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final List<Dog> results = await detector.detect(bytes);

      expect(results, isNotEmpty);

      final dog = results.first;
      final landmark = dog.face!.landmarks.first;
      final point = landmark.toPixel(dog.imageWidth, dog.imageHeight);

      expect(point.x, landmark.x.toInt());
      expect(point.y, landmark.y.toInt());

      await detector.dispose();
    });
  });

  // ---------------------------------------------------------------------------
  // 9. DogDetectorIsolate
  // ---------------------------------------------------------------------------

  group('DogDetectorIsolate', () {
    testWidgets('should detect dogs via isolate', (tester) async {
      final isolate = await DogDetectorIsolate.spawn(
        mode: DogDetectionMode.full,
      );
      expect(isolate.isReady, true);

      final ByteData data = await rootBundle
          .load('packages/dog_detection/assets/samples/sample_dog_1.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final List<Dog> results = await isolate.detectDogs(bytes);

      expect(results, isNotEmpty);

      final dog = results.first;
      expect(dog.boundingBox.right, greaterThan(dog.boundingBox.left));
      expect(dog.boundingBox.bottom, greaterThan(dog.boundingBox.top));
      expect(dog.imageWidth, greaterThan(0));
      expect(dog.imageHeight, greaterThan(0));

      await isolate.dispose();
    });

    testWidgets('should detect dogs from Mat via isolate', (tester) async {
      final isolate = await DogDetectorIsolate.spawn(
        mode: DogDetectionMode.full,
      );

      final ByteData data = await rootBundle
          .load('packages/dog_detection/assets/samples/sample_dog_1.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final mat = cv.imdecode(bytes, cv.IMREAD_COLOR);
      expect(mat.isEmpty, isFalse);

      try {
        final List<Dog> results = await isolate.detectDogsFromMat(mat);

        expect(results, isNotEmpty);

        final dog = results.first;
        expect(dog.boundingBox.right, greaterThan(dog.boundingBox.left));
        expect(dog.face!.landmarks.length, numDogLandmarks);
      } finally {
        mat.dispose();
      }

      await isolate.dispose();
    });

    testWidgets('should match main thread results', (tester) async {
      final detector = DogDetector();
      await detector.initialize();

      final isolate = await DogDetectorIsolate.spawn(
        mode: DogDetectionMode.full,
      );

      final ByteData data = await rootBundle
          .load('packages/dog_detection/assets/samples/sample_dog_1.png');
      final Uint8List bytes = data.buffer.asUint8List();

      final List<Dog> mainResults = await detector.detect(bytes);
      final List<Dog> isolateResults = await isolate.detectDogs(bytes);

      expect(mainResults.length, isolateResults.length);

      for (int i = 0; i < mainResults.length; i++) {
        expect(mainResults[i].face?.landmarks.length,
            isolateResults[i].face?.landmarks.length,
            reason: 'Landmark count mismatch at index $i');
      }

      await detector.dispose();
      await isolate.dispose();
    });

    testWidgets('should support dispose and re-spawn', (tester) async {
      final first = await DogDetectorIsolate.spawn();
      expect(first.isReady, true);
      await first.dispose();
      expect(first.isReady, false);

      // Spawn a new isolate after the previous one was disposed.
      final second = await DogDetectorIsolate.spawn();
      expect(second.isReady, true);

      final ByteData data = await rootBundle
          .load('packages/dog_detection/assets/samples/sample_dog_1.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final List<Dog> results = await second.detectDogs(bytes);

      expect(results, isNotEmpty);

      await second.dispose();
    });

    testWidgets('should handle two sequential detectDogs calls on same isolate',
        (tester) async {
      final isolate = await DogDetectorIsolate.spawn(
        mode: DogDetectionMode.full,
      );
      expect(isolate.isReady, true);

      final ByteData data = await rootBundle
          .load('packages/dog_detection/assets/samples/sample_dog_1.png');
      final Uint8List bytes = data.buffer.asUint8List();

      final List<Dog> first = await isolate.detectDogs(bytes);
      expect(first, isNotEmpty);

      final List<Dog> second = await isolate.detectDogs(bytes);
      expect(second, isNotEmpty);

      expect(first.length, second.length);

      await isolate.dispose();
    });

    testWidgets(
        'should handle three sequential detectDogs calls on same isolate',
        (tester) async {
      final isolate = await DogDetectorIsolate.spawn(
        mode: DogDetectionMode.full,
      );
      expect(isolate.isReady, true);

      final ByteData data = await rootBundle
          .load('packages/dog_detection/assets/samples/sample_dog_1.png');
      final Uint8List bytes = data.buffer.asUint8List();

      final List<Dog> first = await isolate.detectDogs(bytes);
      expect(first, isNotEmpty);

      final List<Dog> second = await isolate.detectDogs(bytes);
      expect(second, isNotEmpty);

      final List<Dog> third = await isolate.detectDogs(bytes);
      expect(third, isNotEmpty);

      expect(first.length, second.length);
      expect(second.length, third.length);

      await isolate.dispose();
    });

    testWidgets(
        'should handle two sequential detectDogsFromMat calls on same isolate',
        (tester) async {
      final isolate = await DogDetectorIsolate.spawn(
        mode: DogDetectionMode.full,
      );
      expect(isolate.isReady, true);

      final ByteData data = await rootBundle
          .load('packages/dog_detection/assets/samples/sample_dog_1.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final mat = cv.imdecode(bytes, cv.IMREAD_COLOR);
      expect(mat.isEmpty, isFalse);

      try {
        final List<Dog> first = await isolate.detectDogsFromMat(mat);
        expect(first, isNotEmpty);

        final List<Dog> second = await isolate.detectDogsFromMat(mat);
        expect(second, isNotEmpty);

        expect(first.length, second.length);
      } finally {
        mat.dispose();
      }

      await isolate.dispose();
    });
  });

  // ---------------------------------------------------------------------------
  // 10. DogDetector - Dispose
  // ---------------------------------------------------------------------------

  group('DogDetector - Dispose', () {
    testWidgets('should dispose cleanly', (tester) async {
      final detector = DogDetector();
      await detector.initialize();
      expect(detector.isInitialized, true);

      await detector.dispose();
      expect(detector.isInitialized, false);
    });

    testWidgets('should not be usable after dispose', (tester) async {
      final detector = DogDetector();
      await detector.initialize();
      await detector.dispose();

      final bytes = _TestUtils.createTinyBlackPng();
      expect(
        () => detector.detect(bytes),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('not initialized'),
        )),
      );
    });

    testWidgets('Dog.toString() should not crash', (tester) async {
      final detector = DogDetector();
      await detector.initialize();

      final ByteData data = await rootBundle
          .load('packages/dog_detection/assets/samples/sample_dog_1.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final List<Dog> results = await detector.detect(bytes);

      expect(results, isNotEmpty);

      final dogString = results.first.toString();
      expect(dogString, isNotEmpty);
      expect(dogString, contains('Dog('));
      expect(dogString, contains('score='));

      await detector.dispose();
    });
  });
}
