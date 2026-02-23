import SwiftUI

@main
struct PasterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environment(appDelegate.dataStore)
                .environment(appDelegate.clipboardMonitor)
                .environment(appDelegate.floatingPanelManager)
        } label: {
            Label("Paster", systemImage: "clipboard")
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environment(appDelegate.dataStore)
        }
    }
}
