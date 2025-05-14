//
//  LoginView.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 26/04/2025.
//
import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Banner Image
            Image("TRKLoginBanner")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: UIScreen.main.bounds.height * 0.55)
                    .clipped()
                    .overlay(
                        // Bottom blur mask
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .blur(radius: 20)
                            .frame(height: 100)
                            .offset(y: 50),
                        alignment: .bottom
                    )
            // Welcome Title & Subtitle
            VStack(spacing: 8) {
                Text("Welcome to The Roaming Kin")
                    .font(.title2.bold())
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)

                Text("A journey of strength, wisdom, and charisma begins.")
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)

            // Buttons
            VStack(spacing: 16) {
                ActionButton(
                    text: "Continue With Facebook",
                    backgroundColor: Color(red: 59/255, green: 89/255, blue: 152/255),
                    foregroundColor: .white,
                    imageName: "f.square",
                    action: {
                        viewModel.signInWithFacebook()
                    }
                )

                ActionButton(
                    text: "Continue With Google",
                    backgroundColor: Color(red: 219/255, green: 68/255, blue: 55/255),
                    foregroundColor: .white,
                    imageName: "globe",
                    action: {
                        viewModel.signInWithGoogle()
                    }
                )

                ActionButton(
                    text: "Continue With Apple",
                    backgroundColor: .black,
                    foregroundColor: .white,
                    imageName: "applelogo",
                    action: {
                        viewModel.signInWithApple()
                    }
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)

            Spacer(minLength: 0)
        }
        .edgesIgnoringSafeArea(.top)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    .white,                                             // White
                    Color(red: 85/255, green: 107/255, blue: 47/255)   // Green
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onAppear {
            print("🟥 [LoginView] onAppear - authState: \(viewModel.authState)")
            print("🟥 [LoginView] LoginViewModel instance id: \(ObjectIdentifier(viewModel))")
        }
    }
}
