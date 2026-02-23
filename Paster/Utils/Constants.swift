import Foundation

enum AppConstants {
    static let appName = "Paster"
    static let defaultMaxHistoryItems = 500
    static let clipboardPollingInterval: TimeInterval = 0.75
    static let maxPreviewLines = 8
    static let maxImageThumbnailSize: CGFloat = 300

    enum Defaults {
        static let maxHistoryKey = "maxHistoryItems"
        static let autoStartKey = "autoStartAtLogin"
        static let showPreviewKey = "showPreview"
        static let hotKeyKeyCode = "hotKeyKeyCode"
        static let hotKeyModifiers = "hotKeyModifiers"
        static let autoCleanupDays = "autoCleanupDays"
        static let appLanguage = "appLanguage"
    }

    enum UI {
        static let menuBarWidth: CGFloat = 340
        static let menuBarHeight: CGFloat = 480
        static let floatingPanelWidth: CGFloat = 680
        static let floatingPanelHeight: CGFloat = 520
        static let rowHeight: CGFloat = 56
        static let cornerRadius: CGFloat = 12
        static let smallCornerRadius: CGFloat = 8
    }
}
