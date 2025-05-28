import SwiftUI

struct ProfileEditView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @StateObject private var viewModel = ProfileEditViewModel()

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

            // MARK: - 3D Preview
            if let selected = viewModel.selectedAvatar {
                AvatarSceneView(avatarName: selected, isInteractive: true)
                    .id(selected)
                    .frame(
                        width: UIScreen.main.bounds.width * 0.9,
                        height: UIScreen.main.bounds.height * 0.4
                    )
                    .cornerRadius(16)
                    .padding(.bottom, 10)
            }

            // MARK: - Avatar Picker
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
                .onChange(of: viewModel.username) {
                    viewModel.checkAvailability(for: viewModel.username)
                }

            // MARK: - Username Status
            if let available = viewModel.isUsernameAvailable {
                Text(available ? "Username is available" : "Username is taken")
                    .font(.subheadline)
                    .foregroundColor(available ? .green : .red)
            }

            if !viewModel.isUsernameClean && !viewModel.username.isEmpty {
                Text("Username contains inappropriate language.")
                    .foregroundColor(.red)
                    .font(.caption)
            }

            // MARK: - Update Button
            Button(action: {
                viewModel.updateProfile(loginViewModel: loginViewModel)
            }) {
                Text("Update Profile")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(viewModel.canUpdate ? Color.blue : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(!viewModel.canUpdate)
            .padding(.horizontal)

            // MARK: - Error Message
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Spacer()

            // MARK: - Logout Button
            Button(action: {
                loginViewModel.logout()
            }) {
                Text("Logout")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color(.red))
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            if viewModel.username.isEmpty && loginViewModel.currentUser != nil {
                viewModel.loadInitialState(from: loginViewModel)
            }
        }
    }
}
