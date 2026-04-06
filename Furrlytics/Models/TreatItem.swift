import Foundation
import SwiftData

@Model
class TreatItem {
    var id: UUID
    var name: String
    var photoData: Data?
    var productLink: String?
    var catId: UUID?

    init(
        id: UUID = UUID(),
        name: String,
        photoData: Data? = nil,
        productLink: String? = nil,
        catId: UUID? = nil
    ) {
        self.id = id
        self.name = name
        self.photoData = photoData
        self.productLink = productLink
        self.catId = catId
    }
}
