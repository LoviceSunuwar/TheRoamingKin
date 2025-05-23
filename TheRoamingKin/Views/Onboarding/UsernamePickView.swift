import SwiftUI

struct UsernamePickView: View {
    @StateObject private var viewModel = UsernamePickViewModel()
    @ObservedObject var loginViewModel: LoginViewModel

    private let avatars = (0...8).map { String(format: "%02d", $0) } // "00" to "08"

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            // Selected avatar preview
            if let selected = viewModel.selectedAvatar {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 150, height: 150)
                    .overlay(
                        Text(selected)
                            .font(.largeTitle)
                            .foregroundColor(.black)
                    )
                    .padding(.bottom, 10)
            }

            // Avatar picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(avatars, id: \.self) { avatar in
                        ZStack {
                            Circle()
                                .stroke(viewModel.selectedAvatar == avatar ? Color.green : Color.black, lineWidth: 2)
                                .background(
                                    Circle()
                                        .fill(Color.gray.opacity(0.2))
                                )
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Text(avatar)
                                        .foregroundColor(.black)
                                )
                        }
                        .onTapGesture {
                            viewModel.selectedAvatar = avatar
                        }
                    }
                }
                .padding(.horizontal)
            }

            // Username field
            TextField("Username", text: $viewModel.username)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .frame(height: 40)

            // Availability status
            if let available = viewModel.isUsernameAvailable {
                Text(available ? "The Username is available" : "The Username is taken")
                    .font(.subheadline)
                    .foregroundColor(available ? .green : .red)
            }

            // Profanity warning
            if !viewModel.isUsernameClean && !viewModel.username.isEmpty {
                Text("Username contains inappropriate language.")
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Spacer()

            // Continue button
            Button(action: {
                viewModel.saveProfile(loginViewModel: loginViewModel)
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(viewModel.canContinue ? Color.blue : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(!viewModel.canContinue)
            .padding(.horizontal)

            // Error message
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            print("🟨 UsernamePickView onAppear: authState=\(loginViewModel.authState)")
        }
    }
}

extension UsernamePickViewModel {
    var isUsernameClean: Bool {
        !ProfanityFilter.containsProfanity(username)
    }

    var canContinue: Bool {
        if let available = isUsernameAvailable {
            return available && selectedAvatar != nil && isUsernameClean
        }
        return false
    }

    func usernameBorderColor(for availability: Bool?) -> Color {
        if let available = availability {
            return available ? .green : .red
        } else {
            return .gray
        }
    }
}
