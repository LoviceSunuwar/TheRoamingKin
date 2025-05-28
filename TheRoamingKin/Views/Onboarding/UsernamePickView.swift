import SwiftUI

struct UsernamePickView: View {
    @StateObject private var viewModel = UsernamePickViewModel()
    @ObservedObject var loginViewModel: LoginViewModel

    private let avatars = [
        "Barbarian", "Knight", "Mage", "Rogue", "Rogue_Hooded",
        "Skeleton_Mage", "Skeleton_Minion", "Skeleton_Rogue", "Skeleton_Warrior"
    ]

    private let avatarNameMap: [String: String] = [
        "Barbarian": "Barbarian",
        "Knight": "Knight",
        "Mage": "Mage",
        "Rogue": "Rogue",
        "Rogue_Hooded": "Rogue+Hood",
        "Skeleton_Mage": "Skel Mage",
        "Skeleton_Minion": "Minion",
        "Skeleton_Rogue": "Skel Rogue",
        "Skeleton_Warrior": "Skel Warrior"
    ]

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            // MARK: - Large Selected Avatar Preview
            if let selected = viewModel.selectedAvatar {
                AvatarSceneView(avatarName: selected, isInteractive: true)
                    .id(selected) // ⬅️ Forces view to update when avatar changes
                    .frame(
                        width: UIScreen.main.bounds.width * 0.9,
                        height: UIScreen.main.bounds.height * 0.4
                    )
                    .cornerRadius(16)
                    .padding(.bottom, 10)
            }

            // MARK: - Avatar Scroll Selection
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(avatars, id: \.self) { avatar in
                        VStack(spacing: 4) {
                            AvatarSceneView(avatarName: avatar, isInteractive: false)
                                .frame(width: 80, height: 80)

                            Text(avatarNameMap[avatar] ?? avatar.capitalized)
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .padding(8)
                        .background(viewModel.selectedAvatar == avatar ? Color.green : Color.black)
                        .cornerRadius(12)
                        .onTapGesture {
                            viewModel.selectedAvatar = avatar
                        }
                    }
                }
                .padding(.horizontal)
            }

            // MARK: - Username TextField
            TextField("Username", text: $viewModel.username)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .frame(height: 40)

            // MARK: - Feedback
            if let available = viewModel.isUsernameAvailable {
                Text(available ? "The Username is available" : "The Username is taken")
                    .font(.subheadline)
                    .foregroundColor(available ? .green : .red)
            }

            if !viewModel.isUsernameClean && !viewModel.username.isEmpty {
                Text("Username contains inappropriate language.")
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Spacer()

            // MARK: - Continue Button
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
