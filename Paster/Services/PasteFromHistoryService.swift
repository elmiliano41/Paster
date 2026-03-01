import Foundation
import AppKit

/// Índice "último clip usado" en el historial (0 = más reciente). Pegar anterior/siguiente y mostrar toast.
final class PasteFromHistoryService {
    private var currentIndex: Int = 0
    private let dataStore: DataStore
    private let toastManager: ToastManager
    private let clipboardMonitor: ClipboardMonitor

    init(dataStore: DataStore, toastManager: ToastManager, clipboardMonitor: ClipboardMonitor) {
        self.dataStore = dataStore
        self.toastManager = toastManager
        self.clipboardMonitor = clipboardMonitor
    }

    /// Llamar al abrir el panel para sincronizar índice con “el más reciente”.
    func resetIndexToLatest() {
        currentIndex = 0
    }

    /// Pegar el clip anterior en el historial (más antiguo) y mostrar toast.
    func pastePrevious() {
        let items = dataStore.clipItems
        guard !items.isEmpty else { return }
        let nextIndex = min(currentIndex + 1, items.count - 1)
        guard nextIndex != currentIndex else { return }
        currentIndex = nextIndex
        let item = items[currentIndex]
        clipboardMonitor.suppressNextClipboardAdd()
        PasteService.copyAndPaste(item)
        toastManager.show(position: currentIndex + 1, total: items.count, preview: item.toastPreviewFourLines)
    }

    /// Pegar el clip siguiente en el historial (más reciente) y mostrar toast.
    func pasteNext() {
        let items = dataStore.clipItems
        guard !items.isEmpty else { return }
        let nextIndex = max(currentIndex - 1, 0)
        guard nextIndex != currentIndex else { return }
        currentIndex = nextIndex
        let item = items[currentIndex]
        clipboardMonitor.suppressNextClipboardAdd()
        PasteService.copyAndPaste(item)
        toastManager.show(position: currentIndex + 1, total: items.count, preview: item.toastPreviewFourLines)
    }
}
