//
//  WatchConnector.swift
//  MC3
//
//  Created by Vanessa on 16/07/24.
//

import Foundation
import WatchConnectivity

class WatchConnector: NSObject, ObservableObject, WCSessionDelegate {
    var session: WCSession
    static let shared = WatchConnector()
    @Published var burnedCalories: Double = 0.0
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            print("✅ WCSession iOS: Activated")
        }
        
        print("📡 WCSession isReachable: \(session.isReachable)")
        print("📡 WCSession activation state: \(session.activationState.rawValue)")
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            if let command = message["command"] as? String {
                DispatchQueue.main.async {
                    if command == "startRecording" {
                        NotificationCenter.default.post(name: .startRecording, object: nil)
                    } else if command == "stopRecording" {
                        NotificationCenter.default.post(name: .stopRecording, object: nil)
                    }
                }
            }
            if let calories = message["burnedCalories"] as? Double {
                
                self.burnedCalories = calories
                print("✅ Received burned calories from Watch: \(calories)")
            }
            
            else {
                print("kok ga masuk kalori")
            }
        }
    }

    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("📡 WCSession activation complete: \(activationState.rawValue)")
        if let error = error {
            print("❌ Activation error: \(error.localizedDescription)")
        }
    }
    func sendMessage(_ message: [String: Any]) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
    
    func sendPredictionToWatch(predicted: String) {
        print("📡 Checking session before sending...")
         print("📡 WCSession isReachable: \(session.isReachable)")
         print("📡 WCSession activation state: \(session.activationState.rawValue)")
        if session.isReachable {
            let message = ["predicted": predicted]
            session.sendMessage(message, replyHandler: nil, errorHandler: { error in
                print("Error sending message to Watch: \(error.localizedDescription)")
            })
        }
    }
    
    

}
