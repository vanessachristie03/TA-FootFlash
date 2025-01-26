//
//  statistic.swift
//  MC3
//
//  Created by Vanessa on 14/07/24.
//

import Foundation

struct Statistic: Identifiable {
    let id = UUID()
    let month: String
    let value: Double
}
struct CardData: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
    let rating: String
    let duration: String
    let detail: String
    let author: String
    let date: String
   
}


