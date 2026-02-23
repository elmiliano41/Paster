import Foundation
import Observation

@Observable
final class DataStore {
    private(set) var clipItems: [ClipItem] = []
    private(set) var categories: [Category] = []

    private let clipItemsURL: URL
    private let categoriesURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!.appendingPathComponent("Paster", isDirectory: true)

        try? FileManager.default.createDirectory(
            at: appSupport,
            withIntermediateDirectories: true
        )

        clipItemsURL = appSupport.appendingPathComponent("clip_items.json")
        categoriesURL = appSupport.appendingPathComponent("categories.json")

        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        decoder.dateDecodingStrategy = .iso8601

        loadAll()
    }

    // MARK: - Load

    private func loadAll() {
        clipItems = load(from: clipItemsURL) ?? []
        categories = load(from: categoriesURL) ?? []
    }

    private func load<T: Decodable>(from url: URL) -> T? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }

    // MARK: - Save

    private func saveClipItems() {
        save(clipItems, to: clipItemsURL)
    }

    private func saveCategories() {
        save(categories, to: categoriesURL)
    }

    private func save<T: Encodable>(_ value: T, to url: URL) {
        guard let data = try? encoder.encode(value) else { return }
        try? data.write(to: url, options: .atomic)
    }

    // MARK: - ClipItem CRUD

    func addClipItem(_ item: ClipItem) {
        if let latest = clipItems.first, latest.content == item.content {
            return
        }

        clipItems.insert(item, at: 0)
        enforceMaxHistory()
        saveClipItems()
    }

    func deleteClipItem(_ item: ClipItem) {
        clipItems.removeAll { $0.id == item.id }
        saveClipItems()
    }

    func deleteClipItem(id: UUID) {
        clipItems.removeAll { $0.id == id }
        saveClipItems()
    }

    func togglePin(_ item: ClipItem) {
        if let index = clipItems.firstIndex(where: { $0.id == item.id }) {
            clipItems[index].isPinned.toggle()
            saveClipItems()
        }
    }

    func updateClipItem(_ item: ClipItem) {
        if let index = clipItems.firstIndex(where: { $0.id == item.id }) {
            clipItems[index] = item
            saveClipItems()
        }
    }

    func setCategory(_ categoryId: UUID?, for item: ClipItem) {
        if let index = clipItems.firstIndex(where: { $0.id == item.id }) {
            clipItems[index].categoryId = categoryId
            saveClipItems()
        }
    }

    func clearAllNonPinned() {
        clipItems.removeAll { !$0.isPinned }
        saveClipItems()
    }

    func clearAll() {
        clipItems.removeAll()
        saveClipItems()
    }

    // MARK: - Category CRUD

    func addCategory(_ category: Category) {
        categories.append(category)
        saveCategories()
    }

    func deleteCategory(_ category: Category) {
        // Remove category reference from items
        for i in clipItems.indices {
            if clipItems[i].categoryId == category.id {
                clipItems[i].categoryId = nil
            }
        }
        categories.removeAll { $0.id == category.id }
        saveCategories()
        saveClipItems()
    }

    func updateCategory(_ category: Category) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
            saveCategories()
        }
    }

    // MARK: - Queries

    func category(for item: ClipItem) -> Category? {
        guard let catId = item.categoryId else { return nil }
        return categories.first { $0.id == catId }
    }

    func itemCount(for category: Category) -> Int {
        clipItems.filter { $0.categoryId == category.id }.count
    }

    var pinnedItems: [ClipItem] {
        clipItems.filter { $0.isPinned }
    }

    var recentItems: [ClipItem] {
        clipItems.filter { !$0.isPinned }
    }

    func filteredItems(
        searchText: String = "",
        typeFilter: ClipItemType? = nil,
        categoryFilter: UUID? = nil
    ) -> [ClipItem] {
        var items = clipItems

        if let typeFilter {
            items = items.filter { $0.type == typeFilter }
        }

        if let categoryFilter {
            items = items.filter { $0.categoryId == categoryFilter }
        }

        if !searchText.isEmpty {
            items = items.filter {
                $0.content.localizedCaseInsensitiveContains(searchText) ||
                ($0.detectedLanguage?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                ($0.sourceApp?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }

        return items
    }

    // MARK: - Maintenance

    private func enforceMaxHistory() {
        let max = UserDefaults.standard.integer(forKey: AppConstants.Defaults.maxHistoryKey)
        let limit = max > 0 ? max : AppConstants.defaultMaxHistoryItems

        let unpinned = clipItems.filter { !$0.isPinned }
        if unpinned.count > limit {
            let idsToRemove = Set(unpinned.suffix(from: limit).map(\.id))
            clipItems.removeAll { idsToRemove.contains($0.id) }
        }
    }

    func performAutoCleanup() {
        let days = UserDefaults.standard.integer(forKey: AppConstants.Defaults.autoCleanupDays)
        guard days > 0 else { return }

        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        clipItems.removeAll { !$0.isPinned && $0.timestamp < cutoff }
        saveClipItems()
    }
}
