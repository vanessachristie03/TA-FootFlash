//
//  WatchConnector.swift
//  MC3
//
//  Created by Vanessa on 16/07/24.
//

import Foundation
import WatchConnectivity

class WatchConnector: NSObject, WCSessionDelegate {
    
    var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
    
    func sendPredictionToWatch(predicted: String) {
        if session.isReachable {
            let message = ["predicted": predicted]
            session.sendMessage(message, replyHandler: nil, errorHandler: { error in
                print("Error sending message to Watch: \(error.localizedDescription)")
            })
        }
    }
}
