import Foundation
import SwiftData

@Model
class CatProfile {
    var id: UUID
    var name: String
    var photoData: Data?

    init(
        id: UUID = UUID(),
        name: String,
        photoData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.photoData = photoData
    }
}
