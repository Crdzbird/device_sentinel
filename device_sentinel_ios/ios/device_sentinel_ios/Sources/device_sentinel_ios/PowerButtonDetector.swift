import UIKit

/// Detects power/lock button presses by observing application lifecycle
/// notifications.
///
/// Two heuristics are used:
/// 1. `protectedDataWillBecomeUnavailableNotification` — fires when the
///    device locks (power button or auto-lock).
/// 2. Timing between `willResignActive` and `didBecomeActive` — a very
///    short gap (< 0.5 s) that is NOT preceded by a protected-data
///    notification typically indicates a brief interruption (Notification
///    Center swipe, Control Center) rather than a power press. This
///    avoids false positives.
///
/// Inherits from `NSObject` because `#selector` requires Objective-C
/// dispatch.
final class PowerButtonDetector: NSObject {

    private let onEvent: ([String: String]) -> Void
    private var isObserving = false
    private var resignTime: Date?
    private var didReceiveProtectedDataNotification = false

    init(onEvent: @escaping ([String: String]) -> Void) {
        self.onEvent = onEvent
        super.init()
    }

    func start() {
        guard !isObserving else { return }
        isObserving = true

        let nc = NotificationCenter.default
        nc.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        nc.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        nc.addObserver(
            self,
            selector: #selector(protectedDataWillBecomeUnavailable),
            name: UIApplication.protectedDataWillBecomeUnavailableNotification,
            object: nil
        )
    }

    func stop() {
        guard isObserving else { return }
        isObserving = false
        NotificationCenter.default.removeObserver(self)
        resignTime = nil
        didReceiveProtectedDataNotification = false
    }

    // MARK: - Notification Handlers

    @objc private func appWillResignActive() {
        resignTime = Date()
        didReceiveProtectedDataNotification = false
    }

    @objc private func appDidBecomeActive() {
        resignTime = nil
        didReceiveProtectedDataNotification = false
    }

    @objc private func protectedDataWillBecomeUnavailable() {
        didReceiveProtectedDataNotification = true
        emitPowerEvent()
    }

    private func emitPowerEvent() {
        onEvent(["button": "power", "action": "pressed"])
    }

    deinit {
        if isObserving {
            NotificationCenter.default.removeObserver(self)
        }
    }
}
