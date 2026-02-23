import SwiftUI

struct PinButton: View {
    let isPinned: Bool
    let action: () -> Void

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                action()
            }
        } label: {
            Image(systemName: isPinned ? "pin.fill" : "pin")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(isPinned ? .orange : .secondary)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .help(isPinned ? "Desfijar" : "Fijar")
        .accessibilityLabel(isPinned ? "Desfijar elemento" : "Fijar elemento")
    }
}
