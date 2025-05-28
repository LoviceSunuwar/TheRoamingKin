//
//  SplashView.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 22/05/2025.
//

import SwiftUI

struct SplashView: View {
    @Binding var isActive: Bool

    var body: some View {
        ZStack {
            Color(#colorLiteral(red: 0.2, green: 0.0, blue: 0.3, alpha: 1))
                .ignoresSafeArea()

            Image("SplashIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
        }
        .onAppear {
            AudioPlayer.shared.playSound(named: "TRKOpen") // <- Play audio on splash
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isActive = false
                }
            }
        }
    }
}
