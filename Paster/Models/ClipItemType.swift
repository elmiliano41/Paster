import Foundation

enum ClipItemType: String, Codable, CaseIterable, Identifiable {
    case text
    case code
    case image
    case link
    case file
    case richText

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .text: "Texto"
        case .code: "Código"
        case .image: "Imagen"
        case .link: "Enlace"
        case .file: "Archivo"
        case .richText: "Texto Enriquecido"
        }
    }

    var iconName: String {
        switch self {
        case .text: "doc.text"
        case .code: "chevron.left.forwardslash.chevron.right"
        case .image: "photo"
        case .link: "link"
        case .file: "doc"
        case .richText: "doc.richtext"
        }
    }
}
