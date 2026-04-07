import SwiftUI
import SwiftData

struct RecordPlayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var catProfiles: [CatProfile]

    @State private var selectedCatId: UUID?
    @State private var durationMinutes: Int = 15

    private let durationOptions = [5, 10, 15, 20, 30, 45, 60]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if catProfiles.count > 1 {
                    catSelectionRow
                }

                durationPicker

                Spacer()

                saveButton
            }
            .padding()
            .navigationTitle("记录玩耍")
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

    private var durationPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("玩耍时长")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                ForEach(durationOptions, id: \.self) { minutes in
                    Button {
                        durationMinutes = minutes
                    } label: {
                        Text("\(minutes)分钟")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .foregroundStyle(durationMinutes == minutes ? .white : .primary)
                            .background(
                                durationMinutes == minutes ? Color.green : Color(.systemGray5),
                                in: RoundedRectangle(cornerRadius: 10)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var saveButton: some View {
        Button {
            savePlay()
        } label: {
            Text("完成")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .foregroundStyle(.white)
                .background(canSave ? Color.green : Color.gray, in: RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!canSave)
    }

    // MARK: - Actions

    private func autoSelectSingleCat() {
        if catProfiles.count == 1 {
            selectedCatId = catProfiles.first?.id
        }
    }

    private func savePlay() {
        guard let selectedCatId else { return }

        let event = CareEvent(
            eventType: .play,
            source: .manual,
            catId: selectedCatId,
            metadata: [
                PlayMetadataKey.durationMinutes: String(durationMinutes)
            ]
        )
        modelContext.insert(event)
        dismiss()
    }

    private var canSave: Bool {
        selectedCatId != nil
    }
}
