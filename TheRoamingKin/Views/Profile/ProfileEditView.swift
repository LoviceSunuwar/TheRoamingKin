import SwiftUI

struct ProfileEditView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @StateObject private var viewModel = ProfileEditViewModel()

    private let avatars = (0...8).map { String(format: "%02d", $0) }

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

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

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(avatars, id: \.self) { avatar in
                        Circle()
                            .stroke(viewModel.selectedAvatar == avatar ? Color.green : Color.black, lineWidth: 2)
                            .background(Circle().fill(Color.gray.opacity(0.2)))
                            .frame(width: 60, height: 60)
                            .overlay(Text(avatar).foregroundColor(.black))
                            .onTapGesture {
                                viewModel.selectedAvatar = avatar
                            }
                    }
                }
                .padding(.horizontal)
            }

            TextField("Username", text: $viewModel.username)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .frame(height: 40)
                .onChange(of: viewModel.username) {
                    viewModel.checkAvailability(for: viewModel.username)
                }

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
