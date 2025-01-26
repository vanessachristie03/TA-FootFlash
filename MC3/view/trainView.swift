//
//  trainView.swift
//  MC3
//
//  Created by Vanessa on 14/07/24.
//
import SwiftUI
import AVKit

struct trainView: View {
    @StateObject var viewModel = TrainViewModel()
    @State var Classification_text: String = ""
    
    var body: some View {
        VStack {
            // Video Player
            if let player = viewModel.player {
                VideoPlayer(player: player) {}
                    .frame(height: 600)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .padding([.top, .leading, .trailing])
            }
            
            // Next or Start Tutorial Button
            if viewModel.currentIndex < viewModel.videoNames.count - 1 {
                Button(action: {
                    viewModel.playNextVideo()
                }) {
                    Text("Next Video")
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                        .frame(width: 361, height: 44)
                        .background(Color("Accent"))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding()
                .disabled(viewModel.player == nil)
            } else {
                NavigationLink(destination: tutorialView()) {
                    Text("Start Tutorial Footwork")
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                        .frame(width: 361, height: 44)
                        .background(Color("Accent"))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding()
            }
            
            // Skip Button
            NavigationLink(destination: tutorialView()) {
                Text("Skip")
                    .font(.system(size: 17))
                    .foregroundColor(Color("Accent"))
            }
            .bold()
        }
        .navigationBarHidden(false)
        .navigationTitle("Preparation")
        .navigationBarTitleDisplayMode(.inline)
        
        .background(Color("Primary").edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    trainView()
}
