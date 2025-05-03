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
    private let achievementManager = AchievementManager()

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
                    print("✅ Google sign-in success. UID: \(user.uid)")
                    guard let self = self else { return }

                    self.authService.checkIfUserExistsPublisher(uid: user.uid)
                        .receive(on: DispatchQueue.main)
                        .sink(
                            receiveCompletion: { _ in },
                            receiveValue: { [weak self] exists in
                                print("📢 checkIfUserExistsPublisher result: \(exists)")
                                self?.authState = exists ? .authenticated : .needsUsername
                                print("🔵 authState updated to: \(self?.authState ?? .unauthenticated)")
                            }
                        )
                        .store(in: &self.cancellables)
                }
            )
            .store(in: &cancellables)
    }

    func markAuthenticated() {
        authState = .authenticated

        achievementManager.unlockAchievement(
                    title: AchievementLibrary.allAchievements.first(where: { $0.title == "Guild Registration" })?.title ?? "Guild Registration",
                    description: AchievementLibrary.allAchievements.first(where: { $0.title == "Guild Registration" })?.description ?? "Welcome!",
                    imageName: AchievementLibrary.allAchievements.first(where: { $0.title == "Guild Registration" })?.imageName ?? "person.crop.circle.badge.checkmark"
                )

                shouldShowWelcomeToast = true
    }

    func signInWithFacebook() {
        print("TODO: Facebook Sign-In not yet implemented")
    }

    func signInWithApple() {
        print("TODO: Apple Sign-In not yet implemented")
    }

    func logout() {
        authService.logout()
        authState = .unauthenticated
    }

}
