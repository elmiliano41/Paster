import SwiftUI

struct HotKeySettingsView: View {
    @State private var currentShortcut = "⌘⇧V"
    @State private var isRecording = false

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
                VStack(alignment: .leading, spacing: 8) {
                    shortcutInfo(keys: "⌘⇧V", description: L("shortcuts.openCloseWindow"))
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
}
