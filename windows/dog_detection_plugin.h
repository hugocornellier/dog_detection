#ifndef FLUTTER_PLUGIN_DOG_DETECTION_PLUGIN_H_
#define FLUTTER_PLUGIN_DOG_DETECTION_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace dog_detection {

class DogDetectionPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  DogDetectionPlugin();

  virtual ~DogDetectionPlugin();

  DogDetectionPlugin(const DogDetectionPlugin&) = delete;
  DogDetectionPlugin& operator=(const DogDetectionPlugin&) = delete;

  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace dog_detection

#endif  // FLUTTER_PLUGIN_DOG_DETECTION_PLUGIN_H_
