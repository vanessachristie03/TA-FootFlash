import SwiftUI
import SwiftData
import Observation


@Model
class User {
    @Attribute(.unique) var userId: UUID
    var firstName: String
    var lastName: String

    init(userId: UUID = UUID(), firstName: String, lastName: String) {
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
    }
}
