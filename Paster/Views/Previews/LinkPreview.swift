import SwiftUI
import LinkPresentation

struct LinkPreview: View {
    let urlString: String
    @State private var title: String?
    @State private var icon: NSImage?
    @State private var isLoading = true

    private var url: URL? {
        URL(string: urlString)
    }

    private var domain: String {
        url?.host ?? urlString
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "link")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.purple)

                Text(domain)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)

                Spacer()

                if let url {
                    Link(destination: url) {
                        Label("Abrir", systemImage: "arrow.up.right.square")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundStyle(Color.accentColor)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    if let icon {
                        Image(nsImage: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    } else {
                        Image(systemName: "globe")
                            .font(.system(size: 20))
                            .foregroundStyle(.purple.opacity(0.5))
                            .frame(width: 32, height: 32)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        if isLoading {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Text(title ?? domain)
                                .font(.system(size: 13, weight: .semibold))
                                .lineLimit(2)
                                .foregroundStyle(.primary)
                        }

                        Text(urlString)
                            .font(.system(size: 11))
                            .lineLimit(1)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.secondary.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.purple.opacity(0.15), lineWidth: 1)
            )
        }
        .task {
            await fetchMetadata()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Enlace a \(title ?? domain)")
    }

    private func fetchMetadata() async {
        guard let url else {
            isLoading = false
            return
        }

        let provider = LPMetadataProvider()
        do {
            let metadata = try await provider.startFetchingMetadata(for: url)
            await MainActor.run {
                title = metadata.title

                if let iconProvider = metadata.iconProvider {
                    iconProvider.loadObject(ofClass: NSImage.self) { image, _ in
                        DispatchQueue.main.async {
                            self.icon = image as? NSImage
                        }
                    }
                }

                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
            }
        }
    }
}
