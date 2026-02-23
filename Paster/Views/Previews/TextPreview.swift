import SwiftUI

struct TextPreview: View {
    let text: String
    @State private var isExpanded = false

    private var displayText: String {
        if isExpanded { return text }
        let lines = text.components(separatedBy: .newlines)
        if lines.count > AppConstants.maxPreviewLines {
            return lines.prefix(AppConstants.maxPreviewLines).joined(separator: "\n") + "\n…"
        }
        return text
    }

    private var lineCount: Int {
        text.components(separatedBy: .newlines).count
    }

    private var charCount: Int {
        text.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Label("\(lineCount) líneas", systemImage: "text.alignleft")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)

                Label("\(charCount) caracteres", systemImage: "character.cursor.ibeam")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)

                Spacer()

                if lineCount > AppConstants.maxPreviewLines {
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

            Text(displayText)
                .font(.system(size: 13, weight: .regular))
                .lineSpacing(3)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.secondary.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Vista previa de texto, \(lineCount) líneas")
    }
}
