import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dog_detection/dog_detection.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('should detect dachshund face and landmarks', (tester) async {
    final detector = DogDetector(
      mode: DogDetectionMode.full,
      landmarkModel: DogLandmarkModel.full,
    );
    await detector.initialize();

    final ByteData data = await rootBundle
        .load('packages/dog_detection/assets/samples/dachshund_test.jpg');
    final Uint8List bytes = data.buffer.asUint8List();

    final List<Dog> results = await detector.detect(bytes);

    // Must detect at least one dog
    expect(results, isNotEmpty, reason: 'No dog detected in dachshund image');

    final dog = results.first;
    debugPrint('Bounding box: ${dog.boundingBox.left}, ${dog.boundingBox.top}, '
        '${dog.boundingBox.right}, ${dog.boundingBox.bottom}');
    debugPrint('Score: ${dog.score}');
    debugPrint('Face landmarks: ${dog.face?.landmarks.length}');

    // Should have valid bounding box
    expect(dog.boundingBox.right, greaterThan(dog.boundingBox.left));
    expect(dog.boundingBox.bottom, greaterThan(dog.boundingBox.top));

    // Should have 46 face landmarks
    expect(dog.face, isNotNull);
    expect(dog.face!.hasLandmarks, true);
    expect(dog.face!.landmarks.length, 46);

    // Print first few landmarks for visual verification
    for (int i = 0; i < 5; i++) {
      final lm = dog.face!.landmarks[i];
      debugPrint(
          '  ${lm.type.name}: (${lm.x.toStringAsFixed(1)}, ${lm.y.toStringAsFixed(1)})');
    }

    await detector.dispose();
  });
}
