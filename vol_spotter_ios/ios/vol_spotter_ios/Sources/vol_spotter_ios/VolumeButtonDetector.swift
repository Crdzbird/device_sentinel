import AVFoundation
import MediaPlayer
import UIKit

final class VolumeButtonDetector: NSObject {

    private let intercept: Bool
    private let onEvent: ([String: String]) -> Void
    private var previousVolume: Float = 0
    private var volumeView: MPVolumeView?
    private var isObserving = false
    // Small offset used to keep volume away from 0.0/1.0 boundaries
    // in intercept mode so the next press can still be detected via KVO.
    private static let boundaryOffset: Float = 1.0 / 128.0

    init(intercept: Bool, onEvent: @escaping ([String: String]) -> Void) {
        self.intercept = intercept
        self.onEvent = onEvent
        super.init()
    }

    func start() {
        guard !isObserving else { return }
        isObserving = true

        configureAudioSession()
        let session = AVAudioSession.sharedInstance()
        previousVolume = session.outputVolume

        session.addObserver(
            self,
            forKeyPath: "outputVolume",
            options: [.new, .old],
            context: nil
        )

        if intercept {
            setupHiddenVolumeView()
            clampVolumeAwayFromBoundaries()
        }
    }

    func stop() {
        guard isObserving else { return }
        isObserving = false

        AVAudioSession.sharedInstance().removeObserver(
            self,
            forKeyPath: "outputVolume"
        )
        removeHiddenVolumeView()
    }

    // MARK: - Audio Session

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            // Use .ambient to avoid interrupting other audio (e.g. music).
            // .mixWithOthers ensures we don't pause the current audio.
            try session.setCategory(.ambient, options: .mixWithOthers)
            try session.setActive(true)
        } catch {
            // Volume observation still works in most cases even if
            // category setup fails — continue gracefully.
        }
    }

    // MARK: - KVO

    // swiftlint:disable:next block_based_kvo
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard keyPath == "outputVolume" else {
            super.observeValue(
                forKeyPath: keyPath,
                of: object,
                change: change,
                context: context
            )
            return
        }
        guard let newVolume = change?[.newKey] as? Float else { return }

        let button: String
        if newVolume > previousVolume {
            button = "volumeUp"
        } else if newVolume < previousVolume {
            button = "volumeDown"
        } else {
            return
        }
        onEvent(["button": button, "action": "pressed"])

        if intercept {
            resetVolume(to: previousVolume)
            // After resetting, ensure we are not stuck at a boundary.
            clampVolumeAwayFromBoundaries()
        } else {
            previousVolume = newVolume
        }
    }

    // MARK: - Volume Control

    /// Moves the volume slightly away from 0.0 or 1.0 so that a subsequent
    /// button press still triggers a KVO change.
    private func clampVolumeAwayFromBoundaries() {
        let offset = VolumeButtonDetector.boundaryOffset
        if previousVolume <= 0 {
            previousVolume = offset
            resetVolume(to: previousVolume)
        } else if previousVolume >= 1 {
            previousVolume = 1.0 - offset
            resetVolume(to: previousVolume)
        }
    }

    private func resetVolume(to value: Float) {
        guard let slider = findSlider(in: volumeView) else { return }
        DispatchQueue.main.async { [weak slider] in
            slider?.value = value
        }
    }

    /// Recursively searches the view hierarchy for the UISlider inside
    /// MPVolumeView. On some iOS versions the slider is a direct subview;
    /// on others it may be nested deeper.
    private func findSlider(in view: UIView?) -> UISlider? {
        guard let view = view else { return nil }
        for subview in view.subviews {
            if let slider = subview as? UISlider {
                return slider
            }
            if let found = findSlider(in: subview) {
                return found
            }
        }
        return nil
    }

    // MARK: - Hidden Volume View

    private func setupHiddenVolumeView() {
        let frame = CGRect(x: -1000, y: -1000, width: 1, height: 1)
        let view = MPVolumeView(frame: frame)
        view.alpha = 0.01
        view.clipsToBounds = true

        if let window = findKeyWindow() {
            window.addSubview(view)
        }
        volumeView = view
    }

    private func removeHiddenVolumeView() {
        volumeView?.removeFromSuperview()
        volumeView = nil
    }

    /// Finds the key window across all iOS versions 13+.
    /// iOS 15+ deprecates UIWindowScene.windows in favor of .keyWindow.
    private func findKeyWindow() -> UIWindow? {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }

        if #available(iOS 15.0, *) {
            return scenes.compactMap(\.keyWindow).first
        }
        return scenes.flatMap(\.windows).first(where: \.isKeyWindow)
    }

    deinit {
        if isObserving {
            AVAudioSession.sharedInstance().removeObserver(
                self,
                forKeyPath: "outputVolume"
            )
        }
        removeHiddenVolumeView()
    }
}
