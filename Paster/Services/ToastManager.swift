import AppKit
import SwiftUI

/// Muestra un toast breve con preview truncado del clip recién pegado. Auto-oculta en 1,75 s.
final class ToastManager {
    private var panel: NSPanel?
    private var hideWorkItem: DispatchWorkItem?
    private let toastDuration: TimeInterval = 1.75
    private let panelWidth: CGFloat = 420
    private let lineHeight: CGFloat = 18
    private let paddingVertical: CGFloat = 12
    private let positionLineHeight: CGFloat = 16
    private let spacing: CGFloat = 8

    func show(position: Int, total: Int, preview: String) {
        DispatchQueue.main.async { [weak self] in
            self?.hideWorkItem?.cancel()
            self?.showToast(position: position, total: total, text: preview.isEmpty ? " " : preview)
        }
    }

    private func showToast(position: Int, total: Int, text: String) {
        if panel == nil {
            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: panelWidth, height: 80),
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

        let lineCount = min(4, text.components(separatedBy: .newlines).count)
        let contentHeight = paddingVertical + positionLineHeight + spacing + (lineCount > 0 ? CGFloat(lineCount) * lineHeight : lineHeight) + paddingVertical
        let panelHeight = max(70, contentHeight)

        let positionLabel = "\(position) / \(total)"
        let content = VStack(alignment: .leading, spacing: 8) {

            HStack(alignment: .top, spacing: 16) {
                Text(text)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(4)
                    .truncationMode(.tail)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(positionLabel)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 48, alignment: .trailing)
                    .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))

        panel.setContentSize(NSSize(width: panelWidth, height: panelHeight))
        panel.contentView = NSHostingView(rootView: content)
        panel.contentView?.frame = NSRect(x: 0, y: 0, width: panelWidth, height: panelHeight)

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
