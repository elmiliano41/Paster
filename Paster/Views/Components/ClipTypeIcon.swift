import SwiftUI

struct ClipTypeIcon: View {
    let type: ClipItemType
    var size: CGFloat = 12

    var body: some View {
        Image(systemName: type.iconName)
            .font(.system(size: size, weight: .medium))
            .foregroundStyle(iconColor)
            .accessibilityLabel(type.displayName)
    }

    private var iconColor: Color {
        switch type {
        case .text: .secondary
        case .code: .green
        case .image: .blue
        case .link: .purple
        case .file: .orange
        case .richText: .pink
        }
    }
}
