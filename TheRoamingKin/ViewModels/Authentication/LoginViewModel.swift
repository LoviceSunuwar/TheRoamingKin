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
    @Published var isFirstTimeLogin: Bool = false

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
                                self.storeLoginTimestamp()
                                self.isFirstTimeLogin = !exists
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
        shouldShowWelcomeToast = true

        // Always unlock Guild Registration
        if let guildRegistrationAchievement = AchievementLibrary.allAchievements.first(where: { $0.title == "Guild Registration" }) {
            AchievementUnlockManager.shared.unlock(
                achievement: guildRegistrationAchievement,
                attributesManager: AttributesManager.shared,
                scenePhase: .active
            )
        }

        Task {
            if !isFirstTimeLogin {
                await AchievementUnlockManager.shared.loadUnlockedAchievements()
            } else {
                // ✅ SKIPPED loading achievements but we MUST mark it as loaded!
                AchievementUnlockManager.shared.isLoaded = true
                print("🆕 New user — skipping Firestore achievement fetch, isLoaded = true")
            }

            await AttributesManager.shared.loadAttributes()
        }
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

    // MARK: - Session Timeout Logic

    func storeLoginTimestamp() {
        let timestamp = Date().timeIntervalSince1970
        UserDefaults.standard.set(timestamp, forKey: "lastLoginTimestamp")
    }

    func hasSessionExpired() -> Bool {
        let timeout: TimeInterval = 1_209_600
        let now = Date().timeIntervalSince1970
        let lastLogin = UserDefaults.standard.double(forKey: "lastLoginTimestamp")
        return (now - lastLogin) > timeout
    }

    func checkSessionValidityOnLaunch() {
        if let user = Auth.auth().currentUser {
            if hasSessionExpired() {
                print("⏰ Session expired. Logging out.")
                logout()
                UserDefaults.standard.removeObject(forKey: "lastLoginTimestamp")
            } else {
                print("✅ Session still valid. Auto login.")
                authState = .authenticated
                loadUserData()
            }
        } else {
            print("🔒 No Firebase user found.")
            authState = .unauthenticated
        }
    }


}
