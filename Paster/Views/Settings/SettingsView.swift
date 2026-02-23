import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @Environment(DataStore.self) private var dataStore

    @AppStorage(AppConstants.Defaults.maxHistoryKey) private var maxHistory = AppConstants.defaultMaxHistoryItems
    @AppStorage(AppConstants.Defaults.autoStartKey) private var autoStart = false
    @AppStorage(AppConstants.Defaults.showPreviewKey) private var showPreview = true
    @AppStorage(AppConstants.Defaults.autoCleanupDays) private var autoCleanupDays = 30

    @State private var selectedTab: SettingsTab = .general

    enum SettingsTab: String, CaseIterable, Identifiable {
        case general = "General"
        case shortcuts = "Atajos"
        case categories = "Categorías"
        case about = "Acerca de"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .general: "gear"
            case .shortcuts: "keyboard"
            case .categories: "tag"
            case .about: "info.circle"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            generalTab
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(SettingsTab.general)

            shortcutsTab
                .tabItem {
                    Label("Atajos", systemImage: "keyboard")
                }
                .tag(SettingsTab.shortcuts)

            categoriesTab
                .tabItem {
                    Label("Categorías", systemImage: "tag")
                }
                .tag(SettingsTab.categories)

            aboutTab
                .tabItem {
                    Label("Acerca de", systemImage: "info.circle")
                }
                .tag(SettingsTab.about)
        }
        .frame(width: 480, height: 420)
    }

    // MARK: - General Tab

    private var generalTab: some View {
        Form {
            Section {
                Toggle("Iniciar al arrancar", isOn: $autoStart)
                    .onChange(of: autoStart) { _, newValue in
                        setAutoStart(newValue)
                    }

                Toggle("Mostrar vista previa en panel flotante", isOn: $showPreview)
            } header: {
                Text("Comportamiento")
            }

            Section {
                Stepper(
                    "Máximo de elementos: \(maxHistory)",
                    value: $maxHistory,
                    in: 50...5000,
                    step: 50
                )

                Picker("Limpieza automática", selection: $autoCleanupDays) {
                    Text("Nunca").tag(0)
                    Text("7 días").tag(7)
                    Text("14 días").tag(14)
                    Text("30 días").tag(30)
                    Text("60 días").tag(60)
                    Text("90 días").tag(90)
                }

                Button(role: .destructive) {
                    dataStore.clearAll()
                } label: {
                    Label("Limpiar todo el historial", systemImage: "trash")
                }
            } header: {
                Text("Historial")
            }

            Section {
                HStack {
                    Text("Intervalo de monitoreo")
                    Spacer()
                    Text("\(String(format: "%.1f", AppConstants.clipboardPollingInterval))s")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Avanzado")
            }
        }
        .formStyle(.grouped)
        .padding(8)
    }

    // MARK: - Shortcuts Tab

    private var shortcutsTab: some View {
        HotKeySettingsView()
    }

    // MARK: - Categories Tab

    private var categoriesTab: some View {
        ScrollView {
            CategoryManagement()
                .environment(dataStore)
        }
    }

    // MARK: - About Tab

    private var aboutTab: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "clipboard.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.accentColor)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.accentColor.opacity(0.1))
                )

            VStack(spacing: 4) {
                Text("Paster")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                Text("Clipboard Manager para macOS")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                Text("Versión 1.0.0")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.secondary.opacity(0.5))
            }

            VStack(spacing: 8) {
                featureRow(icon: "clipboard", text: "Historial completo del portapapeles")
                featureRow(icon: "magnifyingglass", text: "Búsqueda instantánea")
                featureRow(icon: "chevron.left.forwardslash.chevron.right", text: "Syntax highlighting para código")
                featureRow(icon: "photo", text: "Previsualización de imágenes y links")
                featureRow(icon: "keyboard", text: "Acceso rápido con Cmd+Shift+V")
                featureRow(icon: "tag", text: "Categorías personalizables")
            }
            .padding(.horizontal, 40)

            Spacer()

            Text("Hecho con SwiftUI")
                .font(.system(size: 10))
                .foregroundStyle(Color.secondary.opacity(0.3))
                .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.accentColor)
                .frame(width: 20)
            Text(text)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    // MARK: - Actions

    private func setAutoStart(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to \(enabled ? "enable" : "disable") auto start: \(error)")
        }
    }
}
