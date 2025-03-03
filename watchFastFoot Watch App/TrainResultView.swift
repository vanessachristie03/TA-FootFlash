//
//  TrainResultView.swift
//  watchFastFoot Watch App
//
//  Created by Dhammiko Dharmawan on 24/07/24.
//

import SwiftUI

struct TrainResultView: View {
    @ObservedObject var watchToIOSConnector: WatchToIOSConnector
    @Binding var isNavigatingBack: Bool
    
    // Computed property to extract the result substring
    var predictionResult: String {
        let components = watchToIOSConnector.text.split(separator: ":")
        guard components.count > 1 else { return "" }
        return components[1].trimmingCharacters(in: .whitespaces)
    }
    
    var body: some View {
        ZStack {
            // Background square box
            Rectangle()
                .fill(predictionResult == "benar" ? Color("dark_green") : (predictionResult == "salah" ? Color("dark_red") : Color.clear))
                .edgesIgnoringSafeArea(.all) // Make the box fill the whole screen
            
            // VStack on top
            VStack {
                Text(predictionResult)
                    .font(.title2)
                    .bold()
                    .padding()
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
                
                             // **Tampilkan Kalori yang Terbakar**
                             Text("CAL: \(watchToIOSConnector.burnedCalories, specifier: "%.2f") kcal")
                                 .font(.headline)
                                 .foregroundColor(.white)
                                 .padding()
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "pause.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color.black)
                    )
                    .onTapGesture {
                        watchToIOSConnector.sendMessage(["command": "stopRecording"])
//                        watchToIOSConnector.stopWorkout()
                        isNavigatingBack = false
                    }
            }
            .padding()
        }
    }
}

#Preview {
    TrainResultView(watchToIOSConnector: WatchToIOSConnector(), isNavigatingBack: .constant(false))
}







