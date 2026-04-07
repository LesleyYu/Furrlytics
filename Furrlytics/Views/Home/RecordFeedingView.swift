import SwiftUI
import SwiftData

struct RecordFeedingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var catProfiles: [CatProfile]

    @State private var selectedCatId: UUID?
    @State private var foodName: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if catProfiles.count > 1 {
                    catSelectionRow
                }

                foodNameInput

                Spacer()

                saveButton
            }
            .padding()
            .navigationTitle("记录湿粮")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
            .onAppear { autoSelectSingleCat() }
        }
    }

    // MARK: - Subviews

    private var catSelectionRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("选择猫咪")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(catProfiles) { cat in
                        CatSelectionItem(
                            cat: cat,
                            isSelected: selectedCatId == cat.id
                        ) {
                            selectedCatId = cat.id
                        }
                    }
                }
            }
        }
    }

    private var foodNameInput: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("食物描述")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField("例如：鸡肉罐头、三文鱼", text: $foodName)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.done)
        }
    }

    private var saveButton: some View {
        Button {
            saveFeeding()
        } label: {
            Text("完成")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .foregroundStyle(.white)
                .background(canSave ? Color.orange : Color.gray, in: RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!canSave)
    }

    // MARK: - Actions

    private func autoSelectSingleCat() {
        if catProfiles.count == 1 {
            selectedCatId = catProfiles.first?.id
        }
    }

    private func saveFeeding() {
        guard let selectedCatId else { return }

        var metadata: [String: String] = [
            FeedingMetadataKey.foodType: "wet"
        ]
        let trimmedName = foodName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty {
            metadata[FeedingMetadataKey.foodName] = trimmedName
        }

        let event = CareEvent(
            eventType: .feeding,
            source: .manual,
            catId: selectedCatId,
            metadata: metadata
        )
        modelContext.insert(event)
        dismiss()
    }

    private var canSave: Bool {
        selectedCatId != nil
    }
}

// MARK: - Cat Selection Item

struct CatSelectionItem: View {
    let cat: CatProfile
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                CatAvatarView(photoData: cat.photoData, name: cat.name, size: 50)
                    .overlay {
                        Circle()
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 3)
                    }
                Text(cat.name)
                    .font(.caption)
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
        }
        .buttonStyle(.plain)
    }
}
