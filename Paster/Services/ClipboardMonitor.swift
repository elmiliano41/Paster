import AppKit
import Observation

@Observable
final class ClipboardMonitor {
    private(set) var lastChangeCount: Int = 0
    private(set) var isMonitoring: Bool = false
    private var timer: Timer?
    private var dataStore: DataStore?
    private var shouldSuppressNextAdd: Bool = false

    var latestClipContent: String?
    var latestClipType: ClipItemType = .text

    init() {
        lastChangeCount = NSPasteboard.general.changeCount
    }

    func startMonitoring(with store: DataStore) {
        dataStore = store
        guard !isMonitoring else { return }
        isMonitoring = true
        timer = Timer.scheduledTimer(
            withTimeInterval: AppConstants.clipboardPollingInterval,
            repeats: true
        ) { [weak self] _ in
            self?.checkClipboard()
        }
    }

    func stopMonitoring() {
        isMonitoring = false
        timer?.invalidate()
        timer = nil
    }

    func suppressNextClipboardAdd() {
        shouldSuppressNextAdd = true
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        let currentCount = pasteboard.changeCount

        guard currentCount != lastChangeCount else { return }
        lastChangeCount = currentCount

        if shouldSuppressNextAdd {
            shouldSuppressNextAdd = false
            return
        }

        // Determine the type and content
        if let imageData = extractImage(from: pasteboard) {
            saveClipItem(content: L("clip.imageCopied"), imageData: imageData, type: .image)
        } else if let fileURLs = extractFileURLs(from: pasteboard) {
            for url in fileURLs {
                saveClipItem(content: url.path, type: .file)
            }
        } else if let string = pasteboard.string(forType: .string) {
            // Skip if content is empty or whitespace only
            guard !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

            // Detect type
            let type = detectType(for: string)
            let language = type == .code ? SyntaxDetector.detectLanguage(for: string) : nil

            saveClipItem(content: string, type: type, detectedLanguage: language)
        }
    }

    private func detectType(for string: String) -> ClipItemType {
        if string.isURL {
            return .link
        }
        if string.isLikelyCode {
            return .code
        }
        return .text
    }

    private func extractImage(from pasteboard: NSPasteboard) -> Data? {
        guard let type = pasteboard.availableType(from: [.tiff, .png]) else { return nil }
        guard let data = pasteboard.data(forType: type) else { return nil }
        guard let image = NSImage(data: data) else { return nil }
        return image.resized(to: AppConstants.maxImageThumbnailSize * 2).pngData
    }

    private func extractFileURLs(from pasteboard: NSPasteboard) -> [URL]? {
        guard let items = pasteboard.pasteboardItems else { return nil }
        var urls: [URL] = []
        for item in items {
            if let urlString = item.string(forType: .fileURL),
               let url = URL(string: urlString) {
                urls.append(url)
            }
        }
        return urls.isEmpty ? nil : urls
    }

    private func saveClipItem(
        content: String,
        imageData: Data? = nil,
        type: ClipItemType,
        detectedLanguage: String? = nil
    ) {
        guard let store = dataStore else { return }

        let sourceApp = NSWorkspace.shared.frontmostApplication?.bundleIdentifier

        let item = ClipItem(
            content: content,
            imageData: imageData,
            type: type,
            detectedLanguage: detectedLanguage,
            sourceApp: sourceApp
        )

        store.addClipItem(item)

        latestClipContent = content
        latestClipType = type
    }
}
