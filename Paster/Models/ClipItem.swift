import Foundation
import AppKit

final class ClipItem: Identifiable, Codable, Hashable, ObservableObject {
    let id: UUID
    var content: String
    var imageData: Data?
    var typeRaw: String
    var detectedLanguage: String?
    var sourceApp: String?
    var timestamp: Date
    var isPinned: Bool
    var categoryId: UUID?

    var type: ClipItemType {
        get { ClipItemType(rawValue: typeRaw) ?? .text }
        set { typeRaw = newValue.rawValue }
    }

    init(
        content: String,
        imageData: Data? = nil,
        type: ClipItemType = .text,
        detectedLanguage: String? = nil,
        sourceApp: String? = nil,
        isPinned: Bool = false,
        categoryId: UUID? = nil
    ) {
        self.id = UUID()
        self.content = content
        self.imageData = imageData
        self.typeRaw = type.rawValue
        self.detectedLanguage = detectedLanguage
        self.sourceApp = sourceApp
        self.timestamp = Date()
        self.isPinned = isPinned
        self.categoryId = categoryId
    }

    var preview: String {
        if type == .image {
            return "Imagen copiada"
        }
        let maxLength = 200
        if content.count > maxLength {
            return String(content.prefix(maxLength)) + "…"
        }
        return content
    }

    var firstLine: String {
        let line = content.components(separatedBy: .newlines).first ?? content
        if line.count > 80 {
            return String(line.prefix(80)) + "…"
        }
        return line
    }

    /// Preview corto para el toast tras "pegado desde historial" (aprox. 55 caracteres).
    var toastPreview: String {
        if type == .image {
            return L("clip.imageCopied")
        }
        let line = content.components(separatedBy: .newlines).first ?? content
        let maxLen = 55
        if line.count > maxLen {
            return String(line.prefix(maxLen)).trimmingCharacters(in: .whitespaces) + "…"
        }
        return line.trimmingCharacters(in: .whitespaces)
    }

    var toastPreviewFourLines: String {
        if type == .image {
            return L("clip.imageCopied")
        }
        let lines = content.components(separatedBy: .newlines)
        let maxLines = 4
        let maxPerLine = 60
        let taken = Array(lines.prefix(maxLines))
        return taken.map { line in
            let t = line.trimmingCharacters(in: .whitespaces)
            if t.count > maxPerLine {
                return String(t.prefix(maxPerLine)) + "…"
            }
            return t
        }.joined(separator: "\n")
    }

    // MARK: - Hashable
    static func == (lhs: ClipItem, rhs: ClipItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
