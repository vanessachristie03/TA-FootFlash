//
//  TrainViewModel.swift
//  MC3
//
//  Created by Vanessa on 14/07/24.
//

import SwiftUI
import AVKit

class TrainViewModel: NSObject, ObservableObject {
    @Published var currentIndex = 0
    @Published var player: AVQueuePlayer?
    @Published var isFinishedAllVideos = false
    let videoNames = ["pakai apple watch", "nge set kamera", "area", "footwork"]

    override init() {
        super.init()
        setupPlayer()
    }

    func setupPlayer() {
        guard currentIndex < videoNames.count else { return }
        if let videoURL = createLocalUrl(for: videoNames[currentIndex], ofType: "mov") {
            let item = AVPlayerItem(url: videoURL)
            player = AVQueuePlayer(items: [item])
            player?.actionAtItemEnd = .pause
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
            player?.play()
        }
    }

    func playNextVideo() {
        currentIndex += 1
        if currentIndex < videoNames.count {
            setupPlayer()
        } else {
            isFinishedAllVideos = true // Set to true when all videos are finished
        }
    }

    @objc func playerDidFinishPlaying() {
        if currentIndex == videoNames.count - 1 {
            isFinishedAllVideos = true
        } else {
            player?.seek(to: .zero)
            player?.play()
        }
    }

    func createLocalUrl(for filename: String, ofType: String) -> URL? {
        let fileManager = FileManager.default
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let url = cacheDirectory.appendingPathComponent("\(filename).\(ofType)")

        guard fileManager.fileExists(atPath: url.path) else {
            guard let video = NSDataAsset(name: filename) else { return nil }
            do {
                try video.data.write(to: url)
                return url
            } catch {
                print("Error writing video data:", error.localizedDescription)
                return nil
            }
        }

        return url
    }
}
