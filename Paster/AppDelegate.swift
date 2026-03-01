import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    let dataStore = DataStore()
    let clipboardMonitor = ClipboardMonitor()
    let floatingPanelManager = FloatingPanelManager()
    let toastManager = ToastManager()
    lazy var pasteFromHistoryService = PasteFromHistoryService(dataStore: dataStore, toastManager: toastManager)
    private var hotKeyManager: HotKeyManager?
    private var panel: NSPanel?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        clipboardMonitor.startMonitoring(with: dataStore)

        dataStore.performAutoCleanup()

        createFloatingPanel()

        hotKeyManager = HotKeyManager(
            toggleAction: { [weak self] in self?.togglePanel() },
            pastePreviousAction: { [weak self] in self?.pasteFromHistoryService.pastePrevious() },
            pasteNextAction: { [weak self] in self?.pasteFromHistoryService.pasteNext() }
        )

        NotificationCenter.default.addObserver(
            forName: .showFloatingPanel, object: nil, queue: .main
        ) { [weak self] _ in
            self?.showPanel()
        }
        NotificationCenter.default.addObserver(
            forName: .hideFloatingPanel, object: nil, queue: .main
        ) { [weak self] _ in
            self?.hidePanel()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    // MARK: - Floating Panel

    private func createFloatingPanel() {
        let panel = NSPanel(
            contentRect: NSRect(
                x: 0, y: 0,
                width: AppConstants.UI.floatingPanelWidth,
                height: AppConstants.UI.floatingPanelHeight
            ),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.title = "Paster"
        panel.level = .floating
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.animationBehavior = .utilityWindow
        panel.backgroundColor = .clear

        let contentView = FloatingPanelView()
            .environment(dataStore)
            .environment(clipboardMonitor)

        panel.contentView = NSHostingView(rootView: contentView)
        panel.center()

        self.panel = panel
    }

    private func togglePanel() {
        guard let panel else { return }

        if panel.isVisible {
            hidePanel()
        } else {
            showPanel()
        }
    }

    private func showPanel() {
        guard let panel else { return }
        pasteFromHistoryService.resetIndexToLatest()
        NSApp.activate(ignoringOtherApps: true)
        panel.center()
        panel.makeKeyAndOrderFront(nil)
        floatingPanelManager.isVisible = true
    }

    private func hidePanel() {
        guard let panel else { return }
        panel.orderOut(nil)
        floatingPanelManager.isVisible = false
    }
}
