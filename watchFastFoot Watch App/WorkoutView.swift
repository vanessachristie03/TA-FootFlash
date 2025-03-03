////
////  WorkoutView.swift
////  MC3
////
////  Created by Vanessa on 26/02/25.
////
//
//
//import SwiftUI
//
//struct WorkoutView: View {
//    @ObservedObject var watchConnector: WatchToIOSConnector
//    
//    var body: some View {
//        VStack {
//            if watchConnector.isCalibrated {
//                Button(action: {
//                    watchConnector.sendMessage(["command": "startRecording"])
//                    watchConnector.isPlaying = true
//                }) {
//                    Image(systemName: "play.fill")
//                        .resizable()
//                        .frame(width: 50, height: 50)
//                        .foregroundStyle(Color.white)
//                }
//                
//                // Menampilkan jumlah kalori terbakar
//                Text("Calories Burned: \(watchConnector.burnedCalories, specifier: "%.2f") kcal")
//                    .font(.headline)
//                    .padding(.top, 10)
//            } else {
//                Text("Waiting for calibration...")
//                    .padding()
//            }
//        }
//    }
//}
