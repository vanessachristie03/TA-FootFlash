import SwiftUI
import AVKit
import SwiftData
import FirebaseFirestore
import FirebaseAuth

struct Video: Identifiable, Hashable {
    let id: UUID
    let title: String
    let fileName: String
    let fileType: String
}

struct ExerciseDetailView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var watchConnector = WatchConnector.shared
    @Query var exercises: [Exercise]
    @State private var selectedVideo: String? = nil
    @State private var player: AVPlayer? = nil
    @State var saved = false
    
    var viewModel: ExerciseDetailViewModel = ExerciseDetailViewModel()
    
    init(exercise: Exercise) {
        self.viewModel.exercise = exercise
    }
    
    var body: some View {
        
        VStack {
            if let selectedVideo = selectedVideo, let videoURL = URL(string: selectedVideo) {
                VideoPlayer(player: player)
                    .frame(maxHeight: 200)
                    .scaledToFill()
                    .onAppear {
                        player = AVPlayer(url: videoURL)
                        player?.play()
                    }
            } else {
                Spacer()
                Text("Pilih video untuk diputar")
                    .frame(width: 400, height: 200)
                    .background(Color.gray.opacity(0.3))
            }
            HStack {
                VStack(alignment: .leading) {
                    if (viewModel.exercise.duration < 10 && !exercises.contains(where: {e in e.id == viewModel.exercise.id})) {
                        Text("This exercise isn't automatically saved beacuse the duration is less than 10 seconds")
                            .foregroundStyle(Color("Accent"))
                            .padding(.bottom, 12)
                    }
                    
                    Text(viewModel.formatDate(viewModel.exercise.date))
                        .font(.system(size: 13))
                        .padding(.bottom, 12)

                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(formatDuration(Int(viewModel.exercise.duration)))")
                                .bold()
                                .font(.system(size: 22))
                            Text("Time")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 32)
                        VStack(alignment: .leading) {
                                    Text("Calories burned: \(watchConnector.burnedCalories, specifier: "%.2f")")
                                        .font(.headline)
                                        .padding()
                                }
                        
                        VStack(alignment: .leading) {
                            Text("\(Int(viewModel.exercise.accuracy * 100))%")
                                .bold()
                                .font(.system(size: 22))
                            Text("Accuracy")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.leading)
                        }
                      
                    }
                }
                .padding(.top, 22)
                .padding(.horizontal, 16)
                Spacer()
                
            }
            
            if !viewModel.exercise.mistakes.isEmpty {
                HStack {
                    Text("Your Mistake")
                        .bold()
                        .font(.system(size: 17))
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 26)
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 20) {
                        ForEach(Array(viewModel.exercise.mistakes.enumerated()), id: \.element) { index, video in
                            let namaFile = viewModel.extractFileName(from: video)
                            
                            NavigationLink(destination: MistakePlaybackView(url: video)) {
                                HStack(alignment: .center) {
                                    if let thumbnail = viewModel.generateThumbnail(from: URL(string: video)!) {
                                        Image(uiImage: thumbnail)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 120, height: 80)
                                    }
                                    else {
                                        Rectangle()
                                            .frame(width: 120, height: 80)
                                            .foregroundStyle(colorScheme == .light ? Color.hex("#E3E5E5") : Color("Text").opacity(0.1))
                                            .overlay(
                                                Image(systemName: "play.slash.fill")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 30, height: 30)
                                                    .foregroundStyle(colorScheme == .light ? Color("Gray") : Color.hex("#888888"))
                                                    .background(Color.clear)
                                            )
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text("\(namaFile) #\(index + 1)")
                                            .foregroundStyle(Color("Accent"))
                                            .cornerRadius(12)
                                            .multilineTextAlignment(.leading)
                                            .font(.system(size: 15))
                                            .fontWeight(.bold)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        
//                                        Text(viewModel.durations.count > index ? viewModel.formatDuration(viewModel.durations[index], false) : "0")
//                                            .cornerRadius(12)
//                                            .font(.system(size: 13))
//                                            .foregroundStyle(Color("Text"))
//                                            .multilineTextAlignment(.leading)
//                                            .frame(maxWidth: .infinity, alignment: .leading)
//                                        
                                    }
                                    .padding(.leading, 16)
                                }
                            }
                            .frame(maxWidth: .infinity, idealHeight: 80)
                            .background(colorScheme == .dark ? Color("Text").opacity(0.1) : Color.white)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            else {
                Spacer()
                ContentUnavailableView {
                    Label("Good Job!", systemImage: "hands.clap.fill")
                               .foregroundColor(Color("Accent"))
                } description: {
                    Text("You didn't make any significant mistake during this exercise")
                        .padding(.top, 8)
                        .font(.system(size: 17))
                }
                Spacer()
            }
        }
        .background(Color("Primary"))
        .navigationTitle("Exercise Detail")
        
        .background(Color("Secondary"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !saved { // Hanya tampil kalau belum disimpan
                    Button {
                        Task {
                               await viewModel.saveToFirestore()
                               modelContext.insert(viewModel.exercise)
                               saved = true
                           }
                    } label: {
                        Text("Save")
                    }
                    .navigationDestination(isPresented: $saved) {
                        StatisticsList()
                    }
                    } else {
                        Text("Saved") // Ganti tombol dengan teks setelah disimpan
                            .foregroundColor(.gray)
                    }
                }
            }
        
        .onAppear {
            Task {
                selectedVideo = viewModel.exercise.fullRecord
                await viewModel.getVideoDurations()
            }
        }
    }
    
    
}

#Preview {
    NavigationView {
        ExerciseDetailView(exercise: Exercise())
    }
}
