#ifndef VOL_SPOTTER_POWER_BUTTON_DETECTOR_H_
#define VOL_SPOTTER_POWER_BUTTON_DETECTOR_H_

#include <windows.h>

#include <functional>
#include <map>
#include <string>

namespace device_sentinel {

/// Detects system suspend (power button / lid close) via WM_POWERBROADCAST.
/// Uses a hidden message-only window to receive power notifications.
class PowerButtonDetector {
 public:
  using EventCallback =
      std::function<void(const std::map<std::string, std::string>&)>;

  explicit PowerButtonDetector(EventCallback callback)
      : callback_(std::move(callback)) {}

  ~PowerButtonDetector() { Stop(); }

  void Start() {
    if (hwnd_) return;
    instance_ = this;

    WNDCLASS wc = {};
    wc.lpfnWndProc = WindowProc;
    wc.hInstance = GetModuleHandle(nullptr);
    wc.lpszClassName = L"DeviceSentinelPowerDetector";
    RegisterClass(&wc);

    hwnd_ = CreateWindowEx(0, wc.lpszClassName, L"", 0, 0, 0, 0, 0,
                           HWND_MESSAGE, nullptr, wc.hInstance, nullptr);
  }

  void Stop() {
    if (hwnd_) {
      DestroyWindow(hwnd_);
      hwnd_ = nullptr;
      UnregisterClass(L"DeviceSentinelPowerDetector", GetModuleHandle(nullptr));
    }
    if (instance_ == this) {
      instance_ = nullptr;
    }
  }

 private:
  static LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam,
                                     LPARAM lParam) {
    if (uMsg == WM_POWERBROADCAST && wParam == PBT_APMSUSPEND &&
        instance_) {
      try {
        instance_->callback_(
            {{"button", "power"}, {"action", "pressed"}});
      } catch (...) {
        // Prevent callback failures from crashing the message loop.
      }
      return TRUE;
    }
    return DefWindowProc(hwnd, uMsg, wParam, lParam);
  }

  EventCallback callback_;
  HWND hwnd_ = nullptr;

  static PowerButtonDetector* instance_;
};

PowerButtonDetector* PowerButtonDetector::instance_ = nullptr;

}  // namespace device_sentinel

#endif  // VOL_SPOTTER_POWER_BUTTON_DETECTOR_H_
