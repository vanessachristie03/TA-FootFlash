import SwiftUI
import UIKit
import SwiftData

struct ProfileView: View {
    @State private var isEditProfile = true
    @State private var text: String = ""
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \User.firstName, order: .forward, animation: .smooth) var users: [User]
    
    @State private var selectedUser: User?
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    
    
    @State private var isContent1Visible = true    

    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    ZStack{
                        Rectangle()
                            .frame(height: isEditProfile ? 170 : 160)
                            .animation(.bouncy)
                            .foregroundColor(.black)
                        ZStack{
                            Image("banner-circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: .infinity, height: 110)
                                .offset(x: isEditProfile ? 200 : 50,y: isEditProfile ? -30 : -50)
                                .animation(.easeInOut(duration: 0.5))
                            Image("banner-rectangle-2")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: .infinity, height: 55)
                                .offset(x: isEditProfile ? 120 : 50,y: isEditProfile ? 20 : -100)
                                .rotationEffect(.degrees(isEditProfile ? 0 : 80),anchor: .center)
                                .animation(.easeInOut(duration: 0.5))
                            
                            
                            
                            Image("banner-circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: .infinity, height: 110)
                                .offset(x: isEditProfile ? -150 : -100,y: isEditProfile ? 10 : 70)
                                .animation(.easeInOut(duration: 0.5))
                            Image("banner-rectangle-1")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: .infinity, height: 65)
                                .offset(x: isEditProfile ? -40 : 40,y: isEditProfile ? 40 : -60)
                                .rotationEffect(.degrees(isEditProfile ? 0 : -110),anchor: .center)
                                .animation(.easeInOut(duration: 0.5))
                            
                            Image("banner-circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: .infinity, height: 110)
                                .offset(x: isEditProfile ? 200 : 200,y: isEditProfile ? -30 : 90)
                                .animation(.easeInOut(duration: 0.5))
                            Image("banner-circle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: .infinity, height: 110)
                                .offset(x: isEditProfile ? -150 : -200,y: isEditProfile ? 10 : -90)
                                .animation(.easeInOut(duration: 0.5))
                        }
                    }
                    .clipped()
                    .padding(.top,50)
                    
                     
                  HStack {
                      Image("profile_picture")
                          .resizable()
                          .aspectRatio(contentMode: .fit)
                          .frame(width: .infinity, height: 120)
                          .offset(x: isEditProfile ? 10 : 10 , y: isEditProfile ? 80 : 165)
                          .animation(.bouncy(duration: 0.5))
                      Spacer()
                  }
              }
                .padding(.top,180)
             
                
              Spacer()

                
                ZStack(alignment:  .top) {
                    HStack{
                            VStack(alignment: .leading){
                                HStack{
                                    Text("\(firstName)  \(lastName)")
                                        .bold()
                                        .font(.system(size: 37))
                                        .font(.title)
                                }
                                HStack{
                                    VStack(alignment: .leading){
                                        Label(
                                            title: { Text("Indonesia") },
                                            icon: { Text("🇲🇨") }
                                        )
                                        .font(.system(size: 15))
                                        Label(
                                            title: { Text("Member since 2024") },
                                            icon: { Text("👩🏻") }
                                        )
                                    }
//                                    VStack(alignment: .leading){
//                                        Label(
//                                            title: { Text("\(height) cm ") },
//                                            icon: { Text("↕️") }
//                                        )
//                                        .font(.system(size: 15))
//                                        Label(
//                                            title: { Text("\(weight) kg ") },
//                                            icon: { Text("↔️") }
//                                        )
//                                    }
                                    
                                }
                                .font(.system(size: 15))
                                Button(action: {
                                    withAnimation {
                                        self.isEditProfile = !self.isEditProfile
                                    }
                                }) {
                                    // Isi tombol
                                    Text("Edit Profile")
                                        .font(.system(size: 17))
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20) // Padding horizontal sebesar 20 poin
                                        .padding(.vertical, 10)   // Padding vertikal sebesar 10 poin
                                        .background(Color("Accent"))
                                        .cornerRadius(12)
                                }
                                .padding(.top)
                            }
                            Spacer()
                        }
                    .padding(.top,40)
                    .padding()
//                        .background(.red)
                        .opacity(isEditProfile ? 1 : 0)
                    
//                        Edit Field
                    VStack{
                        
                        
                        HStack{
                            Spacer()
                           CustomTextField(icon: "tropy",
                                           placeHolder: "First Name",
                                           text: $firstName,
                                           rounded1: 0.57,
                                           rounded2: 0.59)
                               .frame(width: 230, alignment: .trailing)
                               .padding(.horizontal)
                            }
                        
                            HStack{
                                Spacer()
                                CustomTextField(icon: "tropy", placeHolder: "Last Name", text: $lastName,rounded1: 0.57,rounded2: 0.59)
                                        .frame(width:230,alignment: .trailing)
                                        .padding()
                            }
                        CustomTextField(icon: "tropy", placeHolder: "Email", text: $email,rounded1: 0.55,rounded2: 0.565)
                            .padding(.horizontal)
                        HStack{
                            CustomTextField(icon: "tropy", placeHolder: "weight", text: $weight,rounded1: 0.59,rounded2: 0.62)
//                                    .frame(width:230,alignment: .trailing)
                                    .padding()
                            CustomTextField(icon: "tropy", placeHolder: "height", text: $height,rounded1: 0.59,rounded2: 0.62)
//                                    .frame(width:230,alignment: .trailing)
                                    .padding()
                        }
                        
                        Button(action: {
                            withAnimation {
                                self.isEditProfile = !self.isEditProfile
                            }
                            updateUser()
                        }) {
                            // Isi tombol
                            Text("Update Profile")
                                .font(.system(size: 17))
                                .font(.title)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20) // Padding horizontal sebesar 20 poin
                                .padding(.vertical, 10)   // Padding vertikal sebesar 10 poin
                           
                                .background(Color("Accent"))
                                .cornerRadius(12)
                        }
                        .padding(.top)
                        
                        
                    }
                    .padding(.top)
                    .opacity(isEditProfile ? 0 : 1)
                    
                    
                }
