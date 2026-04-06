import SwiftUI

struct CatAvatarView: View {
    let photoData: Data?
    let name: String
    var size: CGFloat = 60

    var body: some View {
        Group {
            if let photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Text(initialCharacter)
                    .font(.system(size: size * 0.4, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.accentColor.opacity(0.7))
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    // MARK: - Helpers

    private var initialCharacter: String {
        guard let first = name.first else { return "🐱" }
        return String(first)
    }
}
