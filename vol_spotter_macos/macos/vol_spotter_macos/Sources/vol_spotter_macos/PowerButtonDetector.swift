import Cocoa

/// Detects power/sleep events on macOS by observing NSWorkspace
/// sleep notifications.
///
/// This fires when the user presses the power button, closes the lid,
/// or the system enters sleep for any reason. The power button cannot
/// be intercepted on macOS.
final class PowerButtonDetector: NSObject {

    private let onEvent: ([String: String]) -> Void
    private var isObserving = false

    init(onEvent: @escaping ([String: String]) -> Void) {
        self.onEvent = onEvent
        super.init()
    }

    func start() {
        guard !isObserving else { return }
        isObserving = true

        let nc = NSWorkspace.shared.notificationCenter
        nc.addObserver(
            self,
            selector: #selector(willSleep),
            name: NSWorkspace.willSleepNotification,
            object: nil
        )
        nc.addObserver(
            self,
            selector: #selector(screensDidSleep),
            name: NSWorkspace.screensDidSleepNotification,
            object: nil
        )
    }

    func stop() {
        guard isObserving else { return }
        isObserving = false
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    @objc private func willSleep() {
        onEvent(["button": "power", "action": "pressed"])
    }

    @objc private func screensDidSleep() {
        // Screen sleep can be triggered by power button or lid close.
        // Emit as power event for consistency.
        onEvent(["button": "power", "action": "pressed"])
    }

    deinit {
        if isObserving {
            NSWorkspace.shared.notificationCenter.removeObserver(self)
        }
    }
}
