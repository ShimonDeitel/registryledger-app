import Foundation

struct RegistryLedgerEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var createdAt: Date = Date()
    var giverName: String
    var thankYouSent: Bool
    var notes: String

    init(id: UUID = UUID(), createdAt: Date = Date(), giverName: String = "", thankYouSent: Bool = false, notes: String = "") {
        self.id = id
        self.createdAt = createdAt
        self.giverName = giverName
        self.thankYouSent = thankYouSent
        self.notes = notes
    }
}
