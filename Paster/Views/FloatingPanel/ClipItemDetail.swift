import SwiftUI

struct ClipItemDetail: View {
    let item: ClipItem
    @Environment(DataStore.self) private var dataStore

    var body: some View {
        VStack(spacing: 0) {
            detailHeader
            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    contentView
                    metadataView
                }
                .padding(16)
            }

            Divider()
            detailActions
        }
    }

    // MARK: - Header

    private var detailHeader: some View {
        HStack(spacing: 10) {
            ClipTypeIcon(type: item.type, size: 16)

            VStack(alignment: .leading, spacing: 1) {
                Text(item.type.displayName)
                    .font(.system(size: 13, weight: .semibold))
                TimeAgoLabel(date: item.timestamp)
            }

            Spacer()

            Button {
                withAnimation(.spring(response: 0.3)) {
                    dataStore.togglePin(item)
                }
            } label: {
                Image(systemName: item.isPinned ? "pin.fill" : "pin")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(item.isPinned ? .orange : .secondary)
            }
            .buttonStyle(.plain)
            .help(item.isPinned ? "Desfijar" : "Fijar")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Content View

    @ViewBuilder
    private var contentView: some View {
        switch item.type {
        case .image:
            ImagePreview(imageData: item.imageData)
        case .code:
            CodePreview(code: item.content, language: item.detectedLanguage)
        case .link:
            LinkPreview(urlString: item.content)
        default:
            TextPreview(text: item.content)
        }
    }

    // MARK: - Metadata

    private var metadataView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Información")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)

            VStack(spacing: 6) {
                metadataRow("Tipo", value: item.type.displayName)
                metadataRow("Tamaño", value: contentSize)
                metadataRow("Fecha", value: item.timestamp.formatted(date: .abbreviated, time: .shortened))

                if let lang = item.detectedLanguage {
                    metadataRow("Lenguaje", value: lang)
                }

                if let app = item.sourceApp {
                    metadataRow("Origen", value: appName(from: app))
                }

                // Category picker
                HStack {
                    Text("Categoría")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .frame(width: 80, alignment: .leading)

                    Picker("", selection: Binding(
                        get: { item.categoryId },
                        set: { newId in
                            dataStore.setCategory(newId, for: item)
                        }
                    )) {
                        Text("Sin categoría").tag(nil as UUID?)
                        ForEach(dataStore.categories) { category in
                            Label(category.name, systemImage: category.icon)
                                .tag(category.id as UUID?)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .font(.system(size: 11))
                }
            }
            .padding(12)
            .background(Color.secondary.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private func metadataRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .frame(width: 80, alignment: .leading)
            Text(value)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.primary)
            Spacer()
        }
    }

    // MARK: - Actions

    private var detailActions: some View {
        HStack(spacing: 10) {
            Button {
                PasteService.copyToClipboard(item)
            } label: {
                Label("Copiar", systemImage: "doc.on.doc")
                    .font(.system(size: 12, weight: .medium))
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .keyboardShortcut(.return, modifiers: .command)

            Button {
                PasteService.copyAndPaste(item)
            } label: {
                Label("Pegar", systemImage: "doc.on.clipboard")
                    .font(.system(size: 12, weight: .medium))
            }
            .buttonStyle(.bordered)
            .controlSize(.small)

            Spacer()

            Button(role: .destructive) {
                withAnimation {
                    dataStore.deleteClipItem(item)
                }
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 12))
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Helpers

    private var contentSize: String {
        if let imageData = item.imageData {
            return ByteCountFormatter.string(fromByteCount: Int64(imageData.count), countStyle: .file)
        }
        let bytes = item.content.utf8.count
        if bytes < 1024 {
            return "\(bytes) bytes"
        }
        return ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .file)
    }

    private func appName(from bundleId: String) -> String {
        bundleId.components(separatedBy: ".").last ?? bundleId
    }
}
