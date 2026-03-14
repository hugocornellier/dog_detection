import 'package:flutter_test/flutter_test.dart';
import 'package:dog_detection/dog_detection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------------
  // DogDetectionMode enum
  // ---------------------------------------------------------------------------
  group('DogDetectionMode enum', () {
    test('has exactly 3 values', () {
      expect(DogDetectionMode.values.length, 3);
    });

    test('values are full, poseOnly and faceOnly', () {
      expect(DogDetectionMode.values.contains(DogDetectionMode.full), true);
      expect(DogDetectionMode.values.contains(DogDetectionMode.poseOnly), true);
      expect(DogDetectionMode.values.contains(DogDetectionMode.faceOnly), true);
    });

    test('full has index 0', () {
      expect(DogDetectionMode.full.index, 0);
    });

    test('poseOnly has index 1', () {
      expect(DogDetectionMode.poseOnly.index, 1);
    });

    test('faceOnly has index 2', () {
      expect(DogDetectionMode.faceOnly.index, 2);
    });

    test('name property works', () {
      expect(DogDetectionMode.full.name, 'full');
      expect(DogDetectionMode.poseOnly.name, 'poseOnly');
      expect(DogDetectionMode.faceOnly.name, 'faceOnly');
    });
  });

  // ---------------------------------------------------------------------------
  // DogLandmarkModel enum
  // ---------------------------------------------------------------------------
  group('DogLandmarkModel enum', () {
    test('has exactly 2 values', () {
      expect(DogLandmarkModel.values.length, 2);
    });

    test('full is at index 0', () {
      expect(DogLandmarkModel.full.index, 0);
    });

    test('ensemble is at index 1', () {
      expect(DogLandmarkModel.ensemble.index, 1);
    });

    test('name property works', () {
      expect(DogLandmarkModel.full.name, 'full');
    });
  });

  // ---------------------------------------------------------------------------
  // DogLandmarkType enum — 46 values, DogFLW dataset topology
  // ---------------------------------------------------------------------------
  group('DogLandmarkType enum', () {
    test('has exactly 46 values', () {
      expect(DogLandmarkType.values.length, 46);
    });

    test('ear contour indices (interleaved left/right)', () {
      expect(DogLandmarkType.leftEar0.index, 0);
      expect(DogLandmarkType.rightEar0.index, 1);
      expect(DogLandmarkType.leftEar1.index, 2);
      expect(DogLandmarkType.rightEar1.index, 3);
      expect(DogLandmarkType.leftEar2.index, 4);
      expect(DogLandmarkType.rightEar2.index, 5);
      expect(DogLandmarkType.leftEar3.index, 6);
      expect(DogLandmarkType.rightEar3.index, 7);
      expect(DogLandmarkType.leftEar4.index, 8);
      expect(DogLandmarkType.rightEar4.index, 9);
      expect(DogLandmarkType.leftEar5.index, 10);
      expect(DogLandmarkType.rightEar5.index, 11);
      expect(DogLandmarkType.leftEar6.index, 12);
      expect(DogLandmarkType.rightEar6.index, 13);
    });

    test('nose bridge indices', () {
      expect(DogLandmarkType.noseBridgeTop.index, 14);
      expect(DogLandmarkType.noseBridgeBottom.index, 15);
    });

    test('eye indices', () {
      expect(DogLandmarkType.leftEyeOuter.index, 16);
      expect(DogLandmarkType.rightEyeOuter.index, 17);
      expect(DogLandmarkType.leftEyeTop.index, 18);
      expect(DogLandmarkType.rightEyeTop.index, 19);
      expect(DogLandmarkType.leftEyeInner.index, 20);
      expect(DogLandmarkType.rightEyeInner.index, 21);
      expect(DogLandmarkType.leftEyeBottom.index, 22);
      expect(DogLandmarkType.rightEyeBottom.index, 23);
    });

    test('nose ring indices (24–31)', () {
      expect(DogLandmarkType.noseRing0.index, 24);
      expect(DogLandmarkType.noseRing1.index, 25);
      expect(DogLandmarkType.noseRing2.index, 26);
      expect(DogLandmarkType.noseRing3.index, 27);
      expect(DogLandmarkType.noseRing4.index, 28);
      expect(DogLandmarkType.noseRing5.index, 29);
      expect(DogLandmarkType.noseRing6.index, 30);
      expect(DogLandmarkType.noseRing7.index, 31);
    });

    test('mouth/chin contour indices (32–45)', () {
      expect(DogLandmarkType.mouthChin0.index, 32);
      expect(DogLandmarkType.mouthChin1.index, 33);
      expect(DogLandmarkType.mouthChin2.index, 34);
      expect(DogLandmarkType.mouthChin3.index, 35);
      expect(DogLandmarkType.mouthChin4.index, 36);
      expect(DogLandmarkType.mouthChin5.index, 37);
      expect(DogLandmarkType.mouthChin6.index, 38);
      expect(DogLandmarkType.mouthChin7.index, 39);
      expect(DogLandmarkType.mouthChin8.index, 40);
      expect(DogLandmarkType.mouthChin9.index, 41);
      expect(DogLandmarkType.mouthChin10.index, 42);
      expect(DogLandmarkType.mouthChin11.index, 43);
      expect(DogLandmarkType.mouthChin12.index, 44);
      expect(DogLandmarkType.mouthChin13.index, 45);
    });

    test('verify specific landmark names by index', () {
      expect(DogLandmarkType.values[0].name, 'leftEar0');
      expect(DogLandmarkType.values[1].name, 'rightEar0');
      expect(DogLandmarkType.values[14].name, 'noseBridgeTop');
      expect(DogLandmarkType.values[15].name, 'noseBridgeBottom');
      expect(DogLandmarkType.values[24].name, 'noseRing0');
      expect(DogLandmarkType.values[31].name, 'noseRing7');
      expect(DogLandmarkType.values[32].name, 'mouthChin0');
      expect(DogLandmarkType.values[45].name, 'mouthChin13');
    });
  });

  // ---------------------------------------------------------------------------
  // numDogLandmarks constant
  // ---------------------------------------------------------------------------
  group('numDogLandmarks constant', () {
    test('equals 46', () {
      expect(numDogLandmarks, 46);
    });

    test('matches DogLandmarkType.values.length', () {
      expect(numDogLandmarks, DogLandmarkType.values.length);
    });
  });

  // ---------------------------------------------------------------------------
  // Point class
  // ---------------------------------------------------------------------------
  group('Point', () {
    test('constructor stores x and y as doubles', () {
      final point = Point(42.0, 99.0);
      expect(point.x, 42.0);
      expect(point.y, 99.0);
    });

    test('handles zero coordinates', () {
      final point = Point(0.0, 0.0);
      expect(point.x, 0.0);
      expect(point.y, 0.0);
    });

    test('handles negative coordinates', () {
      final point = Point(-10.0, -20.0);
      expect(point.x, -10.0);
      expect(point.y, -20.0);
    });

    test('handles large coordinates', () {
      final point = Point(9999.0, 8888.0);
      expect(point.x, 9999.0);
      expect(point.y, 8888.0);
    });
  });

  // ---------------------------------------------------------------------------
  // BoundingBox class
  // ---------------------------------------------------------------------------
  group('BoundingBox', () {
    test('ltrb constructor stores left, top, right, bottom', () {
      final bbox = BoundingBox.ltrb(10.5, 20.3, 100.7, 200.1);
      expect(bbox.left, 10.5);
      expect(bbox.top, 20.3);
      expect(bbox.right, 100.7);
      expect(bbox.bottom, 200.1);
    });

    test('toMap produces correct map', () {
      final bbox = BoundingBox.ltrb(1.0, 2.0, 3.0, 4.0);
      final map = bbox.toMap();
      expect(map.containsKey('topLeft'), true);
      expect(map.containsKey('topRight'), true);
      expect(map.containsKey('bottomRight'), true);
      expect(map.containsKey('bottomLeft'), true);
    });

    test('fromMap factory reconstructs correctly', () {
      final bbox = BoundingBox.ltrb(10.5, 20.3, 100.7, 200.1);
      final restored = BoundingBox.fromMap(bbox.toMap());
      expect(restored.left, 10.5);
      expect(restored.top, 20.3);
      expect(restored.right, 100.7);
      expect(restored.bottom, 200.1);
    });

    test('toMap/fromMap round-trip', () {
      final original = BoundingBox.ltrb(10.5, 20.3, 100.7, 200.1);
      final restored = BoundingBox.fromMap(original.toMap());
      expect(restored.left, 10.5);
      expect(restored.top, 20.3);
      expect(restored.right, 100.7);
      expect(restored.bottom, 200.1);
    });

    test('zero-size box is preserved', () {
      final bbox = BoundingBox.ltrb(50.0, 50.0, 50.0, 50.0);
      final restored = BoundingBox.fromMap(bbox.toMap());
      expect(restored.left, restored.right);
      expect(restored.top, restored.bottom);
    });

    test('negative coordinates are stored as-is', () {
      final bbox = BoundingBox.ltrb(-50.0, -30.0, -10.0, -5.0);
      expect(bbox.left, -50.0);
      expect(bbox.top, -30.0);
      expect(bbox.right, -10.0);
      expect(bbox.bottom, -5.0);
    });

    test('negative coordinates round-trip via toMap/fromMap', () {
      final original = BoundingBox.ltrb(-100.0, -80.0, -20.0, -10.0);
      final restored = BoundingBox.fromMap(original.toMap());
      expect(restored.left, -100.0);
      expect(restored.top, -80.0);
      expect(restored.right, -20.0);
      expect(restored.bottom, -10.0);
    });
  });

  // ---------------------------------------------------------------------------
  // DogLandmark class
  // ---------------------------------------------------------------------------
  group('DogLandmark', () {
    test('constructor stores all fields correctly', () {
      final landmark = DogLandmark(
        type: DogLandmarkType.noseBridgeBottom,
        x: 100.5,
        y: 200.3,
      );
      expect(landmark.type, DogLandmarkType.noseBridgeBottom);
      expect(landmark.x, 100.5);
      expect(landmark.y, 200.3);
    });

    test('toMap produces correct map with type, x, y keys', () {
      final landmark = DogLandmark(
        type: DogLandmarkType.leftEar0,
        x: 10.0,
        y: 20.0,
      );
      final map = landmark.toMap();
      expect(map['type'], 'leftEar0');
      expect(map['x'], 10.0);
      expect(map['y'], 20.0);
      expect(map.containsKey('type'), true);
      expect(map.containsKey('x'), true);
      expect(map.containsKey('y'), true);
    });

    test('fromMap factory reconstructs correctly', () {
      final map = {'type': 'noseBridgeTop', 'x': 50.0, 'y': 60.0};
      final landmark = DogLandmark.fromMap(map);
      expect(landmark.type, DogLandmarkType.noseBridgeTop);
      expect(landmark.x, 50.0);
      expect(landmark.y, 60.0);
    });

    test('fromMap handles integer coordinates', () {
      final map = {'type': 'noseRing0', 'x': 100, 'y': 200};
      final landmark = DogLandmark.fromMap(map);
      expect(landmark.type, DogLandmarkType.noseRing0);
      expect(landmark.x, 100.0);
      expect(landmark.y, 200.0);
    });

    test('toMap/fromMap round-trip', () {
      final original = DogLandmark(
        type: DogLandmarkType.mouthChin7,
        x: 123.45,
        y: 678.9,
      );
      final restored = DogLandmark.fromMap(original.toMap());
      expect(restored.type, DogLandmarkType.mouthChin7);
      expect(restored.x, 123.45);
      expect(restored.y, 678.9);
    });

    test('round-trip all landmark types', () {
      for (final type in DogLandmarkType.values) {
        final original = DogLandmark(type: type, x: 50.0, y: 50.0);
        final restored = DogLandmark.fromMap(original.toMap());
        expect(restored.type, type);
      }
    });

    test('xNorm returns x / width', () {
      final landmark = DogLandmark(
        type: DogLandmarkType.noseBridgeBottom,
        x: 320.0,
        y: 240.0,
      );
      expect(landmark.xNorm(640), closeTo(0.5, 0.0001));
    });

    test('yNorm returns y / height', () {
      final landmark = DogLandmark(
        type: DogLandmarkType.noseBridgeBottom,
        x: 320.0,
        y: 240.0,
      );
      expect(landmark.yNorm(480), closeTo(0.5, 0.0001));
    });

    test('xNorm clamps negative x to 0.0', () {
      final landmark = DogLandmark(
        type: DogLandmarkType.leftEar0,
        x: -10.0,
        y: 100.0,
      );
      expect(landmark.xNorm(640), 0.0);
    });

    test('yNorm clamps negative y to 0.0', () {
      final landmark = DogLandmark(
        type: DogLandmarkType.leftEar0,
        x: 100.0,
        y: -50.0,
      );
      expect(landmark.yNorm(480), 0.0);
    });

    test('xNorm clamps x beyond width to 1.0', () {
      final landmark = DogLandmark(
        type: DogLandmarkType.rightEar0,
        x: 800.0,
        y: 100.0,
      );
      expect(landmark.xNorm(640), 1.0);
    });

    test('yNorm clamps y beyond height to 1.0', () {
      final landmark = DogLandmark(
        type: DogLandmarkType.rightEar0,
        x: 100.0,
        y: 600.0,
      );
      expect(landmark.yNorm(480), 1.0);
    });

    test('xNorm with width = 1 clamps out-of-range x', () {
      final inRange = DogLandmark(
        type: DogLandmarkType.noseBridgeTop,
        x: 0.5,
        y: 0.0,
      );
      expect(inRange.xNorm(1), closeTo(0.5, 0.0001));

      final over = DogLandmark(
        type: DogLandmarkType.noseBridgeTop,
        x: 2.0,
        y: 0.0,
      );
      expect(over.xNorm(1), 1.0);

      final under = DogLandmark(
        type: DogLandmarkType.noseBridgeTop,
        x: -1.0,
        y: 0.0,
      );
      expect(under.xNorm(1), 0.0);
    });

    test('yNorm with height = 1 clamps out-of-range y', () {
      final inRange = DogLandmark(
        type: DogLandmarkType.noseBridgeTop,
        x: 0.0,
        y: 0.5,
      );
      expect(inRange.yNorm(1), closeTo(0.5, 0.0001));

      final over = DogLandmark(
        type: DogLandmarkType.noseBridgeTop,
        x: 0.0,
        y: 2.0,
      );
      expect(over.yNorm(1), 1.0);

      final under = DogLandmark(
        type: DogLandmarkType.noseBridgeTop,
        x: 0.0,
        y: -1.0,
      );
      expect(under.yNorm(1), 0.0);
    });

    test('toPixel returns Point with coordinates', () {
      final landmark = DogLandmark(
        type: DogLandmarkType.leftEyeOuter,
        x: 123.7,
        y: 456.9,
      );
      final point = landmark.toPixel(640, 480);
      expect(point.x, 123.7);
      expect(point.y, 456.9);
    });

    test('toPixel with whole-number coordinates', () {
      final landmark = DogLandmark(
        type: DogLandmarkType.rightEyeOuter,
        x: 200.0,
        y: 150.0,
      );
      final point = landmark.toPixel(640, 480);
      expect(point.x, 200.0);
      expect(point.y, 150.0);
    });

    test('edge case: zero coordinates', () {
      final landmark = DogLandmark(
        type: DogLandmarkType.mouthChin0,
        x: 0.0,
        y: 0.0,
      );
      expect(landmark.x, 0.0);
      expect(landmark.y, 0.0);
      expect(landmark.xNorm(640), 0.0);
      expect(landmark.yNorm(480), 0.0);
      final point = landmark.toPixel(640, 480);
      expect(point.x, 0.0);
      expect(point.y, 0.0);
    });

    test('edge case: negative coordinates', () {
      final landmark = DogLandmark(
        type: DogLandmarkType.noseRing3,
        x: -10.9,
        y: -5.3,
      );
      expect(landmark.x, -10.9);
      expect(landmark.y, -5.3);
      final point = landmark.toPixel(640, 480);
      expect(point.x, -10.9);
      expect(point.y, -5.3);
    });

    test('edge case: very large coordinates', () {
      final landmark = DogLandmark(
        type: DogLandmarkType.noseRing7,
        x: 10000.0,
        y: 10000.0,
      );
      expect(landmark.x, 10000.0);
      expect(landmark.y, 10000.0);
      final restored = DogLandmark.fromMap(landmark.toMap());
      expect(restored.x, 10000.0);
      expect(restored.y, 10000.0);
    });
  });

  // ---------------------------------------------------------------------------
  // DogFace class
  // ---------------------------------------------------------------------------
  group('DogFace', () {
    DogLandmark makeLandmark(DogLandmarkType type,
        {double x = 0, double y = 0}) {
      return DogLandmark(type: type, x: x, y: y);
    }

    DogFace makeFullFace() {
      return DogFace(
        boundingBox: BoundingBox.ltrb(10.0, 20.0, 200.0, 300.0),
        landmarks: [
          makeLandmark(DogLandmarkType.noseBridgeBottom, x: 150.0, y: 180.0),
          makeLandmark(DogLandmarkType.leftEyeOuter, x: 100.0, y: 120.0),
          makeLandmark(DogLandmarkType.rightEyeOuter, x: 200.0, y: 120.0),
        ],
      );
    }

    test('constructor stores all fields', () {
      final face = makeFullFace();
      expect(face.boundingBox.left, 10.0);
      expect(face.boundingBox.top, 20.0);
      expect(face.boundingBox.right, 200.0);
      expect(face.boundingBox.bottom, 300.0);
      expect(face.landmarks.length, 3);
    });

    test('getLandmark returns correct landmark by type', () {
      final face = makeFullFace();
      final nose = face.getLandmark(DogLandmarkType.noseBridgeBottom);
      expect(nose, isNotNull);
      expect(nose!.type, DogLandmarkType.noseBridgeBottom);
      expect(nose.x, 150.0);
      expect(nose.y, 180.0);
    });

    test('getLandmark returns null for missing type', () {
      final face = makeFullFace();
      final missing = face.getLandmark(DogLandmarkType.leftEar0);
      expect(missing, isNull);
    });

    test('getLandmark returns null for empty landmarks list', () {
      final face = DogFace(
        boundingBox: BoundingBox.ltrb(0, 0, 100, 100),
        landmarks: [],
      );
      expect(face.getLandmark(DogLandmarkType.noseBridgeBottom), isNull);
    });

    test('hasLandmarks returns true when landmarks non-empty', () {
      final face = makeFullFace();
      expect(face.hasLandmarks, true);
    });

    test('hasLandmarks returns false when landmarks empty', () {
      final face = DogFace(
        boundingBox: BoundingBox.ltrb(0, 0, 100, 100),
        landmarks: [],
      );
      expect(face.hasLandmarks, false);
    });

    test('toMap serializes bbox and landmarks list', () {
      final face = makeFullFace();
      final map = face.toMap();

      expect(map.containsKey('boundingBox'), true);
      expect(map.containsKey('landmarks'), true);

      final bbox = map['boundingBox'] as Map<String, dynamic>;
      expect(bbox['left'], 10.0);
      expect(bbox['top'], 20.0);
      expect(bbox['right'], 200.0);
      expect(bbox['bottom'], 300.0);

      final landmarksList = map['landmarks'] as List;
      expect(landmarksList.length, 3);
    });

    test('fromMap deserializes correctly', () {
      final map = {
        'boundingBox': {
          'left': 5.0,
          'top': 10.0,
          'right': 200.0,
          'bottom': 300.0
        },
        'landmarks': [
          {'type': 'noseBridgeTop', 'x': 100.0, 'y': 150.0},
        ],
      };
      final face = DogFace.fromMap(map);
      expect(face.boundingBox.left, 5.0);
      expect(face.landmarks.length, 1);
      expect(face.landmarks[0].type, DogLandmarkType.noseBridgeTop);
    });

    test('toMap/fromMap round-trip', () {
      final original = makeFullFace();
      final restored = DogFace.fromMap(original.toMap());

      expect(restored.boundingBox.left, original.boundingBox.left);
      expect(restored.boundingBox.top, original.boundingBox.top);
      expect(restored.boundingBox.right, original.boundingBox.right);
      expect(restored.boundingBox.bottom, original.boundingBox.bottom);
      expect(restored.landmarks.length, original.landmarks.length);
      expect(restored.landmarks[0].type, DogLandmarkType.noseBridgeBottom);
    });

    test('fromMap with empty landmarks list', () {
      final map = {
        'boundingBox': {
          'left': 0.0,
          'top': 0.0,
          'right': 100.0,
          'bottom': 100.0
        },
        'landmarks': [],
      };
      final face = DogFace.fromMap(map);
      expect(face.landmarks, isEmpty);
    });

    test('toString does not crash', () {
      final face = makeFullFace();
      expect(() => face.toString(), returnsNormally);
    });

    test('toString contains DogFace prefix', () {
      final face = makeFullFace();
      final str = face.toString();
      expect(str, contains('DogFace('));
    });

    test('toString with no landmarks does not crash', () {
      final face = DogFace(
        boundingBox: BoundingBox.ltrb(0, 0, 100, 100),
        landmarks: [],
      );
      expect(() => face.toString(), returnsNormally);
      final str = face.toString();
      expect(str, contains('landmarks=0'));
    });

    test('edge case: empty landmarks list', () {
      final face = DogFace(
        boundingBox: BoundingBox.ltrb(0, 0, 100, 100),
        landmarks: [],
      );
      expect(face.landmarks, isEmpty);
      expect(face.hasLandmarks, false);
      expect(face.getLandmark(DogLandmarkType.noseRing0), isNull);
    });

    test('edge case: single landmark', () {
      final landmark =
          makeLandmark(DogLandmarkType.mouthChin13, x: 55.0, y: 77.0);
      final face = DogFace(
        boundingBox: BoundingBox.ltrb(0, 0, 100, 100),
        landmarks: [landmark],
      );
      expect(face.landmarks.length, 1);
      expect(face.hasLandmarks, true);
      final found = face.getLandmark(DogLandmarkType.mouthChin13);
      expect(found, isNotNull);
      expect(found!.x, 55.0);
      expect(found.y, 77.0);
    });

    test('getLandmark finds all types when all are present', () {
      final landmarks =
          DogLandmarkType.values.map((type) => makeLandmark(type)).toList();
      final face = DogFace(
        boundingBox: BoundingBox.ltrb(0, 0, 100, 100),
        landmarks: landmarks,
      );

      for (final type in DogLandmarkType.values) {
        final lm = face.getLandmark(type);
        expect(lm, isNotNull, reason: 'getLandmark returned null for $type');
        expect(lm!.type, type);
      }
    });
  });

  // ---------------------------------------------------------------------------
  // dogLandmarkConnections constant
  // ---------------------------------------------------------------------------
  group('dogLandmarkConnections constant', () {
    test('is non-empty list', () {
      expect(dogLandmarkConnections, isNotEmpty);
    });

    test('each connection has exactly 2 elements', () {
      for (final connection in dogLandmarkConnections) {
        expect(
          connection.length,
          2,
          reason: 'Connection does not have 2 elements: $connection',
        );
      }
    });

    test('all elements are valid DogLandmarkType values', () {
      final allTypes = DogLandmarkType.values.toSet();
      for (final connection in dogLandmarkConnections) {
        expect(
          allTypes.contains(connection[0]),
          true,
          reason: 'Invalid start: ${connection[0]}',
        );
        expect(
          allTypes.contains(connection[1]),
          true,
          reason: 'Invalid end: ${connection[1]}',
        );
      }
    });

    test('left ear closed contour (7 connections)', () {
      final leftEarTypes = {
        DogLandmarkType.leftEar0,
        DogLandmarkType.leftEar1,
        DogLandmarkType.leftEar2,
        DogLandmarkType.leftEar3,
        DogLandmarkType.leftEar4,
        DogLandmarkType.leftEar5,
        DogLandmarkType.leftEar6,
      };
      final leftEarConnections = dogLandmarkConnections
          .where(
              (c) => leftEarTypes.contains(c[0]) && leftEarTypes.contains(c[1]))
          .toList();
      expect(leftEarConnections.length, 7);
    });

    test('right ear closed contour (7 connections)', () {
      final rightEarTypes = {
        DogLandmarkType.rightEar0,
        DogLandmarkType.rightEar1,
        DogLandmarkType.rightEar2,
        DogLandmarkType.rightEar3,
        DogLandmarkType.rightEar4,
        DogLandmarkType.rightEar5,
        DogLandmarkType.rightEar6,
      };
      final rightEarConnections = dogLandmarkConnections
          .where((c) =>
              rightEarTypes.contains(c[0]) && rightEarTypes.contains(c[1]))
          .toList();
      expect(rightEarConnections.length, 7);
    });

    test('left eye forms a loop (4 connections)', () {
      final leftEyeTypes = {
        DogLandmarkType.leftEyeOuter,
        DogLandmarkType.leftEyeTop,
        DogLandmarkType.leftEyeInner,
        DogLandmarkType.leftEyeBottom,
      };
      final leftEyeConnections = dogLandmarkConnections
          .where(
              (c) => leftEyeTypes.contains(c[0]) && leftEyeTypes.contains(c[1]))
          .toList();
      expect(leftEyeConnections.length, 4);
    });

    test('right eye forms a loop (4 connections)', () {
      final rightEyeTypes = {
        DogLandmarkType.rightEyeOuter,
        DogLandmarkType.rightEyeTop,
        DogLandmarkType.rightEyeInner,
        DogLandmarkType.rightEyeBottom,
      };
      final rightEyeConnections = dogLandmarkConnections
          .where((c) =>
              rightEyeTypes.contains(c[0]) && rightEyeTypes.contains(c[1]))
          .toList();
      expect(rightEyeConnections.length, 4);
    });

    test('only ears and eyes have connections', () {
      for (final c in dogLandmarkConnections) {
        final name0 = c[0].name;
        final name1 = c[1].name;
        expect(
          name0.startsWith('leftEar') ||
              name0.startsWith('rightEar') ||
              name0.startsWith('leftEye') ||
              name0.startsWith('rightEye'),
          true,
          reason: 'Unexpected connection start: $name0',
        );
        expect(
          name1.startsWith('leftEar') ||
              name1.startsWith('rightEar') ||
              name1.startsWith('leftEye') ||
              name1.startsWith('rightEye'),
          true,
          reason: 'Unexpected connection end: $name1',
        );
      }
    });

    test('total connection count is 22', () {
      // 7 (left ear) + 7 (right ear) + 4 (left eye) + 4 (right eye) = 22
      expect(dogLandmarkConnections.length, 22);
    });
  });

  group('dogLandmarkFlipIndex', () {
    test('has exactly 46 entries', () {
      expect(dogLandmarkFlipIndex.length, 46);
    });

    test('all indices are valid (0-45)', () {
      for (final idx in dogLandmarkFlipIndex) {
        expect(idx, greaterThanOrEqualTo(0));
        expect(idx, lessThan(46));
      }
    });

    test('is a valid permutation (each index appears exactly once)', () {
      final sorted = List<int>.from(dogLandmarkFlipIndex)..sort();
      expect(sorted, List.generate(46, (i) => i));
    });

    test('is an involution (applying twice gives identity)', () {
      for (int i = 0; i < 46; i++) {
        expect(dogLandmarkFlipIndex[dogLandmarkFlipIndex[i]], i);
      }
    });

    test('swaps left/right ear pairs', () {
      // leftEar0 (0) <-> rightEar0 (1)
      expect(dogLandmarkFlipIndex[0], 1);
      expect(dogLandmarkFlipIndex[1], 0);
      // leftEar3 (6) <-> rightEar3 (7)
      expect(dogLandmarkFlipIndex[6], 7);
      expect(dogLandmarkFlipIndex[7], 6);
    });

    test('swaps left/right eye pairs', () {
      // leftEyeOuter (16) <-> rightEyeOuter (17)
      expect(dogLandmarkFlipIndex[16], 17);
      expect(dogLandmarkFlipIndex[17], 16);
      // leftEyeTop (18) <-> rightEyeTop (19)
      expect(dogLandmarkFlipIndex[18], 19);
      expect(dogLandmarkFlipIndex[19], 18);
    });

    test('swaps nose bridge', () {
      // noseBridgeTop (14) <-> noseBridgeBottom (15)
      expect(dogLandmarkFlipIndex[14], 15);
      expect(dogLandmarkFlipIndex[15], 14);
    });

    test('matches Python FLIP_INDEX exactly', () {
      const pythonFlipIndex = [
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
      expect(dogLandmarkFlipIndex, pythonFlipIndex);
    });
  });

  // ---------------------------------------------------------------------------
  // Dog class
  // ---------------------------------------------------------------------------
  group('Dog', () {
    DogFace makeFace() {
      return DogFace(
        boundingBox: BoundingBox.ltrb(50.0, 60.0, 150.0, 160.0),
        landmarks: [
          DogLandmark(
              type: DogLandmarkType.noseBridgeBottom, x: 100.0, y: 110.0),
          DogLandmark(type: DogLandmarkType.leftEyeOuter, x: 80.0, y: 90.0),
        ],
      );
    }

    AnimalPose makePose() {
      return AnimalPose(landmarks: [
        AnimalPoseLandmark(
          type: AnimalPoseLandmarkType.neckBase,
          x: 100.0,
          y: 50.0,
          confidence: 0.98,
        ),
        AnimalPoseLandmark(
          type: AnimalPoseLandmarkType.tailEnd,
          x: 300.0,
          y: 200.0,
          confidence: 0.85,
        ),
      ]);
    }

    Dog makeFullDog() {
      return Dog(
        boundingBox: BoundingBox.ltrb(10.0, 20.0, 400.0, 350.0),
        score: 0.95,
        species: 'dog',
        breed: 'labrador',
        speciesConfidence: 0.92,
        face: makeFace(),
        pose: makePose(),
        imageWidth: 640,
        imageHeight: 480,
      );
    }

    Dog makeMinimalDog() {
      return Dog(
        boundingBox: BoundingBox.ltrb(5.0, 10.0, 200.0, 180.0),
        score: 0.75,
        imageWidth: 1920,
        imageHeight: 1080,
      );
    }

    test('constructor stores all required fields', () {
      final dog = makeFullDog();
      expect(dog.boundingBox.left, 10.0);
      expect(dog.boundingBox.top, 20.0);
      expect(dog.boundingBox.right, 400.0);
      expect(dog.boundingBox.bottom, 350.0);
      expect(dog.score, 0.95);
      expect(dog.imageWidth, 640);
      expect(dog.imageHeight, 480);
    });

    test('constructor stores all optional fields', () {
      final dog = makeFullDog();
      expect(dog.species, 'dog');
      expect(dog.breed, 'labrador');
      expect(dog.speciesConfidence, 0.92);
      expect(dog.face, isNotNull);
      expect(dog.pose, isNotNull);
    });

    test('optional fields default to null', () {
      final dog = makeMinimalDog();
      expect(dog.species, isNull);
      expect(dog.breed, isNull);
      expect(dog.speciesConfidence, isNull);
      expect(dog.face, isNull);
      expect(dog.pose, isNull);
    });

    test('toMap produces correct keys for full dog', () {
      final map = makeFullDog().toMap();
      expect(map.containsKey('boundingBox'), true);
      expect(map.containsKey('score'), true);
      expect(map.containsKey('species'), true);
      expect(map.containsKey('breed'), true);
      expect(map.containsKey('speciesConfidence'), true);
      expect(map.containsKey('face'), true);
      expect(map.containsKey('pose'), true);
      expect(map.containsKey('imageWidth'), true);
      expect(map.containsKey('imageHeight'), true);
    });

    test('toMap serializes boundingBox correctly', () {
      final map = makeFullDog().toMap();
      final bbox = map['boundingBox'] as Map<String, dynamic>;
      expect(bbox['left'], 10.0);
      expect(bbox['top'], 20.0);
      expect(bbox['right'], 400.0);
      expect(bbox['bottom'], 350.0);
    });

    test('toMap serializes scalar fields correctly', () {
      final map = makeFullDog().toMap();
      expect(map['score'], 0.95);
      expect(map['species'], 'dog');
      expect(map['breed'], 'labrador');
      expect(map['speciesConfidence'], 0.92);
      expect(map['imageWidth'], 640);
      expect(map['imageHeight'], 480);
    });

    test('toMap serializes face when present', () {
      final map = makeFullDog().toMap();
      expect(map['face'], isNotNull);
      final faceMap = map['face'] as Map<String, dynamic>;
      expect(faceMap.containsKey('boundingBox'), true);
      expect(faceMap.containsKey('landmarks'), true);
      final landmarks = faceMap['landmarks'] as List;
      expect(landmarks.length, 2);
    });

    test('toMap serializes pose when present', () {
      final map = makeFullDog().toMap();
      expect(map['pose'], isNotNull);
      final poseMap = map['pose'] as Map<String, dynamic>;
      expect(poseMap.containsKey('landmarks'), true);
      final landmarks = poseMap['landmarks'] as List;
      expect(landmarks.length, 2);
    });

    test('toMap has null face and pose when absent', () {
      final map = makeMinimalDog().toMap();
      expect(map['face'], isNull);
      expect(map['pose'], isNull);
      expect(map['species'], isNull);
      expect(map['breed'], isNull);
      expect(map['speciesConfidence'], isNull);
    });

    test('fromMap reconstructs full dog correctly', () {
      final map = {
        'boundingBox': {
          'left': 10.0,
          'top': 20.0,
          'right': 400.0,
          'bottom': 350.0,
        },
        'score': 0.95,
        'species': 'dog',
        'breed': 'labrador',
        'speciesConfidence': 0.92,
        'face': {
          'boundingBox': {
            'left': 50.0,
            'top': 60.0,
            'right': 150.0,
            'bottom': 160.0,
          },
          'landmarks': [
            {'type': 'noseBridgeBottom', 'x': 100.0, 'y': 110.0},
          ],
        },
        'pose': {
          'landmarks': [
            {
              'type': 'neckBase',
              'x': 100.0,
              'y': 50.0,
              'confidence': 0.98,
            },
          ],
        },
        'imageWidth': 640,
        'imageHeight': 480,
      };
      final dog = Dog.fromMap(map);
      expect(dog.boundingBox.left, 10.0);
      expect(dog.boundingBox.top, 20.0);
      expect(dog.boundingBox.right, 400.0);
      expect(dog.boundingBox.bottom, 350.0);
      expect(dog.score, 0.95);
      expect(dog.species, 'dog');
      expect(dog.breed, 'labrador');
      expect(dog.speciesConfidence, 0.92);
      expect(dog.face, isNotNull);
      expect(dog.face!.landmarks.length, 1);
      expect(dog.face!.landmarks[0].type, DogLandmarkType.noseBridgeBottom);
      expect(dog.pose, isNotNull);
      expect(dog.pose!.landmarks.length, 1);
      expect(dog.pose!.landmarks[0].type, AnimalPoseLandmarkType.neckBase);
      expect(dog.imageWidth, 640);
      expect(dog.imageHeight, 480);
    });

    test('fromMap reconstructs minimal dog (nulls) correctly', () {
      final map = {
        'boundingBox': {
          'left': 5.0,
          'top': 10.0,
          'right': 200.0,
          'bottom': 180.0,
        },
        'score': 0.75,
        'species': null,
        'breed': null,
        'speciesConfidence': null,
        'face': null,
        'pose': null,
        'imageWidth': 1920,
        'imageHeight': 1080,
      };
      final dog = Dog.fromMap(map);
      expect(dog.score, 0.75);
      expect(dog.species, isNull);
      expect(dog.breed, isNull);
      expect(dog.speciesConfidence, isNull);
      expect(dog.face, isNull);
      expect(dog.pose, isNull);
      expect(dog.imageWidth, 1920);
      expect(dog.imageHeight, 1080);
    });

    test('fromMap handles integer values for doubles', () {
      final map = {
        'boundingBox': {'left': 0, 'top': 0, 'right': 100, 'bottom': 100},
        'score': 1,
        'species': null,
        'breed': null,
        'speciesConfidence': null,
        'face': null,
        'pose': null,
        'imageWidth': 640,
        'imageHeight': 480,
      };
      final dog = Dog.fromMap(map);
      expect(dog.boundingBox.left, 0.0);
      expect(dog.score, 1.0);
    });

    test('toMap/fromMap round-trip with full dog', () {
      final original = makeFullDog();
      final restored = Dog.fromMap(original.toMap());

      expect(restored.boundingBox.left, original.boundingBox.left);
      expect(restored.boundingBox.top, original.boundingBox.top);
      expect(restored.boundingBox.right, original.boundingBox.right);
      expect(restored.boundingBox.bottom, original.boundingBox.bottom);
      expect(restored.score, original.score);
      expect(restored.species, original.species);
      expect(restored.breed, original.breed);
      expect(restored.speciesConfidence, original.speciesConfidence);
      expect(restored.imageWidth, original.imageWidth);
      expect(restored.imageHeight, original.imageHeight);

      // Face round-trip
      expect(restored.face, isNotNull);
      expect(restored.face!.boundingBox.left, original.face!.boundingBox.left);
      expect(restored.face!.landmarks.length, original.face!.landmarks.length);
      expect(
          restored.face!.landmarks[0].type, original.face!.landmarks[0].type);
      expect(restored.face!.landmarks[0].x, original.face!.landmarks[0].x);
      expect(restored.face!.landmarks[0].y, original.face!.landmarks[0].y);

      // Pose round-trip
      expect(restored.pose, isNotNull);
      expect(restored.pose!.landmarks.length, original.pose!.landmarks.length);
      expect(
          restored.pose!.landmarks[0].type, original.pose!.landmarks[0].type);
      expect(restored.pose!.landmarks[0].x, original.pose!.landmarks[0].x);
      expect(restored.pose!.landmarks[0].y, original.pose!.landmarks[0].y);
      expect(restored.pose!.landmarks[0].confidence,
          original.pose!.landmarks[0].confidence);
    });

    test('toMap/fromMap round-trip with minimal dog', () {
      final original = makeMinimalDog();
      final restored = Dog.fromMap(original.toMap());

      expect(restored.boundingBox.left, original.boundingBox.left);
      expect(restored.boundingBox.top, original.boundingBox.top);
      expect(restored.boundingBox.right, original.boundingBox.right);
      expect(restored.boundingBox.bottom, original.boundingBox.bottom);
      expect(restored.score, original.score);
      expect(restored.species, isNull);
      expect(restored.breed, isNull);
      expect(restored.speciesConfidence, isNull);
      expect(restored.face, isNull);
      expect(restored.pose, isNull);
      expect(restored.imageWidth, original.imageWidth);
      expect(restored.imageHeight, original.imageHeight);
    });

    test('toMap/fromMap round-trip with face but no pose', () {
      final original = Dog(
        boundingBox: BoundingBox.ltrb(10.0, 20.0, 300.0, 250.0),
        score: 0.88,
        species: 'dog',
        breed: 'poodle',
        speciesConfidence: 0.80,
        face: makeFace(),
        imageWidth: 800,
        imageHeight: 600,
      );
      final restored = Dog.fromMap(original.toMap());
      expect(restored.face, isNotNull);
      expect(restored.pose, isNull);
      expect(restored.species, 'dog');
      expect(restored.breed, 'poodle');
    });

    test('toMap/fromMap round-trip with pose but no face', () {
      final original = Dog(
        boundingBox: BoundingBox.ltrb(10.0, 20.0, 300.0, 250.0),
        score: 0.88,
        pose: makePose(),
        imageWidth: 800,
        imageHeight: 600,
      );
      final restored = Dog.fromMap(original.toMap());
      expect(restored.face, isNull);
      expect(restored.pose, isNotNull);
      expect(restored.pose!.landmarks.length, 2);
    });

    test('toString does not crash', () {
      expect(() => makeFullDog().toString(), returnsNormally);
      expect(() => makeMinimalDog().toString(), returnsNormally);
    });

    test('toString contains Dog prefix', () {
      expect(makeFullDog().toString(), contains('Dog('));
      expect(makeMinimalDog().toString(), contains('Dog('));
    });

    test('toString contains score', () {
      final str = makeFullDog().toString();
      expect(str, contains('score=0.950'));
    });

    test('toString reflects species and breed', () {
      final str = makeFullDog().toString();
      expect(str, contains('species=dog'));
      expect(str, contains('breed=labrador'));
    });

    test('toString reflects null species and breed', () {
      final str = makeMinimalDog().toString();
      expect(str, contains('species=null'));
      expect(str, contains('breed=null'));
    });

    test('toString reflects face and pose presence', () {
      final fullStr = makeFullDog().toString();
      expect(fullStr, contains('face=true'));
      expect(fullStr, contains('pose=true'));

      final minStr = makeMinimalDog().toString();
      expect(minStr, contains('face=false'));
      expect(minStr, contains('pose=false'));
    });

    test('edge case: score of 0.0', () {
      final dog = Dog(
        boundingBox: BoundingBox.ltrb(0, 0, 100, 100),
        score: 0.0,
        imageWidth: 640,
        imageHeight: 480,
      );
      expect(dog.score, 0.0);
      final restored = Dog.fromMap(dog.toMap());
      expect(restored.score, 0.0);
    });

    test('edge case: score of 1.0', () {
      final dog = Dog(
        boundingBox: BoundingBox.ltrb(0, 0, 100, 100),
        score: 1.0,
        imageWidth: 640,
        imageHeight: 480,
      );
      expect(dog.score, 1.0);
      final restored = Dog.fromMap(dog.toMap());
      expect(restored.score, 1.0);
    });

    test('edge case: empty species and breed strings', () {
      final dog = Dog(
        boundingBox: BoundingBox.ltrb(0, 0, 100, 100),
        score: 0.5,
        species: '',
        breed: '',
        imageWidth: 640,
        imageHeight: 480,
      );
      expect(dog.species, '');
      expect(dog.breed, '');
      final restored = Dog.fromMap(dog.toMap());
      expect(restored.species, '');
      expect(restored.breed, '');
    });

    test('edge case: zero-size bounding box', () {
      final dog = Dog(
        boundingBox: BoundingBox.ltrb(50.0, 50.0, 50.0, 50.0),
        score: 0.5,
        imageWidth: 640,
        imageHeight: 480,
      );
      final restored = Dog.fromMap(dog.toMap());
      expect(restored.boundingBox.left, restored.boundingBox.right);
      expect(restored.boundingBox.top, restored.boundingBox.bottom);
    });

    test('edge case: very small speciesConfidence', () {
      final dog = Dog(
        boundingBox: BoundingBox.ltrb(0, 0, 100, 100),
        score: 0.5,
        speciesConfidence: 0.001,
        imageWidth: 640,
        imageHeight: 480,
      );
      final restored = Dog.fromMap(dog.toMap());
      expect(restored.speciesConfidence, closeTo(0.001, 0.0001));
    });

    test('edge case: large image dimensions', () {
      final dog = Dog(
        boundingBox: BoundingBox.ltrb(0, 0, 7680, 4320),
        score: 0.99,
        imageWidth: 7680,
        imageHeight: 4320,
      );
      final restored = Dog.fromMap(dog.toMap());
      expect(restored.imageWidth, 7680);
      expect(restored.imageHeight, 4320);
    });

    test('edge case: face with empty landmarks list', () {
      final dog = Dog(
        boundingBox: BoundingBox.ltrb(0, 0, 100, 100),
        score: 0.5,
        face: DogFace(
          boundingBox: BoundingBox.ltrb(10, 10, 90, 90),
          landmarks: [],
        ),
        imageWidth: 640,
        imageHeight: 480,
      );
      expect(dog.face, isNotNull);
      expect(dog.face!.landmarks, isEmpty);
      final restored = Dog.fromMap(dog.toMap());
      expect(restored.face, isNotNull);
      expect(restored.face!.landmarks, isEmpty);
    });
  });
}
