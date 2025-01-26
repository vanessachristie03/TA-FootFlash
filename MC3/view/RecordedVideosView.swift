import Foundation
import SwiftUI
import AVKit

struct RecordedVideosView: View {
    var predictionVM: PredictionViewModel
    
    init(predictionVM: PredictionViewModel) {
        self.predictionVM = predictionVM
    }

    var body: some View {
//        NavigationStack {
            VStack {
                List(predictionVM.getSavedVideoURLs(), id: \.self) { url in
                    let fileName = url.lastPathComponent
                    Text(fileName)
                        .onTapGesture {
                            // Handle video playback
                            playVideo(from: url)
                        }
                }
                
                NavigationLink(destination: StatisticsList(), label: {
                    Text("See exercise history")
                })
            }
            .navigationBarTitle("Recorded Videos")
//        }
    }

    private func playVideo(from url: URL) {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        UIApplication.shared.windows.first?.rootViewController?
            .present(playerViewController, animated: true) {
                player.play()
            }
    }
}
