//
//  watchToIOSConnector.swift
//  watchFastFoot Watch App
//
//  Created by Vanessa on 16/07/24.
//

import Foundation
import WatchConnectivity
import SwiftUI

class WatchToIOSConnector: NSObject, ObservableObject, WCSessionDelegate {
    @Published var text: String = "Waiting for calibration..."
    @Published var isCalibrated: Bool = false
    @Published var isPlaying: Bool = false
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let predicted = message["predicted"] as? String {
            DispatchQueue.main.async {
                self.text = "Prediction: \(predicted)"
            }
        } else if let calibrationStatus = message["calibrationStatus"] as? Bool {
            DispatchQueue.main.async {
                self.isCalibrated = calibrationStatus
            }
        } else if let command = message["command"] as? String, command == "startRecording" {
            DispatchQueue.main.async {
                self.isPlaying = true
            }
        }
    }
    
    func sendMessage(_ message: [String: Any]) {
        if let command = message["command"] as? String {
                    if command == "stopRecording" {
                        handleStopRecording()
                    }else{
                        print("ga masuk if")
                    }
                }
        
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
    
    private func handleStopRecording() {
            // Perform the actions needed when "stopRecording" is received
            DispatchQueue.main.async {
                self.isPlaying = false
            }
        }
}





