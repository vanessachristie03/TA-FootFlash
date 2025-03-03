//
//  ContentView.swift
//  watchFastFoot Watch App
//
//  Created by Vanessa on 16/07/24.
//
import SwiftUI

struct ContentView: View {
    @StateObject private var watchToIOSConnector = WatchToIOSConnector()
    @State private var isNavigatingToTrainResult = false
    
    var body: some View {
        NavigationView {
            VStack {
                if watchToIOSConnector.isPlaying {
                    NavigationLink(destination: TrainResultView(watchToIOSConnector: watchToIOSConnector, isNavigatingBack: $isNavigatingToTrainResult), isActive: $isNavigatingToTrainResult) {
                        EmptyView()
                    }
                } else {
                    VStack {
                        if watchToIOSConnector.isCalibrated {
                            Button(action: {
                                watchToIOSConnector.sendMessage(["command": "startRecording"])
                                watchToIOSConnector.isPlaying = true
//                                watchToIOSConnector.startWorkout()
                                isNavigatingToTrainResult = true
                            }) {
                                Image(systemName: "play.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundStyle(Color.white)
                            }
                        } else {
                            Text("Waiting for calibration...")
                                .padding()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}







