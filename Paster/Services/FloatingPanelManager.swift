import AppKit
import Observation

@Observable
final class FloatingPanelManager {
    var isVisible: Bool = false

    func toggle() {
    }

    func show() {
        isVisible = true
        NotificationCenter.default.post(name: .showFloatingPanel, object: nil)
    }

    func hide() {
        isVisible = false
        NotificationCenter.default.post(name: .hideFloatingPanel, object: nil)
    }
}

extension Notification.Name {
    static let showFloatingPanel = Notification.Name("showFloatingPanel")
    static let hideFloatingPanel = Notification.Name("hideFloatingPanel")
}
