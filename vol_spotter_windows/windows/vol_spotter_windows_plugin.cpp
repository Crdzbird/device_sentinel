#include "include/vol_spotter_windows/vol_spotter_windows.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <string>

#include "power_button_detector.h"
#include "volume_key_detector.h"

namespace {

using flutter::EncodableMap;
using flutter::EncodableValue;

class VolSpotterWindows : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(
      flutter::PluginRegistrarWindows* registrar);

  VolSpotterWindows();
  virtual ~VolSpotterWindows();

 private:
  void HandleMethodCall(
      const flutter::MethodCall<EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<EncodableValue>> result);

  void StartDetection(bool intercept_volume);
  void StopDetection();
  void SendEvent(const std::map<std::string, std::string>& event);

  std::unique_ptr<flutter::EventSink<EncodableValue>> event_sink_;
  std::unique_ptr<vol_spotter::VolumeKeyDetector> volume_detector_;
  std::unique_ptr<vol_spotter::PowerButtonDetector> power_detector_;
};

void VolSpotterWindows::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto method_channel =
      std::make_unique<flutter::MethodChannel<EncodableValue>>(
          registrar->messenger(), "vol_spotter_windows",
          &flutter::StandardMethodCodec::GetInstance());

  auto event_channel =
      std::make_unique<flutter::EventChannel<EncodableValue>>(
          registrar->messenger(), "vol_spotter_windows/events",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<VolSpotterWindows>();
  auto* plugin_ptr = plugin.get();

  method_channel->SetMethodCallHandler(
      [plugin_ptr](const auto& call, auto result) {
        plugin_ptr->HandleMethodCall(call, std::move(result));
      });

  auto stream_handler =
      std::make_unique<flutter::StreamHandlerFunctions<EncodableValue>>(
          [plugin_ptr](const EncodableValue* arguments,
                       std::unique_ptr<flutter::EventSink<EncodableValue>>&&
                           events)
              -> std::unique_ptr<flutter::StreamHandlerError<EncodableValue>> {
            plugin_ptr->event_sink_ = std::move(events);
            return nullptr;
          },
          [plugin_ptr](const EncodableValue* arguments)
              -> std::unique_ptr<flutter::StreamHandlerError<EncodableValue>> {
            plugin_ptr->event_sink_ = nullptr;
            return nullptr;
          });

  event_channel->SetStreamHandler(std::move(stream_handler));

  registrar->AddPlugin(std::move(plugin));
}

VolSpotterWindows::VolSpotterWindows() {}

VolSpotterWindows::~VolSpotterWindows() { StopDetection(); }

void VolSpotterWindows::HandleMethodCall(
    const flutter::MethodCall<EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  const auto& method = method_call.method_name();

  if (method == "getPlatformName") {
    result->Success(EncodableValue("Windows"));
  } else if (method == "startListening") {
    bool intercept_volume = false;
    if (const auto* args =
            std::get_if<EncodableMap>(method_call.arguments())) {
      auto it = args->find(EncodableValue("interceptVolumeEvents"));
      if (it != args->end()) {
        if (const auto* val = std::get_if<bool>(&it->second)) {
          intercept_volume = *val;
        }
      }
    }
    StartDetection(intercept_volume);
    result->Success();
  } else if (method == "stopListening") {
    StopDetection();
    result->Success();
  } else {
    result->NotImplemented();
  }
}

void VolSpotterWindows::StartDetection(bool intercept_volume) {
  StopDetection();

  volume_detector_ = std::make_unique<vol_spotter::VolumeKeyDetector>(
      intercept_volume,
      [this](const std::map<std::string, std::string>& event) {
        SendEvent(event);
      });
  volume_detector_->Start();

  power_detector_ = std::make_unique<vol_spotter::PowerButtonDetector>(
      [this](const std::map<std::string, std::string>& event) {
        SendEvent(event);
      });
  power_detector_->Start();
}

void VolSpotterWindows::StopDetection() {
  volume_detector_.reset();
  power_detector_.reset();
}

void VolSpotterWindows::SendEvent(
    const std::map<std::string, std::string>& event) {
  if (!event_sink_) return;
  EncodableMap map;
  for (const auto& pair : event) {
    map[EncodableValue(pair.first)] = EncodableValue(pair.second);
  }
  event_sink_->Success(EncodableValue(map));
}

}  // namespace

void VolSpotterWindowsRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  VolSpotterWindows::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
