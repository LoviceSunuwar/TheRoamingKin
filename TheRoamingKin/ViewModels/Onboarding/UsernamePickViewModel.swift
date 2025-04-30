import Foundation
import SwiftUI
import Combine
import FirebaseAuth

@MainActor
final class UsernamePickViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var selectedAvatar: String? = nil
    @Published var isUsernameAvailable: Bool? = nil
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?

    private let authService = AuthService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupUsernameAvailabilityCheck()
    }

    private func setupUsernameAvailabilityCheck() {
        $username
            .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] newUsername in
                self?.validateUsernameAvailability(username: newUsername)
            }
            .store(in: &cancellables)
    }

    private func validateUsernameAvailability(username: String) {
        guard username.count >= 6, username.count <= 24 else {
            self.isUsernameAvailable = nil
            return
        }

        authService.checkUsernameAvailablePublisher(username: username)
            .receive(on: DispatchQueue.main)
            .sink { _ in }
            receiveValue: { [weak self] available in
                self?.isUsernameAvailable = available
            }
            .store(in: &cancellables)
    }

    func saveProfile(loginViewModel: LoginViewModel) {
        guard let user = Auth.auth().currentUser else {
            self.errorMessage = "No authenticated user."
            return
        }

        guard let avatarURL = selectedAvatar else {
            self.errorMessage = "Please select an avatar."
            return
        }

        isSaving = true
        errorMessage = nil

        authService.saveUserToFirestorePublisher(user: user, username: username, avatarURL: avatarURL)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isSaving = false
                if case .failure(let error) = completion {
                    self?.errorMessage = "Failed to save: \(error.localizedDescription)"
                }
            } receiveValue: { _ in
                loginViewModel.markAuthenticated()
            }
            .store(in: &cancellables)
    }
}

