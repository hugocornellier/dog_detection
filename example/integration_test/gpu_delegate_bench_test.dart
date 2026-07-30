import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_litert/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// On-device benchmark of the landmark model across delegates.
///
/// Everything measured so far has been macOS on an M4 Max, which is the platform
/// that matters least here: `InterpreterFactory` auto-mode selects XNNPACK on
/// macOS and the GPU delegate only on iOS. This runs the same comparison on a real
/// iPhone, which is the platform that actually takes the GPU path.
///
/// Three variants of the same weights, differing only in graph shape:
///
///   landmarks_dynamic_v4  what ships today. Keras leaves the batch dimension
///                         dynamic, so each TRANSPOSE_CONV computes its output
///                         shape at run time. On macOS this fails GPU interpreter
///                         creation outright.
///   landmarks_static_v4   batch pinned to 1, so shapes are static, but the deconv
///                         still carries a fused ReLU and therefore declares
///                         TRANSPOSE_CONV version 4. On macOS the stock delegate
///                         caps that op at version 3, so it refused the deconv head
///                         and ran it on CPU: 30.20 ms.
///   landmarks_static_v3   same, with the ReLU moved into a separate RELU op, which
///                         drops the opcode to version 3. On macOS the stock
///                         delegate accepts the whole graph: 5.11 ms.
///
/// The question this answers, which cannot be inferred from macOS: iOS resolves
/// Metal from `tfliteBinding` rather than the separate macOS dylib, so it is a
/// different binary and may already accept version 4. If static_v4 performs like
/// static_v3 here, iOS needs no patch at all.
///
/// Latency alone is not enough. A delegate that attaches, delegates zero ops and
/// silently runs on CPU looks like a slow success, so each run is also compared
/// against a CPU reference. Deviation of exactly 0.0 means the delegate did
/// nothing; a small deviation means it engaged; a large one means it engaged and
/// computed the wrong answer.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const int inputSize = 384;
  const int numOutputs = 92;
  const int warmup = 5;
  const int runs = 30;

  const variants = <String, String>{
    'dynamic_v4 (ships today)': 'assets/gpubench/landmarks_dynamic_v4.tflite',
    'static_v4 (fused ReLU)': 'assets/gpubench/landmarks_static_v4.tflite',
    'static_v3 (ReLU unfused)': 'assets/gpubench/landmarks_static_v3.tflite',
  };

  /// Deterministic pseudo-random input, so every variant and delegate sees exactly
  /// the same bytes and deviations are attributable to the delegate alone.
  Float32List makeInput() {
    final rng = math.Random(12345);
    final buf = Float32List(inputSize * inputSize * 3);
    for (var i = 0; i < buf.length; i++) {
      buf[i] = rng.nextDouble();
    }
    return buf;
  }

  /// Returns (medianMs, output) or throws. [config] null means no delegate at all.
  Future<(double, Float32List)> measure(
    Uint8List modelBytes,
    PerformanceConfig? config,
    Float32List input,
  ) async {
    final (options, delegate) = config == null
        ? (InterpreterOptions()..threads = 4, null)
        : InterpreterFactory.create(config);
    final interpreter = Interpreter.fromBuffer(modelBytes, options: options);
    try {
      interpreter.resizeInputTensor(0, [1, inputSize, inputSize, 3]);
      interpreter.allocateTensors();

      final output = Float32List(numOutputs);
      // Pass the ByteBuffer itself, matching animal_detection's convention;
      // handing over a ByteData is rejected by the binding.
      final outputs = {0: output.buffer};
      void invoke() => interpreter.runForMultipleInputs([input.buffer], outputs);

      for (var i = 0; i < warmup; i++) {
        invoke();
      }
      final samples = <double>[];
      for (var i = 0; i < runs; i++) {
        final sw = Stopwatch()..start();
        invoke();
        sw.stop();
        samples.add(sw.elapsedMicroseconds / 1000.0);
      }
      samples.sort();
      return (samples[samples.length ~/ 2], Float32List.fromList(output));
    } finally {
      interpreter.close();
      delegate?.delete();
    }
  }

  testWidgets('landmark model across delegates, on device', (tester) async {
    final input = makeInput();
    final lines = <String>[];
    lines.add('');
    lines.add('=== GPU DELEGATE BENCH (on device) ===');
    lines.add('variant                    backend        median ms       dev  note');

    for (final entry in variants.entries) {
      final bytes = (await rootBundle.load(entry.value)).buffer.asUint8List();

      Float32List? cpuRef;
      for (final backend in <String, PerformanceConfig?>{
        'none': null,
        'xnnpack': const PerformanceConfig.xnnpack(numThreads: 4),
        'gpu': const PerformanceConfig.gpu(),
        'coreml': const PerformanceConfig.coreml(),
      }.entries) {
        String note = '';
        String ms = '--';
        String dev = '--';
        try {
          final (median, out) = await measure(bytes, backend.value, input);
          ms = median.toStringAsFixed(2);
          if (backend.key == 'none') {
            cpuRef = out;
            note = 'reference';
          } else if (cpuRef != null) {
            var maxDev = 0.0;
            for (var i = 0; i < out.length; i++) {
              final d = (out[i] - cpuRef[i]).abs();
              if (d > maxDev) maxDev = d;
            }
            dev = maxDev.toStringAsExponential(2);
            note = maxDev == 0.0
                ? 'NO-OP, ran on CPU'
                : (maxDev > 1e-2 ? 'ENGAGED BUT WRONG' : 'engaged');
          }
        } catch (e) {
          note = 'FAILED [${e.runtimeType}] '
              '${e.toString().split('\n').first}';
          if (note.length > 96) note = '${note.substring(0, 96)}...';
        }
        lines.add('${entry.key.padRight(26)} ${backend.key.padRight(14)} '
            '${ms.padLeft(9)} ${dev.padLeft(9)}  $note');
      }
      lines.add('');
    }

    // One print call so the whole table survives the log stream intact.
    // ignore: avoid_print
    print(lines.join('\n'));
  }, timeout: const Timeout(Duration(minutes: 10)));
}
