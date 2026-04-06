import SwiftUI
import SwiftData
import PhotosUI

struct CatProfileSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query private var catProfiles: [CatProfile]

    @State private var showAddSheet = false
    @State private var editingCat: CatProfile?

    var body: some View {
        List {
            ForEach(catProfiles) { cat in
                catRow(cat)
                    .onTapGesture { editingCat = cat }
            }
            .onDelete(perform: deleteCats)

            Button {
                showAddSheet = true
            } label: {
                Label("添加猫咪", systemImage: "plus")
            }
        }
        .navigationTitle("猫咪管理")
        .sheet(isPresented: $showAddSheet) {
            AddCatSheet { newCat in
                modelContext.insert(newCat)
                if catProfiles.isEmpty {
                    appState.activeCatId = newCat.id
                }
            }
        }
        .sheet(item: $editingCat) { cat in
            EditCatSheet(cat: cat)
        }
    }

    // MARK: - Subviews

    private func catRow(_ cat: CatProfile) -> some View {
        HStack(spacing: 12) {
            CatAvatarView(photoData: cat.photoData, name: cat.name, size: 44)
            Text(cat.name)
                .font(.body)
            Spacer()
            if cat.id == appState.activeCatId {
                Text("当前")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Actions

    private func deleteCats(at offsets: IndexSet) {
        guard catProfiles.count - offsets.count >= 1 else { return }
        for index in offsets {
            modelContext.delete(catProfiles[index])
        }
    }
}

// MARK: - Add Cat Sheet

private struct AddCatSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var photoItem: PhotosPickerItem?
    @State private var photoData: Data?

    let onSave: (CatProfile) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $photoItem, matching: .images) {
                            CatAvatarView(photoData: photoData, name: name, size: 80)
                        }
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)

                Section {
                    TextField("猫咪名字", text: $name)
                }
            }
            .navigationTitle("添加猫咪")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let cat = CatProfile(name: name.trimmingCharacters(in: .whitespaces), photoData: photoData)
                        onSave(cat)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onChange(of: photoItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    guard let data = try? await newItem.loadTransferable(type: Data.self) else { return }
                    photoData = compressPhoto(data)
                }
            }
        }
    }

    private func compressPhoto(_ data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let maxDimension: CGFloat = 400
        let scale = min(maxDimension / image.size.width, maxDimension / image.size.height, 1.0)
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
        return resized.jpegData(compressionQuality: 0.7)
    }
}

// MARK: - Edit Cat Sheet

private struct EditCatSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Bindable var cat: CatProfile

    @State private var photoItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $photoItem, matching: .images) {
                            CatAvatarView(photoData: cat.photoData, name: cat.name, size: 80)
                        }
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)

                Section {
                    TextField("猫咪名字", text: $cat.name)
                }
            }
            .navigationTitle("编辑猫咪")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
            .onChange(of: photoItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    guard let data = try? await newItem.loadTransferable(type: Data.self) else { return }
                    cat.photoData = compressPhoto(data)
                }
            }
        }
    }

    private func compressPhoto(_ data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let maxDimension: CGFloat = 400
        let scale = min(maxDimension / image.size.width, maxDimension / image.size.height, 1.0)
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
        return resized.jpegData(compressionQuality: 0.7)
    }
}
