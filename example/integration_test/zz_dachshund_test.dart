// ignore_for_file: avoid_print
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:dog_detection/dog_detection.dart';

const _files = [
  'd1.jpg',
  'd2.webp',
  'd3.jpg',
  'd4.jpg',
  'd5.jpg',
  'd6.jpg',
  'd7.jpg',
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('3.1.0 species gate on real dachshund photos', (tester) async {
    final d = DogDetector(mode: DogDetectionMode.full);
    await d.initialize();
    addTearDown(d.dispose);

    int found = 0;
    final confs = <double>[];
    for (final f in _files) {
      final data =
          await rootBundle.load('integration_test/test_images/dachshund/$f');
      final mat = cv.imdecode(data.buffer.asUint8List(), cv.IMREAD_COLOR);
      final res = await d.detectFromMat(mat,
          imageWidth: mat.cols, imageHeight: mat.rows);
      if (res.isNotEmpty) found++;
      for (final r in res) {
        confs.add(r.speciesConfidence ?? 0);
        print('DACH $f ${mat.cols}x${mat.rows} -> species=${r.species} '
            'breed=${r.breed} conf=${r.speciesConfidence?.toStringAsFixed(4)} '
            'face=${r.face != null} landmarks=${r.face?.landmarks.length ?? 0}');
      }
      if (res.isEmpty) {
        print('DACH $f ${mat.cols}x${mat.rows} -> NO DOG DETECTED');
      }
      mat.dispose();
    }
    confs.sort();
    print('DACH SUMMARY found=$found/${_files.length} '
        'minConf=${confs.isEmpty ? "-" : confs.first.toStringAsFixed(4)} '
        'maxConf=${confs.isEmpty ? "-" : confs.last.toStringAsFixed(4)}');
  });
}