//                .background(.red)
         
                
                
                Rectangle() // Menambahkan garis pemisah
                   .frame(height: 1) // Atur tinggi garis
                   .foregroundColor(.gray) //
                   .offset(y:isEditProfile ? -140 : 0)
                
            
                
                
                
                   
                
                
                           
                
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                self.isContent1Visible = true
                            }
                        }) {
                            Image(systemName: "chart.bar.xaxis")
                                .symbolEffect(.variableColor.iterative.dimInactiveLayers.nonReversing)
                            
                                .font(.largeTitle)
                                .foregroundColor(Color("Accent"))                        }
                        
                        Spacer()
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                self.isContent1Visible = false
                            }
                        }) {
                            Image(systemName: "trophy")
                                .symbolEffect(.variableColor.iterative.dimInactiveLayers.nonReversing)
                            
                                .font(.largeTitle)
                                .foregroundColor(Color("Accent"))
                        }
                        
                        Spacer()
                    }
                ZStack{
                    Rectangle() // Menambahkan garis pemisah
                                       .frame(height: 1) // Atur tinggi garis
                                       .foregroundColor(.gray) //
                    Rectangle() // Menambahkan garis pemisah
                        .frame(width:200, height: 2) // Atur tinggi garis
                        .foregroundColor(.black) //
                        .offset(x:isContent1Visible ? -100 : 100,y: 1)
                }
                
                Spacer()
                
                ZStack {
                    
                        VStack{
                            ScrollView{
                                Spacer()
                            Text("Statistics Detail")
                                .bold()
                                .font(.system(size: 17))
                                .foregroundColor(Color("Text"))
                            Text("Want to know your personal records?")
                                .font(.system(size: 15))
                                .foregroundColor(Color("Text"))
                            Button(action: {
                                // Aksi yang dijalankan ketika tombol ditekan
                                print("Tombol ditekan!")
                            }) {
                                // Isi tombol
                                NavigationLink(destination: StatisticsList(), label: {
                                    Text("See Mine")
                                })
                                .font(.system(size: 17))
                                .font(.title)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20) // Padding horizontal sebesar 20 poin
                                .padding(.vertical, 10)   // Padding vertikal sebesar 10 poin
                                .background(Color("Accent"))
                                .cornerRadius(12)
                                //                                .navigationBarTitleDisplayMode(.automatic)
                            }
                            Spacer()
                            
                        }
                    }
                         .font(.title)
                         .foregroundColor(.blue)
                         .offset(x: isContent1Visible ? 0 : -400)
                         .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
                     
                     
                    VStack{
                        HStack{
                            Text("Latest Achievements")
                                .bold()
                                .font(.system(size: 17))
                                 .foregroundColor(Color("Text"))
                            Spacer()
                            Button(action: {
                                // Aksi yang dijalankan ketika tombol ditekan
                                print("Tombol ditekan!")
                            }) {
                                // Isi tombol
                                NavigationLink(destination: Achievements(), label: {
                                    Text("Show More")
                                })                                    .underline()
                                    .font(.system(size: 17))
                                    .foregroundColor(Color("Gray"))
                                    
                            }
                        }
                        .padding()
                        
                        
                        ScrollView(.horizontal, showsIndicators: true) {
                            HStack(spacing: 20) {
                                ForEach(0..<10) { index in
                                    VStack {
                                        Image(systemName: "star.fill")
                                            .resizable()
                                            .frame(width: 80, height: 80)
                                            .foregroundColor(Color("Accent"))

                                        Text("Item \(index + 1)")
                                            .font(.headline)
                                    }
                                    .frame(width: 150, height: 200)
                                    .background(RoundedRectangle(cornerRadius: 24)
                                                    .stroke(Color("Accent"), lineWidth: 4))
                                    .background(RoundedRectangle(cornerRadius: 24).fill(Color("Primary")))
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                                }
                            }
                            .padding()
                        }
                        
                    }
                         .font(.title)
                         .foregroundColor(Color("Primary"))
                         .offset(x: isContent1Visible ? 400 : 0) // Dinamis offset
                         .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                 }
                
                    
                }
                .offset(y:isEditProfile ? -140 : 330)
                .animation(.bouncy)
                Spacer()
            }
            
            .onAppear {
                initializeUser()
            }
            .onChange(of: users) { newUsers in
                initializeUser()
            }
        }
        .navigationBarTitle("Profile", displayMode: .inline)
        .foregroundColor(Color("Text"))
    }
    
    private func updateUser() {
        guard let user = selectedUser else { return }
        user.firstName = firstName
        user.lastName = lastName
        user.email = email
        user.height = height
        user.weight = weight

        do {
            try modelContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }

    private func initializeUser() {
            guard let user = users.first else {
                selectedUser = nil
                firstName = ""
                lastName = ""
                email = ""
                return
            }
            selectedUser = user
            firstName = user.firstName
            lastName = user.lastName
            email = user.email
            weight = user.weight
            height = user.height
        }
   
    
    private func addUser() {
           let newUser = User(firstName: "Samuel", lastName: "Steven", email: "Samuelstev0902@Gmail.com", weight: "61", height: "171")
        modelContext.insert(newUser)
        do {
            try modelContext.save()
        } catch {
            print(error.localizedDescription)
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
