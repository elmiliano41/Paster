import Foundation
import AppKit

/// Índice "último clip usado" en el historial (0 = más reciente). Pegar anterior/siguiente y mostrar toast.
final class PasteFromHistoryService {
    private var currentIndex: Int = 0
    private let dataStore: DataStore
    private let toastManager: ToastManager

    init(dataStore: DataStore, toastManager: ToastManager) {
        self.dataStore = dataStore
        self.toastManager = toastManager
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
        PasteService.copyAndPaste(item)
        toastManager.show(preview: item.toastPreview)
    }

    /// Pegar el clip siguiente en el historial (más reciente) y mostrar toast.
    func pasteNext() {
        let items = dataStore.clipItems
        guard !items.isEmpty else { return }
        let nextIndex = max(currentIndex - 1, 0)
        guard nextIndex != currentIndex else { return }
        currentIndex = nextIndex
        let item = items[currentIndex]
        PasteService.copyAndPaste(item)
        toastManager.show(preview: item.toastPreview)
    }
}
