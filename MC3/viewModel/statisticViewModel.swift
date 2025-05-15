//
//  statisticViewModel.swift
//  MC3
//
//  Created by Vanessa on 14/07/24.
//


import SwiftUI
import Foundation
import FirebaseFirestore

class StatisticsViewModel: ObservableObject {
    @Published var statistics: [Statistic] = []
    @Published var exercises: [Exercise] = []
    @Published var totalDuration: String = "0"
    @Published var averageAccuracy: Int = 0
    @Published var caloriesData: [UUID: Double] = [:]
    private var accuracyData: [String: Double] = [:]
    
    func fetchExercisesFromFirestore() {
        let db = Firestore.firestore()
        let userID = getOrCreateUserID()
        
        db.collection("exercise")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("🔥 Error fetching exercises: \(error.localizedDescription)")
                    return
                }
                if let documents = snapshot?.documents {
                                   self.exercises = documents.compactMap { doc in
                                       let data = doc.data()
                                       let exerciseID = UUID(uuidString: doc.documentID) ?? UUID()
                                       
                                       // Simpan caloriesBurned ke dictionary
                                       if let calories = data["caloriesBurned"] as? Double {
                                           self.caloriesData[exerciseID] = calories
                                       }
                                       
                                       return Exercise(
                                           id: exerciseID,
                                           date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                                           duration: data["duration"] as? Double ?? 0,
                                           accuracy: data["accuracy"] as? Double ?? 0,
                                           mistakes: data["mistakes"] as? [String] ?? [],
                                           fullRecord: data["fullRecord"] as? String ?? "",
                                           caloriesBurned: data["caloriesBurned"] as? Double ?? 0
                                       )
                                   }
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
    
    func fetchStatistics(completion: (() -> Void)? = nil) {
        let db = Firestore.firestore()
        let userID = getOrCreateUserID()
        
        db.collection("exercise")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("🔥 Error fetching statistics: \(error.localizedDescription)")
                    return
                }
                
                let exercises = snapshot?.documents.compactMap { doc in
                    doc.data()
                } ?? []
                
                let totalDurationValue = exercises
                    .compactMap { $0["duration"] as? Double }
                    .reduce(0, +)
                
                let accuracies = exercises.compactMap { $0["accuracy"] as? Double }
                let avgAccuracyValue = accuracies.isEmpty ? 0 : (accuracies.reduce(0, +) / Double(accuracies.count)) * 100
                
                DispatchQueue.main.async {
                    self.totalDuration = formatDuration(Int(totalDurationValue))
                    self.averageAccuracy = Int(avgAccuracyValue)
                    print("✅ Statistics updated: totalDuration = \(self.totalDuration), averageAccuracy = \(self.averageAccuracy)%")

                    completion?()
                }
            }
    }

    func getMonthlyStatistic() {
        statistics.removeAll()
        let db = Firestore.firestore()
        let userID = getOrCreateUserID()
        var groupedExercise = [String: [Exercise]]()
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        
        // Hitung batas waktu 7 bulan terakhir
        let now = Date()
        let startOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        guard let startDate = calendar.date(byAdding: .month, value: -7, to: startOfCurrentMonth) else { return }
        
        db.collection("exercise")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("🔥 Error fetching exercises: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                for document in documents {
                    let data = document.data()
                    guard let timestamp = data["date"] as? Timestamp else { continue }
                    
                    let exerciseDate = timestamp.dateValue()
                    
                    // Pastikan hanya mengambil data dari 7 bulan terakhir
                    if exerciseDate >= startDate && exerciseDate <= now {
                        let components = calendar.dateComponents([.year, .month], from: exerciseDate)
                        if let year = components.year, let month = components.month {
                            let key = "\(dateFormatter.monthSymbols[month - 1])"
                            let exercise = Exercise(
                                id: UUID(uuidString: document.documentID) ?? UUID(),
                                date: exerciseDate,
                                duration: data["duration"] as? Double ?? 0,
                                accuracy: data["accuracy"] as? Double ?? 0,
                                mistakes: data["mistakes"] as? [String] ?? [],
                                fullRecord: data["fullRecord"] as? String ?? "",
                                caloriesBurned: data["caloriesBurned"] as? Double ?? 0
                            )
                            
                            if groupedExercise[key] != nil {
                                groupedExercise[key]?.append(exercise)
                            } else {
                                groupedExercise[key] = [exercise]
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.statistics = groupedExercise.map { (month, exercises) in
                        return Statistic(
                            month: month,
                            value: Double(Int(exercises.map { $0.duration }.reduce(0, +))) // Total durasi per bulan
                        )
                    }.sorted { $0.month < $1.month }
                }
            }
        print("Fetch monthly statistics selesai")
    }
    func saveToLeaderboard() {
            let db = Firestore.firestore()
            let userID = getOrCreateUserID()
            
            db.collection("users").document(userID).getDocument { document, error in
                guard let data = document?.data(), error == nil else {
                    print("🔥 Error fetching user data: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                let firstName = data["firstName"] as? String ?? ""
                let lastName = data["lastName"] as? String ?? ""
                let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
                
                let leaderboardEntry: [String: Any] = [
                    "id": UUID().uuidString,
                    "userId": userID,
                    "fullName": fullName,
                    "totalAccuracy": self.averageAccuracy
                ]
                
                db.collection("Leaderboard").document(userID).setData(leaderboardEntry) { error in
                    if let error = error {
                        print("🔥 Error saving to Leaderboard: \(error.localizedDescription)")
                    } else {
                        print("✅ Successfully saved to Leaderboard")
                    }
                }
            }
        }

}



