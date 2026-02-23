import Foundation
import SwiftUI

final class Category: Identifiable, Codable, Hashable, ObservableObject {
    let id: UUID
    var name: String
    var colorHex: String
    var icon: String

    init(
        name: String,
        colorHex: String = "#007AFF",
        icon: String = "tag"
    ) {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.icon = icon
    }

    var color: Color {
        Color(hex: colorHex)
    }

    // MARK: - Hashable
    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
