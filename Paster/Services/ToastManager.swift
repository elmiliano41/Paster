import AppKit
import SwiftUI

/// Muestra un toast breve con preview truncado del clip recién pegado. Auto-oculta en 1,75 s.
final class ToastManager {
    private var panel: NSPanel?
    private var hideWorkItem: DispatchWorkItem?
    private let toastDuration: TimeInterval = 1.75

    func show(preview: String) {
        DispatchQueue.main.async { [weak self] in
            self?.hideWorkItem?.cancel()
            self?.showToast(text: preview.isEmpty ? " " : preview)
        }
    }

    private func showToast(text: String) {
        if panel == nil {
            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 44),
                styleMask: [.borderless, .nonactivatingPanel],
                backing: .buffered,
                defer: false
            )
            panel.isOpaque = false
            panel.backgroundColor = .clear
            panel.level = .floating
            panel.collectionBehavior = [.canJoinAllSpaces]
            panel.hidesOnDeactivate = false
            self.panel = panel
        }

        guard let panel else { return }

        let content = Text(text)
            .font(.system(size: 13, weight: .medium))
            .lineLimit(2)
            .truncationMode(.tail)
            .foregroundStyle(.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))

        panel.contentView = NSHostingView(rootView: content)
        panel.contentView?.frame = NSRect(x: 0, y: 0, width: 400, height: 44)

        positionPanel(panel)
        panel.orderFrontRegardless()

        hideWorkItem = DispatchWorkItem { [weak self] in
            self?.panel?.orderOut(nil)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + toastDuration, execute: hideWorkItem!)
    }

    private func positionPanel(_ panel: NSPanel) {
        guard let screen = NSScreen.main ?? NSScreen.screens.first else { return }
        let frame = screen.visibleFrame
        let panelFrame = panel.frame
        let x = frame.midX - panelFrame.width / 2
        let y = frame.maxY - panelFrame.height - 80
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }
}
