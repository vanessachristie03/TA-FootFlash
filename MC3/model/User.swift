import SwiftUI
import SwiftData
import Observation

@Model
class User {
    var id : UUID = UUID.init()
    var firstName: String
    var lastName: String
    var email: String
    var weight: String
    var height: String
    
    init(firstName: String, lastName: String, email: String, weight: String, height: String) {
        self.id = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.weight = weight
        self.height = height
    }
    
    
}
