// ignore_for_file: avoid_print

// Species gate, exercised on a frame holding a man, a cat and a dog.
//
// Before 3.1.0 the body detector's every hit was returned as a [Dog] with
// dog face landmarks run on it, whatever the species classifier said. This
// asserts the gate: only the dog survives.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:dog_detection/dog_detection.dart';

const _imagePath = 'integration_test/test_images/man_cat_dog.png';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('returns only the dog from a man + cat + dog frame',
      (tester) async {
    final data = await rootBundle.load(_imagePath);
    final mat = cv.imdecode(data.buffer.asUint8List(), cv.IMREAD_COLOR);
    addTearDown(mat.dispose);

    final detector = DogDetector(mode: DogDetectionMode.full);
    await detector.initialize();
    addTearDown(detector.dispose);

    final results = await detector.detectFromMat(
      mat,
      imageWidth: mat.cols,
      imageHeight: mat.rows,
    );

    print(
        'GATE image ${mat.cols}x${mat.rows}, dogs returned: ${results.length}');
    for (final r in results) {
      print('GATE   species=${r.species} breed=${r.breed} '
          'conf=${r.speciesConfidence?.toStringAsFixed(3)} '
          'score=${r.score.toStringAsFixed(3)} '
          'face=${r.face != null} landmarks=${r.face?.landmarks.length ?? 0}');
    }

    expect(results, isNotEmpty, reason: 'the dog should be found');
    expect(results.length, 1,
        reason: 'the man and the cat must be dropped by the species gate');

    final only = results.single;
    expect(only.species, 'dog');
    expect(only.face, isNotNull, reason: 'face stage should run on a real dog');
  });
}
