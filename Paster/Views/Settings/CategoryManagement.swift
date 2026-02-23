import SwiftUI

struct CategoryManagement: View {
    @Environment(DataStore.self) private var dataStore

    @State private var isAddingNew = false
    @State private var newName = ""
    @State private var newColorHex = "#007AFF"
    @State private var newIcon = "tag"

    private let availableIcons = [
        "tag", "folder", "star", "heart", "bolt", "flame",
        "bookmark", "flag", "bell", "pin", "doc.text",
        "chevron.left.forwardslash.chevron.right", "link",
        "photo", "briefcase", "person", "gear", "terminal",
        "globe", "cloud", "lock", "key", "cpu"
    ]

    private let availableColors = [
        "#007AFF", "#34C759", "#FF9500", "#FF3B30",
        "#AF52DE", "#FF2D55", "#5856D6", "#00C7BE",
        "#FF6482", "#30B0C7", "#A2845E", "#8E8E93"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Categorías")
                    .font(.system(size: 14, weight: .bold))

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.3)) {
                        isAddingNew.toggle()
                        if !isAddingNew { resetForm() }
                    }
                } label: {
                    Label(
                        isAddingNew ? "Cancelar" : "Nueva",
                        systemImage: isAddingNew ? "xmark" : "plus"
                    )
                    .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }

            if isAddingNew {
                addCategoryForm
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            if dataStore.categories.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tag.slash")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.secondary.opacity(0.3))
                    Text("Sin categorías")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                    Text("Crea categorías para organizar tu historial")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.secondary.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                LazyVStack(spacing: 4) {
                    ForEach(dataStore.categories) { category in
                        categoryRow(category)
                    }
                }
            }
        }
        .padding(16)
    }

    // MARK: - Add Category Form

    private var addCategoryForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Nombre de la categoría", text: $newName)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 13))

            VStack(alignment: .leading, spacing: 6) {
                Text("Icono")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button {
                                newIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.system(size: 14))
                                    .frame(width: 30, height: 30)
                                    .background(newIcon == icon ? Color.accentColor : Color.secondary.opacity(0.12))
                                    .foregroundStyle(newIcon == icon ? .white : .primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Color")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)

                HStack(spacing: 6) {
                    ForEach(availableColors, id: \.self) { colorHex in
                        Button {
                            newColorHex = colorHex
                        } label: {
                            Circle()
                                .fill(Color(hex: colorHex))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Circle()
                                        .stroke(.white, lineWidth: newColorHex == colorHex ? 2 : 0)
                                        .shadow(radius: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Button {
                saveCategory()
            } label: {
                Text("Guardar categoría")
                    .font(.system(size: 12, weight: .medium))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(12)
        .background(Color.secondary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Category Row

    private func categoryRow(_ category: Category) -> some View {
        HStack(spacing: 10) {
            Image(systemName: category.icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(category.color)
                .frame(width: 28, height: 28)
                .background(category.color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 1) {
                Text(category.name)
                    .font(.system(size: 13, weight: .medium))
                Text("\(dataStore.itemCount(for: category)) elementos")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                withAnimation(.easeOut(duration: 0.2)) {
                    dataStore.deleteCategory(category)
                }
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 11))
                    .foregroundStyle(.red.opacity(0.6))
            }
            .buttonStyle(.plain)
            .help("Eliminar categoría")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.04))
        )
    }

    // MARK: - Actions

    private func saveCategory() {
        let trimmedName = newName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        let category = Category(
            name: trimmedName,
            colorHex: newColorHex,
            icon: newIcon
        )
        dataStore.addCategory(category)

        withAnimation(.spring(response: 0.3)) {
            isAddingNew = false
            resetForm()
        }
    }

    private func resetForm() {
        newName = ""
        newColorHex = "#007AFF"
        newIcon = "tag"
    }
}
