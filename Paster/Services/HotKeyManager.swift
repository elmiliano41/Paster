import HotKey
import Carbon
import AppKit

final class HotKeyManager {
    private var hotKeyToggle: HotKey?
    private var hotKeyPastePrevious: HotKey?
    private var hotKeyPasteNext: HotKey?

    private let toggleAction: () -> Void
    private let pastePreviousAction: () -> Void
    private let pasteNextAction: () -> Void

    init(
        toggleAction: @escaping () -> Void,
        pastePreviousAction: @escaping () -> Void,
        pasteNextAction: @escaping () -> Void
    ) {
        self.toggleAction = toggleAction
        self.pastePreviousAction = pastePreviousAction
        self.pasteNextAction = pasteNextAction
        setupToggleHotKey()
        setupPastePreviousHotKey()
        setupPasteNextHotKey()
    }

    deinit {
        hotKeyToggle = nil
        hotKeyPastePrevious = nil
        hotKeyPasteNext = nil
    }

    // MARK: - Toggle (abrir Paster)

    private func setupToggleHotKey() {
        let keyCode = UserDefaults.standard.object(forKey: AppConstants.Defaults.hotKeyKeyCode) as? Int
        let mods = UserDefaults.standard.object(forKey: AppConstants.Defaults.hotKeyModifiers) as? Int
        let key: Key = (keyCode.flatMap { Key(carbonKeyCode: UInt32($0)) }) ?? .v
        let modifiers: NSEvent.ModifierFlags = mods.map { NSEvent.ModifierFlags(carbonFlags: UInt32($0)) } ?? [.command, .shift]
        hotKeyToggle = HotKey(key: key, modifiers: modifiers, keyDownHandler: { [weak self] in
            self?.toggleAction()
        })
    }

    func updateHotKey(key: Key, modifiers: NSEvent.ModifierFlags) {
        UserDefaults.standard.set(Int(key.carbonKeyCode), forKey: AppConstants.Defaults.hotKeyKeyCode)
        UserDefaults.standard.set(Int(modifiers.carbonFlags), forKey: AppConstants.Defaults.hotKeyModifiers)
        hotKeyToggle = nil
        hotKeyToggle = HotKey(key: key, modifiers: modifiers, keyDownHandler: { [weak self] in
            self?.toggleAction()
        })
    }

    // MARK: - Pegar anterior / siguiente (por defecto ⌘⌥K = anterior, ⌘⌥J = siguiente)
    private static let pasteHistoryDefaultModifiers: NSEvent.ModifierFlags = [.command, .option]

    private func setupPastePreviousHotKey() {
        var keyCode = UserDefaults.standard.object(forKey: AppConstants.Defaults.pastePreviousKeyCode) as? Int
        var mods = UserDefaults.standard.object(forKey: AppConstants.Defaults.pastePreviousModifiers) as? Int
        if keyCode == Int(Key.leftBracket.carbonKeyCode) || keyCode == Int(Key.rightBracket.carbonKeyCode) || keyCode == Int(Key.p.carbonKeyCode) || keyCode == Int(Key.n.carbonKeyCode) {
            UserDefaults.standard.removeObject(forKey: AppConstants.Defaults.pastePreviousKeyCode)
            UserDefaults.standard.removeObject(forKey: AppConstants.Defaults.pastePreviousModifiers)
            keyCode = nil
            mods = nil
        }
        let key: Key = (keyCode.flatMap { Key(carbonKeyCode: UInt32($0)) }) ?? .k
        let modifiers: NSEvent.ModifierFlags = mods.map { NSEvent.ModifierFlags(carbonFlags: UInt32($0)) } ?? Self.pasteHistoryDefaultModifiers
        hotKeyPastePrevious = HotKey(key: key, modifiers: modifiers, keyDownHandler: { [weak self] in
            self?.pastePreviousAction()
        })
    }

    private func setupPasteNextHotKey() {
        var keyCode = UserDefaults.standard.object(forKey: AppConstants.Defaults.pasteNextKeyCode) as? Int
        var mods = UserDefaults.standard.object(forKey: AppConstants.Defaults.pasteNextModifiers) as? Int
        if keyCode == Int(Key.leftBracket.carbonKeyCode) || keyCode == Int(Key.rightBracket.carbonKeyCode) || keyCode == Int(Key.p.carbonKeyCode) || keyCode == Int(Key.n.carbonKeyCode) {
            UserDefaults.standard.removeObject(forKey: AppConstants.Defaults.pasteNextKeyCode)
            UserDefaults.standard.removeObject(forKey: AppConstants.Defaults.pasteNextModifiers)
            keyCode = nil
            mods = nil
        }
        let key: Key = (keyCode.flatMap { Key(carbonKeyCode: UInt32($0)) }) ?? .j
        let modifiers: NSEvent.ModifierFlags = mods.map { NSEvent.ModifierFlags(carbonFlags: UInt32($0)) } ?? Self.pasteHistoryDefaultModifiers
        hotKeyPasteNext = HotKey(key: key, modifiers: modifiers, keyDownHandler: { [weak self] in
            self?.pasteNextAction()
        })
    }

    func updatePastePreviousHotKey(key: Key, modifiers: NSEvent.ModifierFlags) {
        UserDefaults.standard.set(Int(key.carbonKeyCode), forKey: AppConstants.Defaults.pastePreviousKeyCode)
        UserDefaults.standard.set(Int(modifiers.carbonFlags), forKey: AppConstants.Defaults.pastePreviousModifiers)
        hotKeyPastePrevious = nil
        hotKeyPastePrevious = HotKey(key: key, modifiers: modifiers, keyDownHandler: { [weak self] in
            self?.pastePreviousAction()
        })
    }

    func updatePasteNextHotKey(key: Key, modifiers: NSEvent.ModifierFlags) {
        UserDefaults.standard.set(Int(key.carbonKeyCode), forKey: AppConstants.Defaults.pasteNextKeyCode)
        UserDefaults.standard.set(Int(modifiers.carbonFlags), forKey: AppConstants.Defaults.pasteNextModifiers)
        hotKeyPasteNext = nil
        hotKeyPasteNext = HotKey(key: key, modifiers: modifiers, keyDownHandler: { [weak self] in
            self?.pasteNextAction()
        })
    }

    func disable() {
        hotKeyToggle = nil
        hotKeyPastePrevious = nil
        hotKeyPasteNext = nil
    }
}
