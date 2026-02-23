import SwiftUI

struct HotKeySettingsView: View {
    @State private var currentShortcut = "⌘⇧V"
    @State private var isRecording = false

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Abrir Paster")
                            .font(.system(size: 13, weight: .medium))

                        Spacer()

                        shortcutDisplay
                    }

                    Text("Presiona este atajo en cualquier lugar para abrir la ventana flotante de Paster.")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Atajo global")
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    shortcutInfo(keys: "⌘⇧V", description: "Abrir/cerrar ventana flotante")
                    shortcutInfo(keys: "⌘C", description: "Copiar (automáticamente se guarda)")
                    shortcutInfo(keys: "↵", description: "Copiar elemento seleccionado")
                    shortcutInfo(keys: "⌘↵", description: "Copiar y pegar elemento")
                    shortcutInfo(keys: "⎋", description: "Cerrar ventana")
                    shortcutInfo(keys: "⌫", description: "Eliminar elemento seleccionado")
                    shortcutInfo(keys: "⌘F", description: "Enfocar búsqueda")
                    shortcutInfo(keys: "↑↓", description: "Navegar por el historial")
                }
            } header: {
                Text("Atajos de teclado")
            }

            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Permisos de accesibilidad")
                        .font(.system(size: 13, weight: .medium))
                    Text("Paster necesita permisos de accesibilidad para registrar atajos globales y simular la acción de pegar. Ve a Preferencias del Sistema → Privacidad y Seguridad → Accesibilidad.")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)

                    Button {
                        openAccessibilityPreferences()
                    } label: {
                        Label("Abrir Preferencias de Accesibilidad", systemImage: "gear")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .padding(.top, 4)
                }
            } header: {
                Text("Permisos")
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
                    Text("Grabando…")
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
        .help("Haz clic para cambiar el atajo")
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
