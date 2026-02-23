import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @Environment(DataStore.self) private var dataStore

    @AppStorage(AppConstants.Defaults.maxHistoryKey) private var maxHistory = AppConstants.defaultMaxHistoryItems
    @AppStorage(AppConstants.Defaults.autoStartKey) private var autoStart = false
    @AppStorage(AppConstants.Defaults.showPreviewKey) private var showPreview = true
    @AppStorage(AppConstants.Defaults.autoCleanupDays) private var autoCleanupDays = 30
    @AppStorage(AppConstants.Defaults.appLanguage) private var appLanguage = "system"

    @State private var selectedTab: SettingsTab = .general
    @State private var selectedLanguage: AppLanguage = LocalizationManager.shared.currentLanguage

    enum SettingsTab: String, CaseIterable, Identifiable {
        case general
        case shortcuts
        case categories
        case about

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .general: L("settings.general")
            case .shortcuts: L("settings.shortcuts")
            case .categories: L("settings.categories")
            case .about: L("settings.about")
            }
        }

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
                    Label(L("settings.general"), systemImage: "gear")
                }
                .tag(SettingsTab.general)

            shortcutsTab
                .tabItem {
                    Label(L("settings.shortcuts"), systemImage: "keyboard")
                }
                .tag(SettingsTab.shortcuts)

            categoriesTab
                .tabItem {
                    Label(L("settings.categories"), systemImage: "tag")
                }
                .tag(SettingsTab.categories)

            aboutTab
                .tabItem {
                    Label(L("settings.about"), systemImage: "info.circle")
                }
                .tag(SettingsTab.about)
        }
        .frame(width: 480, height: 420)
    }

    // MARK: - General Tab

    private var generalTab: some View {
        Form {
            Section {
                Toggle(L("settings.launchAtLogin"), isOn: $autoStart)
                    .onChange(of: autoStart) { _, newValue in
                        setAutoStart(newValue)
                    }

                Toggle(L("settings.showPreview"), isOn: $showPreview)
            } header: {
                Text(L("settings.behavior"))
            }

            Section {
                Stepper(
                    "\(L("settings.maxItems")): \(maxHistory)",
                    value: $maxHistory,
                    in: 50...5000,
                    step: 50
                )

                Picker(L("settings.autoCleanup"), selection: $autoCleanupDays) {
                    Text(L("settings.autoCleanup.never")).tag(0)
                    Text("7 \(L("settings.autoCleanup.days"))").tag(7)
                    Text("14 \(L("settings.autoCleanup.days"))").tag(14)
                    Text("30 \(L("settings.autoCleanup.days"))").tag(30)
                    Text("60 \(L("settings.autoCleanup.days"))").tag(60)
                    Text("90 \(L("settings.autoCleanup.days"))").tag(90)
                }

                Button(role: .destructive) {
                    dataStore.clearAll()
                } label: {
                    Label(L("settings.clearAllHistory"), systemImage: "trash")
                }
            } header: {
                Text(L("settings.history"))
            }

            Section {
                Picker(L("settings.language"), selection: $selectedLanguage) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.displayName).tag(language)
                    }
                }
                .onChange(of: selectedLanguage) { _, newValue in
                    LocalizationManager.shared.setLanguage(newValue)
                }

                HStack {
                    Text(L("settings.monitoringInterval"))
                    Spacer()
                    Text("\(String(format: "%.1f", AppConstants.clipboardPollingInterval))s")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text(L("settings.advanced"))
            } footer: {
                Text(L("settings.languageNote"))
                    .font(.system(size: 10))
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
                Text(L("about.clipboardManager"))
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                Text("\(L("about.version")) 1.0.0")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.secondary.opacity(0.5))
            }

            VStack(spacing: 8) {
                featureRow(icon: "clipboard", text: L("about.feature.history"))
                featureRow(icon: "magnifyingglass", text: L("about.feature.search"))
                featureRow(icon: "chevron.left.forwardslash.chevron.right", text: L("about.feature.syntax"))
                featureRow(icon: "photo", text: L("about.feature.preview"))
                featureRow(icon: "keyboard", text: L("about.feature.shortcut"))
                featureRow(icon: "tag", text: L("about.feature.categories"))
            }
            .padding(.horizontal, 40)

            Spacer()

            Text(L("about.madeWith"))
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
