//
//  ExerciseDetailViewModel.swift
//  MC3
//
//  Created by Nico Samuelson on 10/08/24.
//

import Foundation
import SwiftUI
import AVKit

class ExerciseDetailViewModel: ObservableObject {
    @Published var exercise: Exercise = Exercise()
    @Published var durations: [Int] = []
    
    init(exercise: Exercise) {
        self.exercise = exercise
    }
    
    init() {}
    
    func generateThumbnail(from url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImageGenerator.appliesPreferredTrackTransform = true // Correctly orient the thumbnail
        
        let time = CMTime(seconds: 1.0, preferredTimescale: 600) // Capture the thumbnail at 1 second
        
        do {
            let cgImage = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch {
            print("Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }

    func getVideoDurations() async {
        for mistake in exercise.mistakes {
            guard let url = URL(string: mistake) else {
                continue
            }
            
            let asset = AVAsset(url: url)
            var duration: Double = 0
            do {
                duration = try await asset.load(.duration).seconds
            }
            catch {
                print("error getting video duration")
            }
            
            durations.append(Int(duration))
        }
    }

    func extractFileName(from url: String) -> String {
        // Pisahkan URL berdasarkan "/"
        let components = url.components(separatedBy: "/")
        // Ambil komponen terakhir (nama file dengan ekstensi)
        if let fileNameWithExtension = components.last {
            // Pisahkan nama file berdasarkan "_" dan ambil bagian pertama (nama file sebelum "_")
            let nameParts = fileNameWithExtension.components(separatedBy: "_")
            return nameParts.first ?? ""
        }
        return ""
    }
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy" // For "June 30, 2024" format
        return dateFormatter.string(from: date)
    }


    
    //    private func playVideo(from url: URL) {
    //        let player = AVPlayer(url: url)
    //        let playerViewController = AVPlayerViewController()
    //        playerViewController.player = player
    //        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
    //           let rootViewController = windowScene.windows.first?.rootViewController {
    //            rootViewController.present(playerViewController, animated: true) {
    //                player.play()
    //            }
    //        }
    //    }

    //    func createLocalUrl(for filename: String, ofType type: String) -> URL? {
    //        let fileManager = FileManager.default
    //        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    //        let url = cacheDirectory.appendingPathComponent("\(filename).\(type)")
    //
    //        guard fileManager.fileExists(atPath: url.path) else {
    //            guard let video = NSDataAsset(name: filename) else { return nil }
    //            do {
    //                try video.data.write(to: url)
    //                print("Video written to URL: \(url)")
    //                return url
    //            } catch {
    //                print("Error writing video data:", error.localizedDescription)
    //                return nil
    //            }
    //        }
    //
    //        return url
    //    }
}
