import SwiftUI
import SwiftData
import Firebase
import FirebaseFirestore
import FirebaseAuth


struct ProfileView: View {
    @State private var isEditProfilePresented = false
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedUser: User?
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var leaderboardUsers: [(firstName: String, lastName: String)] = []
    @State private var users: [User] = []

    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    Rectangle()
                        .frame(height: 170)
                        .foregroundColor(.black)
                }
                .clipped()
                
                ZStack(alignment: .top) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(firstName)  \(lastName)")
                                .bold()
                                .font(.system(size: 37))
                                .font(.title)
                            
                            Button(action: {
                                isEditProfilePresented = true
                            }) {
                                Text("Edit Profile")
                                    .font(.system(size: 17))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color("Accent"))
                                    .cornerRadius(12)
                            }
                            .padding(.top)
                        }
                        Spacer()
                    }
                    .padding()
                }
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                    
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "trophy")
                            .font(.largeTitle)
                            .foregroundColor(Color("Accent"))
                        Spacer()
                    }
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
                    
                    VStack {
                                           ScrollView {
                                               VStack(alignment: .leading) {
                                                   Text("Leaderboard")
                                                       .bold()
                                                       .font(.system(size: 17))
                                                       .foregroundColor(Color("Text"))
                                                       .padding(.bottom, 5)
                                                   
                                                   ForEach(users, id: \.id) { user in
                                                             HStack {
                                                                 Text("\(user.firstName) \(user.lastName)")
                                                                     .font(.system(size: 17))
                                                                     .foregroundColor(Color("Text"))
                                                                 Spacer()
                                                             }
                                                             .padding(.horizontal)
                                                         }
                                               }
                                           }
                                       }
                                       .font(.title)
                                       .foregroundColor(.blue)
                    Spacer()
                }
                Spacer()
            }
            .onAppear {
                initializeUser()
                fetchUsersFromFirestore()
            }
            .onChange(of: users) { _ in
                initializeUser()
            }
            .sheet(isPresented: $isEditProfilePresented) {
                EditProfileView(firstName: $firstName, lastName: $lastName, onSave: updateUser)
                    .presentationDetents([.fraction(0.3)])
            }
        }
        .navigationBarTitle("Profile", displayMode: .inline)
        .foregroundColor(Color("Text"))
    }
    private func fetchUsersFromFirestore() {
        let db = Firestore.firestore()
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("🔥 Error fetching users: \(error.localizedDescription)")
                return
            }
            
            if let documents = snapshot?.documents {
                self.users = documents.compactMap { doc in
                    let data = doc.data()
                    return User(
                        userId: UUID(uuidString: doc.documentID) ?? UUID(),
                        firstName: data["firstName"] as? String ?? "No First Name",
                        lastName: data["lastName"] as? String ?? "No Last Name"
                    )
                }
            }
        }
    }

    private func saveUserIDToDefaults(_ userID: String) {
        UserDefaults.standard.set(userID, forKey: "userID")
    }

    private func getUserIDFromDefaults() -> String? {
        return UserDefaults.standard.string(forKey: "userID")
    }
    private func updateUser() {
        let db = Firestore.firestore()
        let userID = getOrCreateUserID()

        let userRef = db.collection("users").document(userID)
        let updatedData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName
        ]

        userRef.setData(updatedData, merge: true) { error in
            if let error = error {
                print("🔥 Error updating Firestore: \(error.localizedDescription)")
            } else {
                print("✅ User data updated in Firestore")
                selectedUser?.firstName = firstName
                selectedUser?.lastName = lastName
            }
        }
    }


    private func initializeUser() {
        let db = Firestore.firestore()
        let userID = getOrCreateUserID()

        let userRef = db.collection("users").document(userID)
        userRef.getDocument { document, error in
            if let document = document, document.exists, let data = document.data() {
                self.selectedUser = User(
                    userId: UUID(uuidString: userID) ?? UUID(),
                    firstName: data["firstName"] as? String ?? "No First Name",
                    lastName: data["lastName"] as? String ?? "No Last Name"
                )
                self.firstName = self.selectedUser?.firstName ?? ""
                self.lastName = self.selectedUser?.lastName ?? ""
                print("✅ User ditemukan dan diupdate dari Firestore.")
            } else {
                print("⚠️ User tidak ditemukan di Firestore, membuat user baru...")
                createNewUser(userID: userID)
            }
        }
    }

    private func createNewUser(userID: String) {
        let db = Firestore.firestore()
        
        let newUser = [
            "firstName": firstName,
            "lastName": lastName
        ]

        db.collection("users").document(userID).setData(newUser) { error in
            if let error = error {
                print("🔥 Error creating new user: \(error.localizedDescription)")
            } else {
                print("✅ New user created with ID: \(userID)")
                self.selectedUser = User(userId: UUID(uuidString: userID) ?? UUID(), firstName: firstName, lastName: lastName)
            }
        }
    }

    private func getOrCreateUserID() -> String {
        if let storedUserID = UserDefaults.standard.string(forKey: "userID") {
            return storedUserID
        } else {
            let newUserID = UUID().uuidString
            UserDefaults.standard.set(newUserID, forKey: "userID")
            return newUserID
        }
    }


}

struct EditProfileView: View {
    @Binding var firstName: String
    @Binding var lastName: String
    var onSave: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                TextField("First Name", text: $firstName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Last Name", text: $lastName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Save") {
                    onSave()
                    dismiss()
                }
                .font(.system(size: 17))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color("Accent"))
                .cornerRadius(12)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Edit Profile")
            
            .navigationBarTitleDisplayMode(.inline)

        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
