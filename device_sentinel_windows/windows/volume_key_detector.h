#ifndef VOL_SPOTTER_VOLUME_KEY_DETECTOR_H_
#define VOL_SPOTTER_VOLUME_KEY_DETECTOR_H_

#include <windows.h>

#include <functional>
#include <map>
#include <string>

namespace device_sentinel {

/// Detects volume key presses using a low-level keyboard hook.
/// When intercept is true, the key event is consumed (volume won't change).
class VolumeKeyDetector {
 public:
  using EventCallback =
      std::function<void(const std::map<std::string, std::string>&)>;

  VolumeKeyDetector(bool intercept, EventCallback callback)
      : intercept_(intercept), callback_(std::move(callback)) {}

  ~VolumeKeyDetector() { Stop(); }

  void Start() {
    if (hook_) return;
    instance_ = this;
    hook_ = SetWindowsHookEx(WH_KEYBOARD_LL, LowLevelKeyboardProc, nullptr, 0);
  }

  void Stop() {
    if (hook_) {
      UnhookWindowsHookEx(hook_);
      hook_ = nullptr;
    }
    if (instance_ == this) {
      instance_ = nullptr;
    }
  }

 private:
  static LRESULT CALLBACK LowLevelKeyboardProc(int nCode, WPARAM wParam,
                                                 LPARAM lParam) {
    if (nCode == HC_ACTION && instance_) {
      auto* kbd = reinterpret_cast<KBDLLHOOKSTRUCT*>(lParam);
      std::string button;
      if (kbd->vkCode == VK_VOLUME_UP) {
        button = "volumeUp";
      } else if (kbd->vkCode == VK_VOLUME_DOWN) {
        button = "volumeDown";
      }

      if (!button.empty()) {
        std::string action;
        if (wParam == WM_KEYDOWN || wParam == WM_SYSKEYDOWN) {
          action = "pressed";
        } else if (wParam == WM_KEYUP || wParam == WM_SYSKEYUP) {
          action = "released";
        }

        if (!action.empty()) {
          try {
            instance_->callback_({{"button", button}, {"action", action}});
          } catch (...) {
            // Prevent callback failures from crashing the hook chain.
          }
        }

        if (instance_->intercept_) {
          return 1;  // Consume the event.
        }
      }
    }
    return CallNextHookEx(nullptr, nCode, wParam, lParam);
  }

  bool intercept_;
  EventCallback callback_;
  HHOOK hook_ = nullptr;

  // Static singleton — only one detector per process.
  static VolumeKeyDetector* instance_;
};

// Definition of the static member.
VolumeKeyDetector* VolumeKeyDetector::instance_ = nullptr;

}  // namespace device_sentinel

#endif  // VOL_SPOTTER_VOLUME_KEY_DETECTOR_H_
