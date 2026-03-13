import Cocoa
import CoreGraphics

/// Detects volume key presses on macOS using a Quartz Event Tap.
///
/// Media keys (including volume up/down) are sent as `NX_SYSDEFINED` system
/// events. The `data1` field encodes the key code and key state.
///
/// When `intercept` is true, a head-insert event tap is used so we can
/// return `nil` from the callback to consume the event (preventing the
/// system volume from changing). Requires Accessibility permissions.
///
/// When `intercept` is false, a listen-only tap is used (no permissions
/// required on most macOS versions).
final class VolumeKeyDetector {

    private let intercept: Bool
    private let onEvent: ([String: String]) -> Void
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    // NX_KEYTYPE constants for media keys.
    private static let nxKeyTypeSoundUp: Int = 0
    private static let nxKeyTypeSoundDown: Int = 1

    init(intercept: Bool, onEvent: @escaping ([String: String]) -> Void) {
        self.intercept = intercept
        self.onEvent = onEvent
    }

    func start() {
        guard eventTap == nil else { return }

        // Prompt for Accessibility permissions if intercepting.
        if intercept {
            let trusted = AXIsProcessTrustedWithOptions(
                [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
            )
            if !trusted {
                // The user will be prompted. The tap will not receive events
                // until the app is granted Accessibility access and relaunched.
            }
        }

        let eventMask: CGEventMask = 1 << 14  // NX_SYSDEFINED = 14

        // Wrap self in an unmanaged pointer for the C callback.
        let userInfo = Unmanaged.passUnretained(self).toOpaque()

        let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: intercept ? .headInsertEventTap : .tailAppendEventTap,
            options: intercept ? .defaultTap : .listenOnly,
            eventsOfInterest: eventMask,
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else {
                    return Unmanaged.passUnretained(event)
                }
                let detector = Unmanaged<VolumeKeyDetector>
                    .fromOpaque(refcon)
                    .takeUnretainedValue()
                return detector.handleEvent(proxy: proxy, type: type, event: event)
            },
            userInfo: userInfo
        )

        guard let tap = tap else { return }
        eventTap = tap

        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        runLoopSource = source
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    func stop() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            if let source = runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
            }
            CFMachPortInvalidate(tap)
        }
        runLoopSource = nil
        eventTap = nil
    }

    // MARK: - Event Handling

    private func handleEvent(
        proxy: CGEventTapProxy,
        type: CGEventType,
        event: CGEvent
    ) -> Unmanaged<CGEvent>? {
        // If the tap is disabled by the system (e.g. timeout), re-enable it.
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let tap = eventTap {
                CGEvent.tapEnable(tap: tap, enable: true)
            }
            return Unmanaged.passUnretained(event)
        }

        guard let nsEvent = NSEvent(cgEvent: event) else {
            return Unmanaged.passUnretained(event)
        }

        // Media keys arrive as system-defined events with subtype 8.
        guard nsEvent.type == .systemDefined, nsEvent.subtype.rawValue == 8 else {
            return Unmanaged.passUnretained(event)
        }

        let data1 = nsEvent.data1
        let keyCode = (data1 & 0xFFFF_0000) >> 16
        let keyFlags = (data1 & 0x0000_FF00) >> 8
        let isKeyDown = (keyFlags & 0x0A) != 0
        let isKeyUp = (keyFlags & 0x0B) != 0 && !isKeyDown

        let button: String?
        switch keyCode {
        case Self.nxKeyTypeSoundUp:
            button = "volumeUp"
        case Self.nxKeyTypeSoundDown:
            button = "volumeDown"
        default:
            button = nil
        }

        guard let button = button else {
            return Unmanaged.passUnretained(event)
        }

        let action: String
        if isKeyDown {
            action = "pressed"
        } else if isKeyUp {
            action = "released"
        } else {
            return Unmanaged.passUnretained(event)
        }

        onEvent(["button": button, "action": action])

        if intercept {
            return nil  // Consume the event.
        }
        return Unmanaged.passUnretained(event)
    }

    deinit {
        stop()
    }
}
