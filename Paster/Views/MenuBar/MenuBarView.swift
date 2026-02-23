import SwiftUI

struct MenuBarView: View {
    @Environment(DataStore.self) private var dataStore
    @Environment(ClipboardMonitor.self) private var clipboardMonitor
    @Environment(FloatingPanelManager.self) private var panelManager
    @Environment(\.openSettings) private var openSettings

    @State private var searchText = ""
    @State private var hoveredItemId: UUID?

    private var filteredItems: [ClipItem] {
        let items = dataStore.filteredItems(searchText: searchText)
        return Array(items.prefix(20))
    }

    private var pinnedItems: [ClipItem] {
        filteredItems.filter { $0.isPinned }
    }

    private var recentItems: [ClipItem] {
        filteredItems.filter { !$0.isPinned }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            searchBar

            if dataStore.clipItems.isEmpty {
                emptyState
            } else {
                clipList
            }

            Divider()
            footerView
        }
        .frame(
            width: AppConstants.UI.menuBarWidth,
            height: AppConstants.UI.menuBarHeight
        )
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Text("Paster")
                .font(.system(size: 14, weight: .bold, design: .rounded))

            Spacer()

            Text("\(dataStore.clipItems.count) elementos")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)

            TextField("Buscar en el historial…", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 13))

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Clip List

    private var clipList: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                if !pinnedItems.isEmpty {
                    sectionHeader("Fijados", icon: "pin.fill")
                    ForEach(pinnedItems) { item in
                        MenuBarClipRow(
                            item: item,
                            category: dataStore.category(for: item),
                            isHovered: hoveredItemId == item.id,
                            onCopy: { copyItem(item) },
                            onPin: { dataStore.togglePin(item) },
                            onDelete: { deleteItem(item) }
                        )
                        .onHover { isHovered in
                            hoveredItemId = isHovered ? item.id : nil
                        }
                    }
                }

                if !recentItems.isEmpty {
                    if !pinnedItems.isEmpty {
                        sectionHeader("Recientes", icon: "clock")
                    }
                    ForEach(recentItems) { item in
                        MenuBarClipRow(
                            item: item,
                            category: dataStore.category(for: item),
                            isHovered: hoveredItemId == item.id,
                            onCopy: { copyItem(item) },
                            onPin: { dataStore.togglePin(item) },
                            onDelete: { deleteItem(item) }
                        )
                        .onHover { isHovered in
                            hoveredItemId = isHovered ? item.id : nil
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "clipboard")
                .font(.system(size: 40))
                .foregroundStyle(Color.secondary.opacity(0.3))
            Text("Sin contenido aún")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
            Text("Copia algo y aparecerá aquí")
                .font(.system(size: 12))
                .foregroundStyle(Color.secondary.opacity(0.6))
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .accessibilityLabel("Historial vacío. Copia algo y aparecerá aquí.")
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack(spacing: 12) {
            Button {
                panelManager.show()
            } label: {
                Label("Abrir Paster", systemImage: "macwindow")
                    .font(.system(size: 12))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)

            Spacer()

            Button {
                dataStore.clearAllNonPinned()
            } label: {
                Label("Limpiar", systemImage: "trash")
                    .font(.system(size: 12))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)

            Button {
                openSettings()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 12))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Section Header

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .semibold))
            Text(title.uppercased())
                .font(.system(size: 10, weight: .semibold, design: .rounded))
            Spacer()
        }
        .foregroundStyle(Color.secondary.opacity(0.6))
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 2)
    }

    // MARK: - Actions

    private func copyItem(_ item: ClipItem) {
        PasteService.copyToClipboard(item)
    }

    private func deleteItem(_ item: ClipItem) {
        withAnimation(.easeOut(duration: 0.2)) {
            dataStore.deleteClipItem(item)
        }
    }
}

// MARK: - Menu Bar Clip Row

struct MenuBarClipRow: View {
    let item: ClipItem
    let category: Category?
    let isHovered: Bool
    let onCopy: () -> Void
    let onPin: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            // Type icon
            ClipTypeIcon(type: item.type, size: 14)
                .frame(width: 24, height: 24)
                .background(iconBackground)
                .clipShape(RoundedRectangle(cornerRadius: 6))

            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(item.firstLine)
                    .font(.system(size: 12, weight: .regular))
                    .lineLimit(1)
                    .foregroundStyle(.primary)

                HStack(spacing: 6) {
                    TimeAgoLabel(date: item.timestamp)
                    if let category {
                        CategoryBadge(category: category)
                    }
                    if item.type == .code, let lang = item.detectedLanguage {
                        Text(lang)
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(.green.opacity(0.1))
                            .foregroundStyle(.green)
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer()

            if isHovered {
                HStack(spacing: 4) {
                    Button {
                        onPin()
                    } label: {
                        Image(systemName: item.isPinned ? "pin.fill" : "pin")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(item.isPinned ? .orange : .secondary)
                    }
                    .buttonStyle(.plain)
                    .help(item.isPinned ? "Desfijar" : "Fijar")

                    Button {
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 11))
                            .foregroundStyle(.red.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                    .help("Eliminar")
                }
                .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHovered ? Color.accentColor.opacity(0.08) : .clear)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onCopy()
        }
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.type.displayName): \(item.firstLine)")
        .accessibilityHint("Haz clic para copiar")
    }

    private var iconBackground: Color {
        switch item.type {
        case .code: .green.opacity(0.1)
        case .image: .blue.opacity(0.1)
        case .link: .purple.opacity(0.1)
        case .file: .orange.opacity(0.1)
        default: Color.secondary.opacity(0.08)
        }
    }
}
