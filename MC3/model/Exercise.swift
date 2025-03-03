//
//  Exercise.swift
//  MC3
//
//  Created by Nico Samuelson on 23/07/24.
//

import Foundation
import SwiftData

@Model
class Exercise: Identifiable {
    var id: UUID = UUID.init()
    var date: Date = Date.now
    var duration: Double = 0
    var accuracy: Double = 0
    var mistakes: [String] = []
    var fullRecord: String = ""
    var caloriesBurned: Double = 0 

      
       init() {}


       init(id: UUID, date: Date, duration: Double, accuracy: Double, mistakes: [String], fullRecord: String, caloriesBurned: Double) {
           self.id = id
           self.date = date
           self.duration = duration
           self.accuracy = accuracy
           self.mistakes = mistakes
           self.fullRecord = fullRecord
           self.caloriesBurned = caloriesBurned
       }
}
