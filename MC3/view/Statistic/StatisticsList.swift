import SwiftUI
import FirebaseFirestore

struct StatisticsList: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var currentIndex: Int = 0
    @State private var trainNow: Bool = false
    @StateObject private var viewModel = StatisticsViewModel() 
    
    
    func setWorkoutTitle(date: Date) -> String {
        let day = formatDate(date: date, format: "EEEE")
        
        let hour = Int(formatDate(date: date, format: "HH", locale: "ID")) ?? 0
        var time = "Morning"
        
        if hour >= 12 && hour < 15 {
            time = "Noon"
        }
        else if hour >= 15 && hour < 18 {
            time = "Afternoon"
        }
        else if hour >= 18 && hour < 24 {
            time = "Night"
        }
        
        return "\(day) \(time) Exercise"
    }
    
    var body: some View {
        if viewModel.exercises.count > 0 {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 20) {
                    ForEach(Array(viewModel.exercises.sorted(by: { $0.date > $1.date }).enumerated()), id: \.element.id) { index, exercise in

                        NavigationLink(destination: ExerciseDetailView(exercise: exercise))  {
                            VStack(alignment: .leading) {
                                Text(formatDate(date: exercise.date))
                                    .font(.custom("SF Pro Text", size: 18))
                                Text(setWorkoutTitle(date: exercise.date))
                                    .foregroundStyle(.gray)
                                    .font(.custom("SF Pro Text", size: 16))
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(formatDuration(Int(exercise.duration)))
                                            .bold()
                                            .font(.custom("SF Pro Text", size: 22))
                                        Text("Time")
                                            .font(.custom("SF Pro Text", size: 12))
                                            .multilineTextAlignment(.leading)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack {
                                        Text("\(Int(exercise.accuracy * 100))%")
                                            .font(.custom("SF Pro Text", size: 22))
                                        Text("Accuracy")
                                            .font(.custom("SF Pro Text", size: 12))
                                            .multilineTextAlignment(.leading)
                                    }
                                    .padding(.vertical, 5)
                                    
                                    Spacer()
                                    VStack {
                                           Text("\(String(format: "%.2f", viewModel.caloriesData[exercise.id] ?? 0.0))")
                                               .font(.custom("SF Pro Text", size: 22))
                                           Text("Calories")
                                               .font(.custom("SF Pro Text", size: 12))
                                               .multilineTextAlignment(.leading)
                                       }
                                       .padding(.vertical, 5)
                                    Spacer()
                                    
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 200)
                            .padding()
                            .background(colorScheme == .dark ? Color("Text").opacity(0.1) : Color.white)
                            .cornerRadius(12)
                            .offset(x: index <= currentIndex ? 0 : 400)
                            .opacity(index <= currentIndex ? 1 : 0)
                            .animation(.easeOut.delay(Double(index) * 0.1), value: index <= currentIndex)
                        }
                    }
                    .foregroundColor(Color("Text"))
                }
                .padding()
                .onAppear {
                    print("Exercise count: \(viewModel.exercises.count)")
                    for index in 0..<viewModel.exercises.count {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                            withAnimation {
                                currentIndex += 1
                            }
                        }
                    }
                }
            }
            .background(Color("Primary"))
            .navigationBarTitle("Statistic List", displayMode: .inline)
            .onAppear {
                trainNow = false
                viewModel.fetchExercisesFromFirestore() // Fetch data dari Firestore saat tampilan muncul
            }
        }
        else {
            VStack {
                Spacer()
                ContentUnavailableView {
                    Label("You haven't done any exercise", systemImage: "figure.run")
                } description: {
                    Text("Let's exercise your footwork and review your progress here")
                        .padding(.top, 8)
                        .font(.system(size: 17))
                }
                Spacer()
                Button(action: {
                    trainNow = true
                }) {
                    Text("Start Training")
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                        .frame(width: 361, height: 44)
                        .background(Color("Accent"))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding()
                .navigationDestination(isPresented: $trainNow) {
                    trainView()
                }
            }
            .background(Color("Primary"))
            .navigationBarTitle("Statistic List", displayMode: .inline)
            .onAppear {
                trainNow = false
                viewModel.fetchExercisesFromFirestore() // Fetch data Firestore
            }
        }
    }
}

#Preview {
    StatisticsList()
}
