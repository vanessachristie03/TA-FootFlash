//
//  tutorialView.swift
//  MC3
//
//  Created by Vanessa on 15/07/24.
//

import SwiftUI
import AVKit

struct tutorialView: View {
    @StateObject var viewModel = TutorialViewModel()
    @State var done = false

    var body: some View {
        NavigationStack {
            VStack {
                if let player = viewModel.player {
                    VideoPlayer(player: player)
                        .frame(height: 600)
                        .cornerRadius(15)
                        .shadow(radius: 10)
                        .padding([.top, .leading, .trailing])
                        .aspectRatio(contentMode: .fill)
                }

                Spacer()

                Button {
                    done = true
                } label: {
                    Text("Start Training")
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                        .frame(width: 361, height: 44)
                        .background(Color("Accent"))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding()
                .disabled(viewModel.player == nil)
                .navigationDestination(isPresented: $done) {
                    TrainClassifierView()
                }

                Spacer()
            }
            .navigationBarHidden(false)
            .navigationTitle("Tutorial")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color("Primary").edgesIgnoringSafeArea(.all))
        }
    }
}

#Preview {
    tutorialView()
}
