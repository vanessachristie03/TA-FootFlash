//
//  LogoView.swift
//  MC3
//
//  Created by Vanessa on 23/07/24.
//

import SwiftUI

struct LogoView: View {
    @State private var isActive = false
    @State private var size: CGFloat = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("Accent")
                    .ignoresSafeArea()

                VStack {
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 400, height: 400)
                        .scaleEffect(size)
                        .opacity(opacity)
                        .onAppear {
                            withAnimation(.easeIn(duration: 1.2)) {
                                self.size = 0.9
                                self.opacity = 1.0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                                self.isActive = true
                            }
                        }
                }
            }
        }
        .accentColor(Color.red)
        .fullScreenCover(isPresented: $isActive) {
            ContentView()
        }
    }
}
#Preview {
    LogoView()
}

