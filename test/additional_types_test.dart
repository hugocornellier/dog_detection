import 'package:flutter_test/flutter_test.dart';
import 'package:dog_detection/dog_detection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------------
  // DogLandmarkModel — ensemble.name gap
  // ---------------------------------------------------------------------------
  group('DogLandmarkModel — ensemble name', () {
    test('ensemble name is ensemble', () {
      expect(DogLandmarkModel.ensemble.name, 'ensemble');
    });
  });

  // ---------------------------------------------------------------------------
  // Point — z coordinate, is3D, toString, ==, hashCode, toMap/fromMap
  // ---------------------------------------------------------------------------
  group('Point extended', () {
    test('constructor accepts optional z', () {
      final p = Point(1.0, 2.0, 3.0);
      expect(p.x, 1.0);
      expect(p.y, 2.0);
      expect(p.z, 3.0);
    });

    test('z defaults to null when not provided', () {
      final p = Point(4.0, 5.0);
      expect(p.z, isNull);
    });

    test('is3D returns true when z is provided', () {
      expect(Point(1.0, 2.0, 0.0).is3D, true);
    });

    test('is3D returns false when z is null', () {
      expect(Point(1.0, 2.0).is3D, false);
    });

    test('toString with z includes all three coords', () {
      final p = Point(1.5, 2.5, 3.5);
      expect(p.toString(), 'Point(1.5, 2.5, 3.5)');
    });

    test('toString without z shows two coords', () {
      final p = Point(1.5, 2.5);
      expect(p.toString(), 'Point(1.5, 2.5)');
    });

    test('equality holds for identical 2D points', () {
      expect(Point(10.0, 20.0), equals(Point(10.0, 20.0)));
    });

    test('equality holds for identical 3D points', () {
      expect(Point(10.0, 20.0, 30.0), equals(Point(10.0, 20.0, 30.0)));
    });

    test('equality fails when z differs', () {
      expect(Point(10.0, 20.0, 1.0), isNot(equals(Point(10.0, 20.0, 2.0))));
    });

    test('equality fails when 2D vs 3D', () {
      expect(Point(10.0, 20.0), isNot(equals(Point(10.0, 20.0, 0.0))));
    });

    test('hashCode is consistent for equal 2D points', () {
      expect(Point(5.0, 6.0).hashCode, Point(5.0, 6.0).hashCode);
    });

    test('hashCode is consistent for equal 3D points', () {
      expect(Point(5.0, 6.0, 7.0).hashCode, Point(5.0, 6.0, 7.0).hashCode);
    });

    test('toMap without z has no z key', () {
      final map = Point(3.0, 4.0).toMap();
      expect(map['x'], 3.0);
      expect(map['y'], 4.0);
      expect(map.containsKey('z'), false);
    });

    test('toMap with z includes z key', () {
      final map = Point(3.0, 4.0, 5.0).toMap();
      expect(map['x'], 3.0);
      expect(map['y'], 4.0);
      expect(map['z'], 5.0);
    });

    test('fromMap round-trip without z', () {
      final original = Point(7.0, 8.0);
      final restored = Point.fromMap(original.toMap());
      expect(restored.x, 7.0);
      expect(restored.y, 8.0);
      expect(restored.z, isNull);
    });

    test('fromMap round-trip with z', () {
      final original = Point(7.0, 8.0, 9.0);
      final restored = Point.fromMap(original.toMap());
      expect(restored.x, 7.0);
      expect(restored.y, 8.0);
      expect(restored.z, 9.0);
    });

    test('fromMap handles integer coordinates', () {
      final restored = Point.fromMap({'x': 10, 'y': 20});
      expect(restored.x, 10.0);
      expect(restored.y, 20.0);
      expect(restored.z, isNull);
    });

    test('fromMap handles integer z', () {
      final restored = Point.fromMap({'x': 10, 'y': 20, 'z': 30});
      expect(restored.z, 30.0);
    });
  });

  // ---------------------------------------------------------------------------
  // BoundingBox — width, height, center, corners
  // ---------------------------------------------------------------------------
  group('BoundingBox computed properties', () {
    test('width is right minus left', () {
      final bbox = BoundingBox.ltrb(10.0, 20.0, 110.0, 220.0);
      expect(bbox.width, closeTo(100.0, 0.0001));
    });

    test('height is bottom minus top', () {
      final bbox = BoundingBox.ltrb(10.0, 20.0, 110.0, 220.0);
      expect(bbox.height, closeTo(200.0, 0.0001));
    });

    test('width is zero for zero-width box', () {
      final bbox = BoundingBox.ltrb(50.0, 50.0, 50.0, 100.0);
      expect(bbox.width, 0.0);
    });

    test('height is zero for zero-height box', () {
      final bbox = BoundingBox.ltrb(50.0, 50.0, 100.0, 50.0);
      expect(bbox.height, 0.0);
    });

    test('center is midpoint of ltrb box', () {
      final bbox = BoundingBox.ltrb(0.0, 0.0, 100.0, 200.0);
      final c = bbox.center;
      expect(c.x, closeTo(50.0, 0.0001));
      expect(c.y, closeTo(100.0, 0.0001));
    });

    test('center with non-zero origin', () {
      final bbox = BoundingBox.ltrb(40.0, 60.0, 140.0, 160.0);
      final c = bbox.center;
      expect(c.x, closeTo(90.0, 0.0001));
      expect(c.y, closeTo(110.0, 0.0001));
    });

    test('corners returns 4 points', () {
      final bbox = BoundingBox.ltrb(10.0, 20.0, 110.0, 120.0);
      expect(bbox.corners.length, 4);
    });

    test('corners order is topLeft, topRight, bottomRight, bottomLeft', () {
      final bbox = BoundingBox.ltrb(10.0, 20.0, 110.0, 120.0);
      final corners = bbox.corners;
      expect(corners[0].x, 10.0);
      expect(corners[0].y, 20.0);
      expect(corners[1].x, 110.0);
      expect(corners[1].y, 20.0);
      expect(corners[2].x, 110.0);
      expect(corners[2].y, 120.0);
      expect(corners[3].x, 10.0);
      expect(corners[3].y, 120.0);
    });

    test('corner points round-trip consistent with ltrb accessors', () {
      final bbox = BoundingBox.ltrb(5.0, 15.0, 55.0, 65.0);
      expect(bbox.topLeft.x, bbox.left);
      expect(bbox.topLeft.y, bbox.top);
      expect(bbox.bottomRight.x, bbox.right);
      expect(bbox.bottomRight.y, bbox.bottom);
    });
  });

  // ---------------------------------------------------------------------------
  // DogLandmark — toString
  // ---------------------------------------------------------------------------
  group('DogLandmark toString', () {
    // DogLandmark does not override toString, so we just ensure it doesn't crash
    // and produces a non-empty string (default Object.toString).
    test('toString does not crash', () {
      final lm = DogLandmark(
        type: DogLandmarkType.noseBridgeTop,
        x: 50.0,
        y: 75.0,
      );
      expect(() => lm.toString(), returnsNormally);
      expect(lm.toString(), isNotEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // AnimalPoseLandmarkType enum — all 24 values and indices
  // ---------------------------------------------------------------------------
  group('AnimalPoseLandmarkType enum', () {
    test('has exactly 24 values', () {
      expect(AnimalPoseLandmarkType.values.length, 24);
    });

    test('spine and neck indices', () {
      expect(AnimalPoseLandmarkType.neckBase.index, 0);
      expect(AnimalPoseLandmarkType.neckEnd.index, 1);
      expect(AnimalPoseLandmarkType.throatBase.index, 2);
      expect(AnimalPoseLandmarkType.throatEnd.index, 3);
      expect(AnimalPoseLandmarkType.backBase.index, 4);
      expect(AnimalPoseLandmarkType.backEnd.index, 5);
      expect(AnimalPoseLandmarkType.backMiddle.index, 6);
      expect(AnimalPoseLandmarkType.tailBase.index, 7);
      expect(AnimalPoseLandmarkType.tailEnd.index, 8);
    });

    test('front leg indices', () {
      expect(AnimalPoseLandmarkType.frontLeftThigh.index, 9);
      expect(AnimalPoseLandmarkType.frontLeftKnee.index, 10);
      expect(AnimalPoseLandmarkType.frontLeftPaw.index, 11);
      expect(AnimalPoseLandmarkType.frontRightThigh.index, 12);
      expect(AnimalPoseLandmarkType.frontRightKnee.index, 13);
      expect(AnimalPoseLandmarkType.frontRightPaw.index, 14);
    });

    test('back leg indices', () {
      expect(AnimalPoseLandmarkType.backLeftPaw.index, 15);
      expect(AnimalPoseLandmarkType.backLeftThigh.index, 16);
      expect(AnimalPoseLandmarkType.backRightThigh.index, 17);
      expect(AnimalPoseLandmarkType.backLeftKnee.index, 18);
      expect(AnimalPoseLandmarkType.backRightKnee.index, 19);
      expect(AnimalPoseLandmarkType.backRightPaw.index, 20);
    });

    test('body middle indices', () {
      expect(AnimalPoseLandmarkType.bellyBottom.index, 21);
      expect(AnimalPoseLandmarkType.bodyMiddleRight.index, 22);
      expect(AnimalPoseLandmarkType.bodyMiddleLeft.index, 23);
    });

    test('name property works for selected values', () {
      expect(AnimalPoseLandmarkType.neckBase.name, 'neckBase');
      expect(AnimalPoseLandmarkType.tailEnd.name, 'tailEnd');
      expect(AnimalPoseLandmarkType.frontLeftPaw.name, 'frontLeftPaw');
      expect(AnimalPoseLandmarkType.backRightPaw.name, 'backRightPaw');
      expect(AnimalPoseLandmarkType.bellyBottom.name, 'bellyBottom');
      expect(AnimalPoseLandmarkType.bodyMiddleLeft.name, 'bodyMiddleLeft');
    });
  });

  // ---------------------------------------------------------------------------
  // AnimalPoseLandmark — toMap / fromMap
  // ---------------------------------------------------------------------------
  group('AnimalPoseLandmark', () {
    test('constructor stores all fields', () {
      final lm = AnimalPoseLandmark(
        type: AnimalPoseLandmarkType.tailEnd,
        x: 120.0,
        y: 200.0,
        confidence: 0.91,
      );
      expect(lm.type, AnimalPoseLandmarkType.tailEnd);
      expect(lm.x, 120.0);
      expect(lm.y, 200.0);
      expect(lm.confidence, 0.91);
    });

    test('toMap produces correct keys and values', () {
      final lm = AnimalPoseLandmark(
        type: AnimalPoseLandmarkType.neckBase,
        x: 50.0,
        y: 75.0,
        confidence: 0.88,
      );
      final map = lm.toMap();
      expect(map['type'], 'neckBase');
      expect(map['x'], 50.0);
      expect(map['y'], 75.0);
      expect(map['confidence'], 0.88);
    });

    test('fromMap reconstructs correctly', () {
      final map = {
        'type': 'frontLeftPaw',
        'x': 30.0,
        'y': 40.0,
        'confidence': 0.77,
      };
      final lm = AnimalPoseLandmark.fromMap(map);
      expect(lm.type, AnimalPoseLandmarkType.frontLeftPaw);
      expect(lm.x, 30.0);
      expect(lm.y, 40.0);
      expect(lm.confidence, 0.77);
    });

    test('fromMap handles integer coordinates', () {
      final map = {
        'type': 'tailBase',
        'x': 100,
        'y': 200,
        'confidence': 1,
      };
      final lm = AnimalPoseLandmark.fromMap(map);
      expect(lm.x, 100.0);
      expect(lm.y, 200.0);
      expect(lm.confidence, 1.0);
    });

    test('toMap/fromMap round-trip', () {
      final original = AnimalPoseLandmark(
        type: AnimalPoseLandmarkType.backRightKnee,
        x: 77.7,
        y: 88.8,
        confidence: 0.55,
      );
      final restored = AnimalPoseLandmark.fromMap(original.toMap());
      expect(restored.type, original.type);
      expect(restored.x, original.x);
      expect(restored.y, original.y);
      expect(restored.confidence, original.confidence);
    });

    test('round-trip all landmark types', () {
      for (final type in AnimalPoseLandmarkType.values) {
        final original = AnimalPoseLandmark(
          type: type,
          x: 10.0,
          y: 20.0,
          confidence: 0.5,
        );
        final restored = AnimalPoseLandmark.fromMap(original.toMap());
        expect(restored.type, type, reason: 'Round-trip failed for type $type');
      }
    });
  });

  // ---------------------------------------------------------------------------
  // AnimalPose — getLandmark, hasLandmarks, toMap/fromMap
  // ---------------------------------------------------------------------------
  group('AnimalPose', () {
    AnimalPoseLandmark makeLm(AnimalPoseLandmarkType type,
        {double x = 0, double y = 0, double confidence = 0.9}) {
      return AnimalPoseLandmark(type: type, x: x, y: y, confidence: confidence);
    }

    test('constructor stores landmarks', () {
      final pose = AnimalPose(landmarks: [
        makeLm(AnimalPoseLandmarkType.neckBase, x: 10.0, y: 20.0),
      ]);
      expect(pose.landmarks.length, 1);
    });

    test('hasLandmarks returns true when non-empty', () {
      final pose = AnimalPose(landmarks: [
        makeLm(AnimalPoseLandmarkType.tailEnd),
      ]);
      expect(pose.hasLandmarks, true);
    });

    test('hasLandmarks returns false when empty', () {
      final pose = AnimalPose(landmarks: []);
      expect(pose.hasLandmarks, false);
    });

    test('getLandmark returns correct landmark by type', () {
      final pose = AnimalPose(landmarks: [
        makeLm(AnimalPoseLandmarkType.tailBase, x: 55.0, y: 66.0),
        makeLm(AnimalPoseLandmarkType.neckBase, x: 11.0, y: 22.0),
      ]);
      final lm = pose.getLandmark(AnimalPoseLandmarkType.tailBase);
      expect(lm, isNotNull);
      expect(lm!.x, 55.0);
      expect(lm.y, 66.0);
    });

    test('getLandmark returns null for missing type', () {
      final pose = AnimalPose(landmarks: [
        makeLm(AnimalPoseLandmarkType.neckBase),
      ]);
      expect(pose.getLandmark(AnimalPoseLandmarkType.tailEnd), isNull);
    });

    test('getLandmark returns null for empty landmarks', () {
      final pose = AnimalPose(landmarks: []);
      expect(pose.getLandmark(AnimalPoseLandmarkType.neckBase), isNull);
    });

    test('toMap produces landmarks key', () {
      final pose = AnimalPose(landmarks: [
        makeLm(AnimalPoseLandmarkType.neckBase, x: 1.0, y: 2.0),
      ]);
      final map = pose.toMap();
      expect(map.containsKey('landmarks'), true);
      final list = map['landmarks'] as List;
      expect(list.length, 1);
    });

    test('fromMap reconstructs pose', () {
      final map = {
        'landmarks': [
          {'type': 'tailEnd', 'x': 99.0, 'y': 88.0, 'confidence': 0.75},
        ],
      };
      final pose = AnimalPose.fromMap(map);
      expect(pose.landmarks.length, 1);
      expect(pose.landmarks[0].type, AnimalPoseLandmarkType.tailEnd);
      expect(pose.landmarks[0].x, 99.0);
    });

    test('fromMap with empty list', () {
      final pose = AnimalPose.fromMap({'landmarks': []});
      expect(pose.landmarks, isEmpty);
    });

    test('toMap/fromMap round-trip', () {
      final original = AnimalPose(landmarks: [
        makeLm(AnimalPoseLandmarkType.frontLeftPaw,
            x: 33.0, y: 44.0, confidence: 0.82),
        makeLm(AnimalPoseLandmarkType.backRightPaw,
            x: 77.0, y: 88.0, confidence: 0.65),
      ]);
      final restored = AnimalPose.fromMap(original.toMap());
      expect(restored.landmarks.length, 2);
      expect(restored.landmarks[0].type, AnimalPoseLandmarkType.frontLeftPaw);
      expect(restored.landmarks[0].x, 33.0);
      expect(restored.landmarks[0].y, 44.0);
      expect(restored.landmarks[0].confidence, closeTo(0.82, 0.0001));
      expect(restored.landmarks[1].type, AnimalPoseLandmarkType.backRightPaw);
    });
  });

  // ---------------------------------------------------------------------------
  // animalPoseConnections constant
  // ---------------------------------------------------------------------------
  group('animalPoseConnections constant', () {
    test('is non-empty', () {
      expect(animalPoseConnections, isNotEmpty);
    });

    test('each connection has exactly 2 elements', () {
      for (final c in animalPoseConnections) {
        expect(c.length, 2, reason: 'Connection does not have 2 elements: $c');
      }
    });

    test('total connection count is 13', () {
      // 1 throat + 4 spine + 4 front legs + 4 back legs = 13
      expect(animalPoseConnections.length, 13);
    });

    test('all elements are valid AnimalPoseLandmarkType values', () {
      final allTypes = AnimalPoseLandmarkType.values.toSet();
      for (final c in animalPoseConnections) {
        expect(allTypes.contains(c[0]), true, reason: 'Invalid start: ${c[0]}');
        expect(allTypes.contains(c[1]), true, reason: 'Invalid end: ${c[1]}');
      }
    });

    test('tail connection exists', () {
      final hasTail = animalPoseConnections.any((c) =>
          c[0] == AnimalPoseLandmarkType.tailBase &&
          c[1] == AnimalPoseLandmarkType.tailEnd);
      expect(hasTail, true);
    });

    test('front left leg connections exist', () {
      final thighKnee = animalPoseConnections.any((c) =>
          c[0] == AnimalPoseLandmarkType.frontLeftThigh &&
          c[1] == AnimalPoseLandmarkType.frontLeftKnee);
      final kneePaw = animalPoseConnections.any((c) =>
          c[0] == AnimalPoseLandmarkType.frontLeftKnee &&
          c[1] == AnimalPoseLandmarkType.frontLeftPaw);
      expect(thighKnee, true);
      expect(kneePaw, true);
    });

    test('back right leg connections exist', () {
      final thighKnee = animalPoseConnections.any((c) =>
          c[0] == AnimalPoseLandmarkType.backRightThigh &&
          c[1] == AnimalPoseLandmarkType.backRightKnee);
      final kneePaw = animalPoseConnections.any((c) =>
          c[0] == AnimalPoseLandmarkType.backRightKnee &&
          c[1] == AnimalPoseLandmarkType.backRightPaw);
      expect(thighKnee, true);
      expect(kneePaw, true);
    });
  });

  // ---------------------------------------------------------------------------
  // CropMetadata
  // ---------------------------------------------------------------------------
  group('CropMetadata', () {
    test('constructor stores all fields', () {
      const meta =
          CropMetadata(cx1: 10.0, cy1: 20.0, cropW: 300.0, cropH: 250.0);
      expect(meta.cx1, 10.0);
      expect(meta.cy1, 20.0);
      expect(meta.cropW, 300.0);
      expect(meta.cropH, 250.0);
    });

    test('zero values are stored', () {
      const meta = CropMetadata(cx1: 0.0, cy1: 0.0, cropW: 0.0, cropH: 0.0);
      expect(meta.cx1, 0.0);
      expect(meta.cy1, 0.0);
      expect(meta.cropW, 0.0);
      expect(meta.cropH, 0.0);
    });

    test('negative origin values are stored', () {
      const meta =
          CropMetadata(cx1: -5.0, cy1: -10.0, cropW: 100.0, cropH: 100.0);
      expect(meta.cx1, -5.0);
      expect(meta.cy1, -10.0);
    });

    test('large values are stored', () {
      const meta =
          CropMetadata(cx1: 0.0, cy1: 0.0, cropW: 7680.0, cropH: 4320.0);
      expect(meta.cropW, 7680.0);
      expect(meta.cropH, 4320.0);
    });
  });

  // ---------------------------------------------------------------------------
  // Animal — toMap, fromMap, toString
  // ---------------------------------------------------------------------------
  group('Animal', () {
    AnimalPose makePose() {
      return AnimalPose(landmarks: [
        AnimalPoseLandmark(
          type: AnimalPoseLandmarkType.neckBase,
          x: 100.0,
          y: 50.0,
          confidence: 0.95,
        ),
      ]);
    }

    Animal makeFullAnimal() {
      return Animal(
        boundingBox: BoundingBox.ltrb(10.0, 20.0, 400.0, 350.0),
        score: 0.93,
        species: 'dog',
        breed: 'beagle',
        speciesConfidence: 0.87,
        pose: makePose(),
        imageWidth: 640,
        imageHeight: 480,
      );
    }

    Animal makeMinimalAnimal() {
      return Animal(
        boundingBox: BoundingBox.ltrb(5.0, 10.0, 200.0, 180.0),
        score: 0.70,
        imageWidth: 1280,
        imageHeight: 720,
      );
    }

    test('constructor stores required fields', () {
      final animal = makeFullAnimal();
      expect(animal.boundingBox.left, 10.0);
      expect(animal.boundingBox.top, 20.0);
      expect(animal.boundingBox.right, 400.0);
      expect(animal.boundingBox.bottom, 350.0);
      expect(animal.score, 0.93);
      expect(animal.imageWidth, 640);
      expect(animal.imageHeight, 480);
    });

    test('constructor stores optional fields', () {
      final animal = makeFullAnimal();
      expect(animal.species, 'dog');
      expect(animal.breed, 'beagle');
      expect(animal.speciesConfidence, 0.87);
      expect(animal.pose, isNotNull);
    });

    test('optional fields default to null', () {
      final animal = makeMinimalAnimal();
      expect(animal.species, isNull);
      expect(animal.breed, isNull);
      expect(animal.speciesConfidence, isNull);
      expect(animal.pose, isNull);
    });

    test('toMap produces all expected keys', () {
      final map = makeFullAnimal().toMap();
      expect(map.containsKey('boundingBox'), true);
      expect(map.containsKey('score'), true);
      expect(map.containsKey('species'), true);
      expect(map.containsKey('breed'), true);
      expect(map.containsKey('speciesConfidence'), true);
      expect(map.containsKey('pose'), true);
      expect(map.containsKey('imageWidth'), true);
      expect(map.containsKey('imageHeight'), true);
    });

    test('toMap serializes boundingBox correctly', () {
      final map = makeFullAnimal().toMap();
      final bbox = map['boundingBox'] as Map<String, dynamic>;
      expect(bbox['left'], 10.0);
      expect(bbox['top'], 20.0);
      expect(bbox['right'], 400.0);
      expect(bbox['bottom'], 350.0);
    });

    test('toMap serializes scalar fields correctly', () {
      final map = makeFullAnimal().toMap();
      expect(map['score'], 0.93);
      expect(map['species'], 'dog');
      expect(map['breed'], 'beagle');
      expect(map['speciesConfidence'], 0.87);
      expect(map['imageWidth'], 640);
      expect(map['imageHeight'], 480);
    });

    test('toMap has null pose when absent', () {
      final map = makeMinimalAnimal().toMap();
      expect(map['pose'], isNull);
      expect(map['species'], isNull);
      expect(map['breed'], isNull);
      expect(map['speciesConfidence'], isNull);
    });

    test('toMap serializes pose when present', () {
      final map = makeFullAnimal().toMap();
      expect(map['pose'], isNotNull);
      final poseMap = map['pose'] as Map<String, dynamic>;
      expect(poseMap.containsKey('landmarks'), true);
      final landmarks = poseMap['landmarks'] as List;
      expect(landmarks.length, 1);
    });

    test('fromMap reconstructs full animal', () {
      final map = {
        'boundingBox': {
          'left': 10.0,
          'top': 20.0,
          'right': 400.0,
          'bottom': 350.0,
        },
        'score': 0.93,
        'species': 'dog',
        'breed': 'beagle',
        'speciesConfidence': 0.87,
        'pose': {
          'landmarks': [
            {'type': 'neckBase', 'x': 100.0, 'y': 50.0, 'confidence': 0.95},
          ],
        },
        'imageWidth': 640,
        'imageHeight': 480,
      };
      final animal = Animal.fromMap(map);
      expect(animal.score, 0.93);
      expect(animal.species, 'dog');
      expect(animal.breed, 'beagle');
      expect(animal.speciesConfidence, 0.87);
      expect(animal.pose, isNotNull);
      expect(animal.pose!.landmarks.length, 1);
      expect(animal.pose!.landmarks[0].type, AnimalPoseLandmarkType.neckBase);
      expect(animal.imageWidth, 640);
      expect(animal.imageHeight, 480);
    });

    test('fromMap reconstructs minimal animal (nulls)', () {
      final map = {
        'boundingBox': {
          'left': 5.0,
          'top': 10.0,
          'right': 200.0,
          'bottom': 180.0,
        },
        'score': 0.70,
        'species': null,
        'breed': null,
        'speciesConfidence': null,
        'pose': null,
        'imageWidth': 1280,
        'imageHeight': 720,
      };
      final animal = Animal.fromMap(map);
      expect(animal.score, 0.70);
      expect(animal.species, isNull);
      expect(animal.breed, isNull);
      expect(animal.speciesConfidence, isNull);
      expect(animal.pose, isNull);
      expect(animal.imageWidth, 1280);
      expect(animal.imageHeight, 720);
    });

    test('fromMap handles integer values for doubles', () {
      final map = {
        'boundingBox': {'left': 0, 'top': 0, 'right': 100, 'bottom': 100},
        'score': 1,
        'species': null,
        'breed': null,
        'speciesConfidence': null,
        'pose': null,
        'imageWidth': 640,
        'imageHeight': 480,
      };
      final animal = Animal.fromMap(map);
      expect(animal.boundingBox.left, 0.0);
      expect(animal.score, 1.0);
    });

    test('toMap/fromMap round-trip with full animal', () {
      final original = makeFullAnimal();
      final restored = Animal.fromMap(original.toMap());

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
      expect(restored.pose, isNotNull);
      expect(restored.pose!.landmarks.length, original.pose!.landmarks.length);
      expect(
          restored.pose!.landmarks[0].type, original.pose!.landmarks[0].type);
    });

    test('toMap/fromMap round-trip with minimal animal', () {
      final original = makeMinimalAnimal();
      final restored = Animal.fromMap(original.toMap());

      expect(restored.score, original.score);
      expect(restored.species, isNull);
      expect(restored.breed, isNull);
      expect(restored.pose, isNull);
      expect(restored.imageWidth, original.imageWidth);
      expect(restored.imageHeight, original.imageHeight);
    });

    test('toString does not crash', () {
      expect(() => makeFullAnimal().toString(), returnsNormally);
      expect(() => makeMinimalAnimal().toString(), returnsNormally);
    });

    test('toString contains Animal prefix', () {
      expect(makeFullAnimal().toString(), contains('Animal('));
      expect(makeMinimalAnimal().toString(), contains('Animal('));
    });

    test('toString contains score', () {
      final str = makeFullAnimal().toString();
      expect(str, contains('score=0.930'));
    });

    test('toString reflects species and breed', () {
      final str = makeFullAnimal().toString();
      expect(str, contains('species=dog'));
      expect(str, contains('breed=beagle'));
    });

    test('toString reflects null species and breed', () {
      final str = makeMinimalAnimal().toString();
      expect(str, contains('species=null'));
      expect(str, contains('breed=null'));
    });

    test('toString reflects pose presence', () {
      expect(makeFullAnimal().toString(), contains('pose=true'));
      expect(makeMinimalAnimal().toString(), contains('pose=false'));
    });

    test('edge case: score of 0.0', () {
      final animal = Animal(
        boundingBox: BoundingBox.ltrb(0, 0, 100, 100),
        score: 0.0,
        imageWidth: 640,
        imageHeight: 480,
      );
      final restored = Animal.fromMap(animal.toMap());
      expect(restored.score, 0.0);
    });

    test('edge case: speciesConfidence of 0.0', () {
      final animal = Animal(
        boundingBox: BoundingBox.ltrb(0, 0, 100, 100),
        score: 0.5,
        speciesConfidence: 0.0,
        imageWidth: 640,
        imageHeight: 480,
      );
      final restored = Animal.fromMap(animal.toMap());
      expect(restored.speciesConfidence, 0.0);
    });
  });
}
