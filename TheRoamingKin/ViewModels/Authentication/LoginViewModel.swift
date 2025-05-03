import Foundation
import Combine
import FirebaseAuth

enum AuthState {
    case unauthenticated
    case authenticated
    case needsUsername
}

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var authState: AuthState = .unauthenticated
    @Published var shouldShowWelcomeToast: Bool = false

    private let authService = AuthService()
    private var cancellables = Set<AnyCancellable>()

    func signInWithGoogle() {
        authService.signInWithGooglePublisher()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("🔥 Google sign-in failed: \(error.localizedDescription)")
                        self?.authState = .unauthenticated
                    }
                },
                receiveValue: { [weak self] user in
                    guard let self else { return }
                    print("✅ Google sign-in success. UID: \(user.uid)")

                    self.authService.checkIfUserExistsPublisher(uid: user.uid)
                        .receive(on: DispatchQueue.main)
                        .sink(
                            receiveCompletion: { _ in },
                            receiveValue: { [weak self] exists in
                                guard let self else { return }
                                self.authState = exists ? .authenticated : .needsUsername
                                print("🔵 authState updated to: \(self.authState)")
                                if self.authState == .authenticated {
                                    self.loadUserData()
                                }
                            }
                        )
                        .store(in: &self.cancellables)
                }
            )
            .store(in: &cancellables)
    }

    func markAuthenticated() {
        authState = .authenticated
        if let guildRegistrationAchievement = AchievementLibrary.allAchievements.first(where: { $0.title == "Guild Registration" }) {
            AchievementUnlockManager.shared.unlock(
                achievement: guildRegistrationAchievement,
                attributesManager: AttributesManager.shared,
                scenePhase: .active
            )
        }
        shouldShowWelcomeToast = true
    }

    private func loadUserData() {
        Task {
            await AchievementUnlockManager.shared.loadUnlockedAchievements()
            await AttributesManager.shared.loadAttributes()
        }
    }

    func logout() {
        authService.logout()
        authState = .unauthenticated
        AchievementUnlockManager.shared.resetUnlockedAchievements()
        AttributesManager.shared.resetAttributes()
    }



    func signInWithFacebook() {
        print("🟦 Facebook Sign-In not yet implemented. Placeholder function called.")
        // Future: Integrate Facebook SDK login flow here
    }

    func signInWithApple() {
        print("⚫️ Apple Sign-In not yet implemented. Placeholder function called.")
        // Future: Integrate Apple Sign-In flow here
    }

}




func signInWithFacebook() {
    print("🟦 Facebook Sign-In not yet implemented. Placeholder function called.")
    // Future: Integrate Facebook SDK login flow here
}

func signInWithApple() {
    print("⚫️ Apple Sign-In not yet implemented. Placeholder function called.")
    // Future: Integrate Apple Sign-In flow here
}
