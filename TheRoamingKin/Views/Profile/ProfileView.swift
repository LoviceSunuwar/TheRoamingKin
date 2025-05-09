//
//  ProfileView.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 08/05/2025.
//
import SwiftUI

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel

    var body: some View {
        VStack(spacing: 24) {
            Text("👤 Profile View")
                .font(.largeTitle.bold())

            Button(action: {
                loginViewModel.logout()
            }) {
                Text("Logout")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.red)
                    .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
    }
}
