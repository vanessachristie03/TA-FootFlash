//
//  StringFormat.swift
//  MC3
//
//  Created by Nico Samuelson on 10/08/24.
//

import Foundation

func formatDuration(_ seconds: Int, _ withHour: Bool = true) -> String {
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    let seconds = seconds % 60
    
    return withHour ? String(format: "%02d:%02d:%02d", hours, minutes, seconds) : String(format: "%02d:%02d", minutes, seconds)
}

func formatDate(date: Date, format: String = "MMMM dd, yyyy", locale: String = "en_US") -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.locale = Locale(identifier: locale)
    
    return dateFormatter.string(from: date)
}
