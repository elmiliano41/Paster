import SwiftUI

struct ClipItemRow: View {
    let item: ClipItem
    let category: Category?

    var body: some View {
        HStack(spacing: 10) {
            typeIndicator

            VStack(alignment: .leading, spacing: 3) {
                contentPreview

                HStack(spacing: 6) {
                    TimeAgoLabel(date: item.timestamp)

                    if item.type == .code, let lang = item.detectedLanguage {
                        languageBadge(lang)
                    }

                    if let category {
                        CategoryBadge(category: category)
                    }

                    if let app = item.sourceApp {
                        appBadge(app)
                    }
                }
            }

            Spacer()

            if item.isPinned {
                Image(systemName: "pin.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.type.displayName): \(item.firstLine)")
        .accessibilityHint(L("clip.doubleClickToCopy"))
    }

    // MARK: - Type Indicator

    private var typeIndicator: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(typeColor.opacity(0.1))
                .frame(width: 32, height: 32)

            if item.type == .image, let imageData = item.imageData,
               let nsImage = NSImage(data: imageData) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: item.type.iconName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(typeColor)
            }
        }
    }

    // MARK: - Content Preview

    @ViewBuilder
    private var contentPreview: some View {
        switch item.type {
        case .image:
            Text(L("clip.imageCopied"))
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        case .code:
            Text(item.firstLine)
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .lineLimit(1)
                .foregroundStyle(.primary)
        case .link:
            Text(item.content)
                .font(.system(size: 12, weight: .regular))
                .lineLimit(1)
                .foregroundStyle(.blue)
                .underline()
        default:
            Text(item.firstLine)
                .font(.system(size: 12, weight: .regular))
                .lineLimit(1)
                .foregroundStyle(.primary)
        }
    }

    // MARK: - Badges

    private func languageBadge(_ lang: String) -> some View {
        Text(lang)
            .font(.system(size: 9, weight: .semibold, design: .monospaced))
            .padding(.horizontal, 5)
            .padding(.vertical, 1)
            .background(.green.opacity(0.1))
            .foregroundStyle(.green)
            .clipShape(Capsule())
    }

    private func appBadge(_ bundleId: String) -> some View {
        let appName = bundleId.components(separatedBy: ".").last ?? bundleId
        return Text(appName)
            .font(.system(size: 9, weight: .medium))
            .foregroundStyle(Color.secondary.opacity(0.4))
    }

    // MARK: - Helpers

    private var typeColor: Color {
        switch item.type {
        case .text: .secondary
        case .code: .green
        case .image: .blue
        case .link: .purple
        case .file: .orange
        case .richText: .pink
        }
    }
}
