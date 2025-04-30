import SwiftUI

struct UsernamePickView: View {
    @StateObject private var viewModel = UsernamePickViewModel()
    @ObservedObject var loginViewModel: LoginViewModel

    private let avatars = (0...8).map { String(format: "%02d", $0) } // "00" to "08"

    private let columns = [
        GridItem(.flexible()), GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // App Logo (replace with real asset later)
            Image("AppLogo") // 👈 your TRK image asset
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .cornerRadius(16)

            // Username availability message
            if let available = viewModel.isUsernameAvailable {
                Text(available ? "The Username is available" : "The Username is taken")
                    .font(.subheadline)
                    .foregroundColor(available ? .green : .red)
            }

            // Username textfield
            TextField("Username", text: $viewModel.username)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .frame(height: 40)

            // Avatar grid
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(avatars, id: \.self) { avatar in
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(viewModel.selectedAvatar == avatar ? Color.green : Color.clear)
                            .frame(height: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black, lineWidth: 1)
                            )

                        Circle()
                            .fill(Color.black)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(avatar)
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                            )
                    }
                    .onTapGesture {
                        viewModel.selectedAvatar = avatar
                    }
                }
            }
            .padding(.horizontal)

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

// MARK: - Extension for button enabling logic
extension UsernamePickViewModel {
    func usernameBorderColor(for availability: Bool?) -> Color {
        if let available = availability {
            return available ? .green : .red
        } else {
            return .gray
        }
    }

    var canContinue: Bool {
        if let available = isUsernameAvailable {
            return available && selectedAvatar != nil
        }
        return false
    }
}
