//
//  WatchViewModel.swift
//  watchFastFoot Watch App
//
//  Created by Dhammiko Dharmawan on 24/07/24.
//

import SwiftUI
import WatchConnectivity

class WatchViewModel: NSObject, ObservableObject, WCSessionDelegate {
    @Published var receivedImage: UIImage?

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle activation state
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let base64String = message["frame"] as? String,
           let imageData = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters),
           let image = UIImage(data: imageData) {
            DispatchQueue.main.async {
                self.receivedImage = image
            }
        }
    }
}

