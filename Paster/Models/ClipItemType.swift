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
        case .text: L("type.text")
        case .code: L("type.code")
        case .image: L("type.image")
        case .link: L("type.link")
        case .file: L("type.file")
        case .richText: L("type.richText")
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
