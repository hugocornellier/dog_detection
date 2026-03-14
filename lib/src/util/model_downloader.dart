import 'dart:typed_data';
import 'package:animal_detection/animal_detection.dart';

/// Dog-specific model downloader wrapping [SpeciesModelDownloader].
class DogModelDownloader {
  static const _downloader = SpeciesModelDownloader(
    releaseBaseUrl:
        'https://github.com/hugocornellier/dog_detection/releases/download/v0.0.1-models',
    cacheSubdir: 'dog_detection/models',
    model256Name: 'dog_face_landmarks_256_float16.tflite',
    model320Name: 'dog_face_landmarks_320_float16.tflite',
  );

  /// Downloads both ensemble models (256px and 320px) in parallel.
  static Future<(Uint8List, Uint8List)> getEnsembleModels({
    void Function(String model, int received, int total)? onProgress,
  }) =>
      _downloader.getEnsembleModels(onProgress: onProgress);

  /// Returns true if both ensemble models are already cached locally.
  static Future<bool> isEnsembleCached() => _downloader.isEnsembleCached();

  /// Deletes all cached models.
  static Future<void> clearCache() => _downloader.clearCache();
}
