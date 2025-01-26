//
//  VideoPlaybackView.swift
//  MC3
//
//  Created by Nico Samuelson on 29/07/24.
//

import SwiftUI
import AVFoundation
import AVKit
//import _AVKit_SwiftUI

struct MistakePlaybackView: View {
    @State var url: String
    @State var player: AVPlayer? = nil
    
    init(url: String) {
        self.url = url
    }
    
    var body: some View {
        GeometryReader { gr in
            VideoPlayer(player: player)
                .frame(maxWidth: gr.size.width, maxHeight: gr.size.height, alignment: .center)
                .edgesIgnoringSafeArea(.bottom)
                .onAppear {
                    player = AVPlayer(url: URL(string: url)!)
                    player?.play()
                }
        }
        .navigationTitle("Your Mistake")
        .navigationBarTitleDisplayMode(.inline)
    }
}

//#Preview {
////    VideoPlaybackView()
//}
