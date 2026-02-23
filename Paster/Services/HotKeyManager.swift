import HotKey
import Carbon
import AppKit

final class HotKeyManager {
    private var hotKey: HotKey?
    private let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
        setupDefaultHotKey()
    }

    deinit {
        hotKey = nil
    }

    func setupDefaultHotKey() {
        // Default: Cmd + Shift + V
        hotKey = HotKey(key: .v, modifiers: [.command, .shift])
        hotKey?.keyDownHandler = { [weak self] in
            self?.action()
        }
    }

    func updateHotKey(key: Key, modifiers: NSEvent.ModifierFlags) {
        hotKey = nil
        hotKey = HotKey(key: key, modifiers: modifiers)
        hotKey?.keyDownHandler = { [weak self] in
            self?.action()
        }
    }

    func disable() {
        hotKey = nil
    }
}
