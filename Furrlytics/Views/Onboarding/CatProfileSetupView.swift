import SwiftUI
import PhotosUI

struct CatProfileSetupView: View {
    @State private var catCount = 1
    @State private var catNames: [String] = [""]
    @State private var catPhotoItems: [PhotosPickerItem?] = [nil]
    @State private var catPhotoData: [Data?] = [nil]

    let onComplete: ([CatProfile]) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                catCountStepper
                catFieldsList
                continueButton
            }
            .padding()
        }
        .navigationTitle("添加猫咪")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "cat.fill")
                .font(.system(size: 60))
                .foregroundStyle(.tint)
            Text("告诉我们关于你的猫咪")
                .font(.headline)
        }
        .padding(.top, 20)
    }

    private var catCountStepper: some View {
        Stepper("猫咪数量: \(catCount)", value: $catCount, in: 1...6)
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            .onChange(of: catCount) { _, newCount in
                resizeArrays(to: newCount)
            }
    }

    private var catFieldsList: some View {
        VStack(spacing: 16) {
            ForEach(0..<catCount, id: \.self) { index in
                catRow(at: index)
            }
        }
    }

    private func catRow(at index: Int) -> some View {
        HStack(spacing: 16) {
            photoPicker(at: index)
            TextField("猫咪名字", text: binding(for: index))
                .textFieldStyle(.roundedBorder)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func photoPicker(at index: Int) -> some View {
        PhotosPicker(selection: photoBinding(for: index), matching: .images) {
            CatAvatarView(
                photoData: catPhotoData[index],
                name: catNames[index],
                size: 60
            )
        }
        .onChange(of: catPhotoItems[index]) { _, newItem in
            guard let newItem else { return }
            loadPhoto(from: newItem, at: index)
        }
    }

    private var continueButton: some View {
        Button {
            onComplete(buildCatProfiles())
        } label: {
            Text("继续")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(canContinue ? Color.accentColor : Color.gray.opacity(0.3))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!canContinue)
        .padding(.top, 8)
    }

    // MARK: - Computed

    private var canContinue: Bool {
        catNames.prefix(catCount).allSatisfy { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    // MARK: - Actions

    private func resizeArrays(to newCount: Int) {
        while catNames.count < newCount {
            catNames.append("")
            catPhotoItems.append(nil)
            catPhotoData.append(nil)
        }
        while catNames.count > newCount {
            catNames.removeLast()
            catPhotoItems.removeLast()
            catPhotoData.removeLast()
        }
    }

    private func loadPhoto(from item: PhotosPickerItem, at index: Int) {
        Task {
            guard let data = try? await item.loadTransferable(type: Data.self) else { return }
            let compressed = compressPhoto(data)
            await MainActor.run {
                catPhotoData[index] = compressed
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

    private func buildCatProfiles() -> [CatProfile] {
        (0..<catCount).map { index in
            CatProfile(
                name: catNames[index].trimmingCharacters(in: .whitespaces),
                photoData: catPhotoData[index]
            )
        }
    }

    // MARK: - Binding Helpers

    private func binding(for index: Int) -> Binding<String> {
        Binding(
            get: { catNames[index] },
            set: { catNames[index] = $0 }
        )
    }

    private func photoBinding(for index: Int) -> Binding<PhotosPickerItem?> {
        Binding(
            get: { catPhotoItems[index] },
            set: { catPhotoItems[index] = $0 }
        )
    }
}
