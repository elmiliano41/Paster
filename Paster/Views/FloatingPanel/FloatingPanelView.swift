import SwiftUI

struct FloatingPanelView: View {
    @Environment(DataStore.self) private var dataStore
    @Environment(ClipboardMonitor.self) private var clipboardMonitor

    @State private var searchText = ""
    @State private var selectedItemID: UUID?
    @State private var selectedTypeFilter: ClipItemType?
    @State private var showingDetail = true

    @FocusState private var isSearchFocused: Bool

    private var selectedItem: ClipItem? {
        guard let id = selectedItemID else { return nil }
        return dataStore.clipItems.first { $0.id == id }
    }

    private var filteredItems: [ClipItem] {
        dataStore.filteredItems(
            searchText: searchText,
            typeFilter: selectedTypeFilter
        )
    }

    private var pinnedItems: [ClipItem] {
        filteredItems.filter { $0.isPinned }
    }

    private var unpinnedItems: [ClipItem] {
        filteredItems.filter { !$0.isPinned }
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar
            Divider()
            filterChips

            HStack(spacing: 0) {
                clipList
                    .frame(minWidth: 280)

                if showingDetail {
                    Divider()
                    detailPanel
                        .frame(minWidth: 260, idealWidth: 320)
                }
            }
        }
        .background(.ultraThinMaterial)
        .onAppear {
            isSearchFocused = true
        }
        .onExitCommand {
            NSApp.windows.first { $0.title == "Paster" }?.orderOut(nil)
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)

                TextField(L("search.placeholder"), text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14))
                    .focused($isSearchFocused)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(10)
            .background(Color.secondary.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Button {
                withAnimation(.spring(response: 0.3)) {
                    showingDetail.toggle()
                }
            } label: {
                Image(systemName: showingDetail ? "sidebar.trailing" : "sidebar.leading")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help(showingDetail ? L("panel.hidePreview") : L("panel.showPreview"))

            Text("\(filteredItems.count)")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.08))
                .clipShape(Capsule())
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                FilterChip(
                    title: L("filter.all"),
                    icon: "tray.full",
                    isSelected: selectedTypeFilter == nil
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTypeFilter = nil
                    }
                }

                ForEach(ClipItemType.allCases) { type in
                    let count = dataStore.clipItems.filter { $0.type == type }.count
                    if count > 0 {
                        FilterChip(
                            title: type.displayName,
                            icon: type.iconName,
                            count: count,
                            isSelected: selectedTypeFilter == type
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTypeFilter = selectedTypeFilter == type ? nil : type
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Clip List

    private var clipList: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                if !pinnedItems.isEmpty {
                    sectionLabel(L("section.pinned"), icon: "pin.fill")
                    ForEach(pinnedItems) { item in
                        clipRow(item)
                    }
                }

                if !unpinnedItems.isEmpty {
                    if !pinnedItems.isEmpty {
                        sectionLabel(L("section.recent"), icon: "clock")
                    }
                    ForEach(unpinnedItems) { item in
                        clipRow(item)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
    }

    private func sectionLabel(_ title: String, icon: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .semibold))
            Text(title)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
            Spacer()
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 2)
    }

    private func clipRow(_ item: ClipItem) -> some View {
        HStack(spacing: 10) {
            ClipItemRow(item: item, category: dataStore.category(for: item))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(selectedItemID == item.id ? Color.accentColor.opacity(0.12) : Color.clear)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedItemID = item.id
            }
        }
        .simultaneousGesture(
            TapGesture(count: 2).onEnded {
                PasteService.copyToClipboard(item)
            }
        )
        .contextMenu { itemContextMenu(item) }
    }

    // MARK: - Detail Panel

    private var detailPanel: some View {
        Group {
            if let item = selectedItem {
                ClipItemDetail(item: item)
                    .environment(dataStore)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "cursorarrow.click.2")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.secondary.opacity(0.3))
                    Text(L("panel.selectItem"))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                    Text(L("panel.toPreview"))
                        .font(.system(size: 12))
                        .foregroundStyle(Color.secondary.opacity(0.5))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(.ultraThinMaterial)
    }

    // MARK: - Context Menu

    @ViewBuilder
    private func itemContextMenu(_ item: ClipItem) -> some View {
        Button {
            PasteService.copyToClipboard(item)
        } label: {
            Label(L("action.copy"), systemImage: "doc.on.doc")
        }

        Button {
            PasteService.copyAndPaste(item)
        } label: {
            Label(L("action.copyAndPaste"), systemImage: "doc.on.clipboard")
        }

        Divider()

        Button {
            withAnimation { dataStore.togglePin(item) }
        } label: {
            Label(
                item.isPinned ? L("action.unpin") : L("action.pin"),
                systemImage: item.isPinned ? "pin.slash" : "pin"
            )
        }

        Divider()

        Button(role: .destructive) {
            withAnimation {
                dataStore.deleteClipItem(item)
                if selectedItemID == item.id {
                    selectedItemID = nil
                }
            }
        } label: {
            Label(L("action.delete"), systemImage: "trash")
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let icon: String
    var count: Int? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .medium))
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                if let count {
                    Text("\(count)")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(isSelected ? Color.white.opacity(0.8) : Color.secondary.opacity(0.4))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(isSelected ? Color.accentColor : Color.clear)
            .foregroundStyle(isSelected ? .white : .secondary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.secondary.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title)\(count.map { ", \($0) elementos" } ?? "")")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
