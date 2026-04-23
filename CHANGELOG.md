## 1.0.5

* Add public `DogDetector.modelVersion` and `DogDetector.modelVersionFor(...)` APIs for downstream cache invalidation.

## 1.0.4

* Update flutter_litert -> 2.2.0

## 1.0.3

* Update flutter_litert -> 2.1.0

## 1.0.2

* Update flutter_litert to 2.0.13
* Update animal_detection to 1.0.2

## 1.0.1

* Update flutter_litert -> 2.0.12 

## 1.0.0

* First stable release. On-device dog face detection and 46-point facial landmark prediction using TensorFlow Lite. Supports Android, iOS, macOS, Windows, and Linux with automatic hardware acceleration.

## 0.0.10

* Update documentation

## 0.0.9

* Update flutter_litert 2.0.8 -> 2.0.10

## 0.0.8

* Enable auto hardware acceleration by default (XNNPACK on all native platforms, Metal GPU on iOS)
* Update flutter_litert 2.0.6 -> 2.0.8
* Update animal_detection 0.0.5 -> 0.0.6

## 0.0.7

* Fix Android hang on sequential detect calls

## 0.0.6

* Fix isolate hanging on sequential detect calls

## 0.0.5

* Update animal_detection 0.0.3 -> 0.0.4

## 0.0.4

* Fix Xcode build warnings by declaring PrivacyInfo.xcprivacy as a resource bundle in iOS and macOS podspecs

## 0.0.3

* Refactor to use shared animal_detection utils

## 0.0.2

- Added homepage and repository to pubspec.yaml

## 0.0.1

- Initial release
- Dog face detection with bounding box
- 46 facial landmark extraction (ears, eyes, nose, mouth/chin)
- DogDetector and DogDetectorIsolate APIs
- Support for iOS, Android, macOS, Windows, Linux
