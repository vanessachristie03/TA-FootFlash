//
//  statisticViewModel.swift
//  MC3
//
//  Created by Vanessa on 14/07/24.
//


import SwiftUI

class StatisticsViewModel: ObservableObject {
    @Published var statistics: [Statistic] = []
    @Published var exercises: [Exercise] = []
    
    func getAverageAccuracy() -> Int {
        let accuracies = exercises.map { $0.accuracy }
        
        return Int(accuracies.reduce(0) { $0 + $1/Double(accuracies.count)} * 100)
    }
    
    func getTotalDuration() -> String {
        let totalDur: Double = exercises.map { $0.duration }.reduce(0) { $0 + $1 }
        
        return formatDuration(Int(totalDur))
    }

    func getMonthlyStatistic() {
        statistics.removeAll()
        var groupedExercise = [String: [Exercise]]()
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        
        // Calculate the start and end dates for the last 7 full months
        let now = Date()
        let startOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        guard let startDate = calendar.date(byAdding: .month, value: -7, to: startOfCurrentMonth) else {
            return
        }
        
        for exercise in exercises {
            // Filter dates to include only those in the last 7 full months
            if exercise.date >= startDate && exercise.date <= now {
                let components = calendar.dateComponents([.year, .month], from: exercise.date)
                if let year = components.year, let month = components.month {
                    let key = "\(dateFormatter.monthSymbols[month - 1])"
                    if groupedExercise[key] != nil {
                        groupedExercise[key]?.append(exercise)
                    } else {
                        groupedExercise[key] = [exercise]
                    }
                }
            }
        }
        
        for (month, exercises) in groupedExercise {
            statistics.append(Statistic(month: month, value: Double(Int(exercises.map{$0.duration}.reduce(0) { $0 + $1 }))))
        }
    }
}

