import SwiftUI
import AppKit

// MARK: - Color from Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 122, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Date Formatting

extension Date {
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.locale = Locale(identifier: "es")
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    var timeAgoFull: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale(identifier: "es")
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

// MARK: - NSImage to Data

extension NSImage {
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else {
            return nil
        }
        return bitmapImage.representation(using: .png, properties: [:])
    }

    func resized(to maxSize: CGFloat) -> NSImage {
        let ratio = min(maxSize / size.width, maxSize / size.height)
        if ratio >= 1 { return self }
        let newSize = NSSize(
            width: size.width * ratio,
            height: size.height * ratio
        )
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        draw(
            in: NSRect(origin: .zero, size: newSize),
            from: NSRect(origin: .zero, size: size),
            operation: .sourceOver,
            fraction: 1.0
        )
        newImage.unlockFocus()
        return newImage
    }
}

// MARK: - String URL Detection

extension String {
    var isURL: Bool {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let range = NSRange(startIndex..., in: self)
        let matches = detector?.matches(in: self, options: [], range: range)
        guard let match = matches?.first else { return false }
        return match.range.length == self.utf16.count
    }

    var isLikelyCode: Bool {
        let codeIndicators = [
            "func ", "class ", "struct ", "enum ", "import ",
            "def ", "return ", "if ", "for ", "while ",
            "const ", "let ", "var ", "function ",
            "public ", "private ", "static ",
            "->", "=>", "===", "!==",
            "{", "}", "();", "[]",
            "#include", "#import", "#define",
            "package ", "interface ",
        ]
        let lines = components(separatedBy: .newlines)
        guard lines.count >= 2 else { return false }
        var score = 0
        let fullText = self.lowercased()
        for indicator in codeIndicators {
            if fullText.contains(indicator.lowercased()) {
                score += 1
            }
        }
        let indentedLines = lines.filter { $0.hasPrefix("  ") || $0.hasPrefix("\t") }
        if indentedLines.count > lines.count / 3 {
            score += 2
        }
        return score >= 3
    }
}

// MARK: - View Helpers

extension View {
    func cardStyle() -> some View {
        self
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.smallCornerRadius))
    }
}
