//
//  Video.swift
//  MC3
//
//  Created by Dhammiko Dharmawan on 23/07/24.
//

import Foundation
import SwiftData

@Model
class VideoMetadata {
    var id : UUID = UUID.init()
    var title: String
    var url: URL

    init(title: String, url: URL) {
        self.id = UUID()
        self.title = title
        self.url = url
    }
}
