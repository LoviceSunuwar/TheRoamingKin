//
//  LoginView.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 26/04/2025.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text(LocalizedStringKey("welcome_title"))
                .font(.largeTitle.bold())
                .padding(.bottom, 4)

            Text(LocalizedStringKey("welcome_subtitle"))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Image(systemName: "figure.walk") // placeholder, you will replace later
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding(.vertical)

            Text(LocalizedStringKey("app_name"))
                .font(.title.bold())
                .padding(.top)

            Text(LocalizedStringKey("app_tagline"))
                .font(.headline)
                .foregroundStyle(.secondary)

            Spacer()

            VStack(spacing: 16) {
                ActionButton(
                    text: NSLocalizedString("button_google", comment: ""),
                    backgroundColor: Color(red: 219/255, green: 68/255, blue: 55/255),
                    foregroundColor: .white,
                    imageName: "globe", // placeholder icon
                    action: {
                        viewModel.signInWithGoogle()
                    }
                )

                ActionButton(
                    text: NSLocalizedString("button_facebook", comment: ""),
                    backgroundColor: Color(red: 59/255, green: 89/255, blue: 152/255),
                    foregroundColor: .white,
                    imageName: "f.square", // placeholder
                    action: {
                        viewModel.signInWithFacebook()
                    }
                )

                ActionButton(
                    text: NSLocalizedString("button_apple", comment: ""),
                    backgroundColor: .black,
                    foregroundColor: .white,
                    imageName: "applelogo",
                    action: {
                        viewModel.signInWithApple()
                    }
                )
            }
            .padding(.horizontal)

            Button(action: {
                // TODO: Continue as Guest
            }) {
                Text(LocalizedStringKey("continue_as_guest"))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    LoginView()
}
