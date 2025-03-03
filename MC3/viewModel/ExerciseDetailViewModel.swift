//
//  ExerciseDetailViewModel.swift
//  MC3
//
//  Created by Nico Samuelson on 10/08/24.
//

import Foundation
import SwiftUI
import AVKit
import FirebaseFirestore

class ExerciseDetailViewModel: ObservableObject {
    @Published var exercise: Exercise = Exercise()
    @Published var durations: [Int] = []
    
    init(exercise: Exercise) {
        self.exercise = exercise
    }
    
    init() {}
    func saveToFirestore() {
        let db = Firestore.firestore()
        let userID = getOrCreateUserID()

        let exerciseData: [String: Any] = [
            "id": exercise.id.uuidString,
            "userID": userID,
            "date": Timestamp(date: exercise.date),
            "duration": exercise.duration,
            "accuracy": exercise.accuracy,
            "mistakes": exercise.mistakes,
            "fullRecord": exercise.fullRecord,
            "caloriesBurned": exercise.caloriesBurned
        ]
        
        db.collection("exercise").document(exercise.id.uuidString).setData(exerciseData) { error in
            if let error = error {
                print("Error saving to Firestore: \(error.localizedDescription)")
            } else {
                print("Exercise successfully saved to Firestore")
            }
        }
    }
    

    
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
