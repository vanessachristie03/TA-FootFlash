//
//  testview.swift
//  watchFastFoot Watch App
//
//  Created by Dhammiko Dharmawan on 29/09/24.
//

import SwiftUI

struct testview: View {
    var body: some View {
        ZStack {
            // Background square box
            Rectangle()
                .fill(Color("dark_green"))
                .edgesIgnoringSafeArea(.all)
//            Rectangle()
//                .fill(Color("dark_red"))
//                .edgesIgnoringSafeArea(.all)
//            Rectangle()
//                .fill(Color.clear)
//                .edgesIgnoringSafeArea(.all)
            
            // VStack on top
            VStack {
                Text("No person")
                    .font(.title2)
                    .bold()
                    .padding()
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
                
                Circle()
                    .fill(Color.white) // Create the white circle
                    .frame(width: 60, height: 60) // Set the size of the circle
                    .overlay(
                        Image(systemName: "pause.fill") // Overlay the image on top of the circle
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30) // Adjust the size of the image
                            .foregroundColor(Color.black) // Set image color
                    )
                    .onTapGesture {
//                        watchToIOSConnector.sendMessage(["command": "stopRecording"])
//                        isNavigatingBack = false
                    }
            }
            .padding()
        }
    }
}

#Preview {
    testview()
}
