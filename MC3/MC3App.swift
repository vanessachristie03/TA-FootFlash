//
//  MC3App.swift
//  MC3
//
//  Created by Vanessa on 11/07/24.
//

import SwiftUI
import SwiftData

@main
struct MC3App: App {
 
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Exercise.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            LogoView()
        }
        .modelContainer(sharedModelContainer)
    }
}
