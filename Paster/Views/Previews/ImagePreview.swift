import SwiftUI
import AppKit

struct ImagePreview: View {
    let imageData: Data?
    @State private var isExpanded = false

    private var nsImage: NSImage? {
        guard let data = imageData else { return nil }
        return NSImage(data: data)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: "photo")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.blue)

                if let image = nsImage {
                    Text("\(Int(image.size.width)) × \(Int(image.size.height))")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                if let data = imageData {
                    Text(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.3)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 10, weight: .medium))
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.accentColor)
            }

            if let image = nsImage {
                ZStack {
                    checkerboardPattern
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            maxWidth: isExpanded ? .infinity : AppConstants.maxImageThumbnailSize,
                            maxHeight: isExpanded ? .infinity : AppConstants.maxImageThumbnailSize
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.quaternary, lineWidth: 1)
                )
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "photo.badge.exclamationmark")
                        .font(.system(size: 32))
                        .foregroundStyle(.quaternary)
                    Text("No se pudo cargar la imagen")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .background(.quaternary.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Vista previa de imagen")
    }

    private var checkerboardPattern: some View {
        Canvas { context, size in
            let tileSize: CGFloat = 8
            let rows = Int(size.height / tileSize) + 1
            let cols = Int(size.width / tileSize) + 1

            for row in 0..<rows {
                for col in 0..<cols {
                    if (row + col) % 2 == 0 {
                        let rect = CGRect(
                            x: CGFloat(col) * tileSize,
                            y: CGFloat(row) * tileSize,
                            width: tileSize,
                            height: tileSize
                        )
                        context.fill(Path(rect), with: .color(.secondary.opacity(0.08)))
                    }
                }
            }
        }
    }
}
