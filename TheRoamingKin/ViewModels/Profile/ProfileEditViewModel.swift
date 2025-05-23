//
//  ProfileEditViewModel.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 21/05/2025.
//

import Foundation
import Combine

class ProfileEditViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var selectedAvatar: String?
    @Published var isUsernameAvailable: Bool?
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    @MainActor
    func loadInitialState(from loginViewModel: LoginViewModel) {
        self.username = loginViewModel.currentUser?.username ?? ""
        self.selectedAvatar = loginViewModel.currentUser?.avatar
        checkAvailability(for: self.username)
    }

    func checkAvailability(for username: String) {
        guard !username.isEmpty else {
            isUsernameAvailable = nil
            return
        }

        // Fake async check (replace with Firestore or backend call)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.isUsernameAvailable = (username.lowercased() != "takenuser")
        }
    }

    func updateProfile(loginViewModel: LoginViewModel) {
        guard canUpdate else {
            if !isUsernameClean {
                errorMessage = "Please choose a clean username."
            }
            return
        }

        Task {
            do {
                try await loginViewModel.updateUserProfile(
                    newUsername: username,
                    newAvatar: selectedAvatar ?? ""
                )
            } catch {
                errorMessage = "Failed to update profile. Please try again."
            }
        }
    }

    var isUsernameClean: Bool {
        !ProfanityFilter.containsProfanity(username)
    }

    var canUpdate: Bool {
        if let available = isUsernameAvailable {
            return available && !(username.isEmpty || selectedAvatar == nil) && isUsernameClean
        }
        return false
    }
}
