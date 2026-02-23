import SwiftUI
import AppKit

struct CodePreview: View {
    let code: String
    let language: String?
    @State private var isExpanded = false
    @Environment(\.colorScheme) private var colorScheme

    private var lines: [String] {
        code.components(separatedBy: .newlines)
    }

    private var displayLines: [String] {
        if isExpanded { return lines }
        return Array(lines.prefix(AppConstants.maxPreviewLines * 2))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                if let language {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left.forwardslash.chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                        Text(language.capitalized)
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.green.opacity(0.12))
                    .foregroundStyle(.green)
                    .clipShape(Capsule())
                }

                Label("\(lines.count) líneas", systemImage: "text.alignleft")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    PasteService.copyString(code)
                } label: {
                    Label("Copiar", systemImage: "doc.on.doc")
                        .font(.system(size: 10, weight: .medium))
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.accentColor)

                if lines.count > AppConstants.maxPreviewLines * 2 {
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        Text(isExpanded ? "Colapsar" : "Expandir")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.accentColor)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(displayLines.enumerated()), id: \.offset) { index, line in
                        HStack(alignment: .top, spacing: 0) {
                            Text("\(index + 1)")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(.tertiary)
                                .frame(width: 36, alignment: .trailing)
                                .padding(.trailing, 12)

                            Rectangle()
                                .fill(.quaternary)
                                .frame(width: 1)
                                .padding(.trailing, 12)

                            highlightedLine(line)
                        }
                        .padding(.vertical, 1)
                    }

                    if !isExpanded && lines.count > AppConstants.maxPreviewLines * 2 {
                        HStack(spacing: 0) {
                            Text("…")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(.tertiary)
                                .frame(width: 36, alignment: .trailing)
                                .padding(.trailing, 12)

                            Rectangle()
                                .fill(.quaternary)
                                .frame(width: 1)
                                .padding(.trailing, 12)

                            Text("(\(lines.count - AppConstants.maxPreviewLines * 2) líneas más)")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .padding(12)
            }
            .background(codeBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.quaternary, lineWidth: 1)
            )
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Vista previa de código \(language ?? ""), \(lines.count) líneas")
    }

    // MARK: - Syntax Highlighting (basic)

    private func highlightedLine(_ line: String) -> some View {
        let attributed = basicHighlight(line)
        return Text(attributed)
            .font(.system(size: 12, design: .monospaced))
            .textSelection(.enabled)
    }

    private func basicHighlight(_ line: String) -> AttributedString {
        var result = AttributedString(line)

        let keywords = ["func", "let", "var", "if", "else", "for", "while", "return",
                        "import", "class", "struct", "enum", "protocol", "switch",
                        "case", "guard", "do", "try", "catch", "throw", "throws",
                        "def", "const", "function", "async", "await", "export",
                        "public", "private", "static", "final", "override",
                        "true", "false", "nil", "null", "undefined", "self", "Self",
                        "print", "int", "string", "bool", "float", "double",
                        "new", "delete", "this", "super", "extends", "implements"]

        let keywordColor: Color = colorScheme == .dark
            ? Color(red: 0.988, green: 0.376, blue: 0.639)
            : Color(red: 0.686, green: 0.212, blue: 0.463)

        let commentColor: Color = .secondary

        let lineStr = line

        if lineStr.trimmingCharacters(in: .whitespaces).hasPrefix("//") ||
           lineStr.trimmingCharacters(in: .whitespaces).hasPrefix("#") {
            result.foregroundColor = commentColor
            return result
        }

        var inString = false
        var stringChar: Character = "\""
        for (i, char) in lineStr.enumerated() {
            if !inString && (char == "\"" || char == "'") {
                inString = true
                stringChar = char
                if let range = result.range(of: String(lineStr.dropFirst(i)), options: .literal) {
                    _ = range
                }
            } else if inString && char == stringChar {
                inString = false
            }
        }

        for keyword in keywords {
            let pattern = "\\b\(keyword)\\b"
            if let regex = try? Regex(pattern) {
                for match in line.matches(of: regex) {
                    let matchStr = String(line[match.range])
                    if let range = result.range(of: matchStr, options: .literal) {
                        result[range].foregroundColor = keywordColor
                    }
                }
            }
        }

        if let numberRegex = try? Regex("\\b\\d+\\.?\\d*\\b") {
            for match in line.matches(of: numberRegex) {
                let matchStr = String(line[match.range])
                if let range = result.range(of: matchStr, options: .literal) {
                    result[range].foregroundColor = .blue
                }
            }
        }

        return result
    }

    private var codeBackground: Color {
        colorScheme == .dark
            ? Color(red: 0.1, green: 0.1, blue: 0.12)
            : Color(red: 0.97, green: 0.97, blue: 0.98)
    }
}
