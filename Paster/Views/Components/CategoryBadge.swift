import SwiftUI

struct CategoryBadge: View {
    let category: Category

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: category.icon)
                .font(.system(size: 9, weight: .semibold))
            Text(category.name)
                .font(.system(size: 10, weight: .medium))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(category.color.opacity(0.15))
        .foregroundStyle(category.color)
        .clipShape(Capsule())
        .accessibilityLabel("Categoría: \(category.name)")
    }
}
