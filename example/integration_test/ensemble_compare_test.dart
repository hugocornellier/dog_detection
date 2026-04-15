import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dog_detection/dog_detection.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ensemble detection on dachshund - output for comparison',
      (tester) async {
    final detector = DogDetector(
      mode: DogDetectionMode.full,
      landmarkModel: DogLandmarkModel.ensemble,
    );

    await detector.initialize(
      onDownloadProgress: (model, received, total) {
        final mb = (received / 1024 / 1024).toStringAsFixed(1);
        final totalMb =
            total > 0 ? (total / 1024 / 1024).toStringAsFixed(1) : '?';
        // ignore: avoid_print
        print('Downloading $model: $mb / $totalMb MB');
      },
    );

    final ByteData data = await rootBundle
        .load('packages/dog_detection/assets/samples/dachshund_test.jpg');
    final bytes = data.buffer.asUint8List();

    final List<Dog> results = await detector.detect(bytes);

    expect(results, isNotEmpty, reason: 'No dog detected');

    final dog = results.first;

    // Print bbox
    // ignore: avoid_print
    print('=== FLUTTER ENSEMBLE OUTPUT ===');
    // ignore: avoid_print
    print('Bbox: [${dog.boundingBox.left.toStringAsFixed(2)}, '
        '${dog.boundingBox.top.toStringAsFixed(2)}, '
        '${dog.boundingBox.right.toStringAsFixed(2)}, '
        '${dog.boundingBox.bottom.toStringAsFixed(2)}]');
    // ignore: avoid_print
    print('Image: ${dog.imageWidth}x${dog.imageHeight}');
    // ignore: avoid_print
    print('Landmarks: ${dog.face?.landmarks.length}');

    // Print all 46 landmarks
    for (final lm in dog.face?.landmarks ?? []) {
      // ignore: avoid_print
      print(
          'LM ${lm.type.index.toString().padLeft(2)}: x=${lm.x.toStringAsFixed(2).padLeft(7)}, y=${lm.y.toStringAsFixed(2).padLeft(7)}  (${'${lm.type}'.split('.').last})');
    }

    expect(dog.face?.landmarks.length, 46);

    await detector.dispose();
  });
}
