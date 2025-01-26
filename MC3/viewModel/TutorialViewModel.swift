//
//  TutorialViewModel.swift
//  MC3
//
//  Created by Vanessa on 15/07/24.
//

import SwiftUI
import AVKit

class TutorialViewModel: NSObject, ObservableObject {
    @Published var currentIndex = 0
    @Published var player: AVQueuePlayer?
    @Published var navigateToTutorialView = false
    
    let videoNames = ["footworkbenar"]

    override init() {
        super.init()
        setupPlayer()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setupPlayer() {
        guard currentIndex < videoNames.count else { return }
        if let videoURL = createLocalUrl(for: videoNames[currentIndex], ofType: "mov") {
            let item = AVPlayerItem(url: videoURL)
            if player == nil {
                player = AVQueuePlayer(items: [item])
                player?.actionAtItemEnd = .pause
                NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
            } else {
                player?.removeAllItems()
                player?.insert(item, after: nil)
            }
            player?.play()
        }
    }

    func playNextVideo() {
        currentIndex += 1
        if currentIndex < videoNames.count {
            setupPlayer()
        } else {
            navigateToTutorialView = true
        }
    }

    @objc func playerDidFinishPlaying() {
        playNextVideo()
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
