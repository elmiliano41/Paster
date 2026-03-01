import SwiftUI
import AppKit
import HotKey

struct HotKeySettingsView: View {
    @State private var currentShortcut = "⌘⇧V"
    @State private var isRecording = false
    private static let pasteHistoryDefaultModifiers: NSEvent.ModifierFlags = [.command, .option]

    @State private var pastePreviousShortcut: String = {
        let k = UserDefaults.standard.object(forKey: AppConstants.Defaults.pastePreviousKeyCode) as? Int
        let m = UserDefaults.standard.object(forKey: AppConstants.Defaults.pastePreviousModifiers) as? Int
        return HotKeySettingsView.formatShortcut(keyCode: k, modifiers: m, defaultKey: .k, defaultModifiers: HotKeySettingsView.pasteHistoryDefaultModifiers)
    }()
    @State private var pasteNextShortcut: String = {
        let k = UserDefaults.standard.object(forKey: AppConstants.Defaults.pasteNextKeyCode) as? Int
        let m = UserDefaults.standard.object(forKey: AppConstants.Defaults.pasteNextModifiers) as? Int
        return HotKeySettingsView.formatShortcut(keyCode: k, modifiers: m, defaultKey: .j, defaultModifiers: HotKeySettingsView.pasteHistoryDefaultModifiers)
    }()

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(L("shortcuts.openPaster"))
                            .font(.system(size: 13, weight: .medium))

                        Spacer()

                        shortcutDisplay
                    }

                    Text(L("shortcuts.openPasterDesc"))
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text(L("shortcuts.globalShortcut"))
            }

            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(L("shortcuts.pastePrevious"))
                            .font(.system(size: 13, weight: .medium))
                        Spacer()
                        Text(pastePreviousShortcut)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    HStack {
                        Text(L("shortcuts.pasteNext"))
                            .font(.system(size: 13, weight: .medium))
                        Spacer()
                        Text(pasteNextShortcut)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            } header: {
                Text(L("shortcuts.pasteFromHistory"))
            } footer: {
                Text(L("shortcuts.pasteFromHistoryFooter"))
                    .font(.system(size: 11))
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    shortcutInfo(keys: "⌘⇧V", description: L("shortcuts.openCloseWindow"))
                    shortcutInfo(keys: pastePreviousShortcut, description: L("shortcuts.pastePrevious"))
                    shortcutInfo(keys: pasteNextShortcut, description: L("shortcuts.pasteNext"))
                    shortcutInfo(keys: "⌘C", description: L("shortcuts.copyAuto"))
                    shortcutInfo(keys: "↵", description: L("shortcuts.copySelected"))
                    shortcutInfo(keys: "⌘↵", description: L("shortcuts.copyAndPasteItem"))
                    shortcutInfo(keys: "⎋", description: L("shortcuts.closeWindow"))
                    shortcutInfo(keys: "⌫", description: L("shortcuts.deleteSelected"))
                    shortcutInfo(keys: "⌘F", description: L("shortcuts.focusSearch"))
                    shortcutInfo(keys: "↑↓", description: L("shortcuts.navigateHistory"))
                }
            } header: {
                Text(L("shortcuts.keyboardShortcuts"))
            }

            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L("shortcuts.accessibilityPermissions"))
                        .font(.system(size: 13, weight: .medium))
                    Text(L("shortcuts.accessibilityDesc"))
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)

                    Button {
                        openAccessibilityPreferences()
                    } label: {
                        Label(L("shortcuts.openAccessibility"), systemImage: "gear")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .padding(.top, 4)
                }
            } header: {
                Text(L("shortcuts.permissions"))
            }
        }
        .formStyle(.grouped)
        .padding(8)
        .onAppear {
            pastePreviousShortcut = HotKeySettingsView.formatShortcut(
                keyCode: UserDefaults.standard.object(forKey: AppConstants.Defaults.pastePreviousKeyCode) as? Int,
                modifiers: UserDefaults.standard.object(forKey: AppConstants.Defaults.pastePreviousModifiers) as? Int,
                defaultKey: .k,
                defaultModifiers: HotKeySettingsView.pasteHistoryDefaultModifiers
            )
            pasteNextShortcut = HotKeySettingsView.formatShortcut(
                keyCode: UserDefaults.standard.object(forKey: AppConstants.Defaults.pasteNextKeyCode) as? Int,
                modifiers: UserDefaults.standard.object(forKey: AppConstants.Defaults.pasteNextModifiers) as? Int,
                defaultKey: .j,
                defaultModifiers: HotKeySettingsView.pasteHistoryDefaultModifiers
            )
        }
    }

    // MARK: - Shortcut Display

    private var shortcutDisplay: some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                isRecording.toggle()
            }
        } label: {
            HStack(spacing: 4) {
                if isRecording {
                    Text(L("shortcuts.recording"))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.orange)

                    Image(systemName: "record.circle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.orange)
                        .symbolEffect(.pulse, isActive: isRecording)
                } else {
                    ForEach(shortcutKeys, id: \.self) { key in
                        Text(key)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.secondary.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isRecording ? Color.orange : Color.secondary.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .help(L("shortcuts.clickToChange"))
    }

    private var shortcutKeys: [String] {
        ["⌘", "⇧", "V"]
    }

    private func shortcutInfo(keys: String, description: String) -> some View {
        HStack {
            Text(keys)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .frame(width: 50, alignment: .leading)
                .foregroundStyle(Color.accentColor)
            Text(description)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private func openAccessibilityPreferences() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }

    private static func formatShortcut(keyCode: Int?, modifiers: Int?, defaultKey: Key, defaultModifiers: NSEvent.ModifierFlags = [.command, .shift]) -> String {
        let key = keyCode.flatMap { Key(carbonKeyCode: UInt32($0)) } ?? defaultKey
        let mods = modifiers.map { NSEvent.ModifierFlags(carbonFlags: UInt32($0)) } ?? defaultModifiers
        return mods.description + key.description
    }
}
