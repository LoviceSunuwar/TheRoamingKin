//
//  AuthService.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 26/04/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import FirebaseAuthCombineSwift
import UIKit
import Combine
import FirebaseCore

final class AuthService {
    private let db = Firestore.firestore()
@MainActor
    func signInWithGooglePublisher() -> AnyPublisher<User, Error> {
        Future { promise in
            Task {
                do {
                    guard let clientID = FirebaseApp.app()?.options.clientID else {
                        promise(.failure(AuthError.clientIDNotFound))
                        return
                    }
                    
                    let config = GIDConfiguration(clientID: clientID)
                    GIDSignIn.sharedInstance.configuration = config

                    // 👇 👇 👇 Force this block onto MainActor 👇 👇 👇
                    let rootViewController = try await MainActor.run {
                        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                              let rootVC = windowScene.windows.first?.rootViewController else {
                            throw AuthError.rootViewControllerNotFound
                        }
                        return rootVC
                    }
                    
                    let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

                    guard let idToken = result.user.idToken?.tokenString else {
                        promise(.failure(AuthError.missingIDToken))
                        return
                    }

                    let accessToken = result.user.accessToken.tokenString

                    let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

                    // ✅ Firebase login
                    let authResult = try await Auth.auth().signIn(with: credential)
                    promise(.success(authResult.user))

                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }


    func checkIfUserExistsPublisher(uid: String) -> AnyPublisher<Bool, Never> {
        Future { promise in
            self.db.collection("users").document(uid).getDocument { snapshot, error in
                if let snapshot = snapshot {
                    promise(.success(snapshot.exists))
                } else {
                    promise(.success(false))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func saveUserToFirestorePublisher(user: User, username: String, avatarURL: String) -> AnyPublisher<Void, Error> {
        Future { promise in
            var userData: [String: Any] = [
                "uid": user.uid,
                "email": user.email ?? "",
                "displayName": user.displayName ?? "",
                "photoURL": user.photoURL?.absoluteString ?? "",
                "provider": "google",
                "lastLogin": FieldValue.serverTimestamp(),
                "username": username,
                "avatarURL": avatarURL
            ]

            self.db.collection("users").document(user.uid).setData(userData, merge: true) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    
    func checkUsernameAvailablePublisher(username: String) -> AnyPublisher<Bool, Never> {
        Future { promise in
            self.db.collection("users")
                .whereField("username", isEqualTo: username)
                .getDocuments { snapshot, error in
                    if let snapshot = snapshot, snapshot.documents.isEmpty {
                        promise(.success(true)) // ✅ Username available
                    } else {
                        promise(.success(false)) // ❌ Username already taken
                    }
                }
        }
        .eraseToAnyPublisher()
    }


    func signInWithFacebook() {
        // TODO: Implement Facebook sign in
        print("TODO: Facebook Sign-In not yet implemented")
    }

    func signInWithApple() {
        // TODO: Implement Apple sign in
        print("TODO: Apple Sign-In not yet implemented")
    }

    // MARK: - Private
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - Custom Errors
enum AuthError: Error {
    case clientIDNotFound
    case rootViewControllerNotFound
    case missingGoogleSignInResult
    case missingIDToken
    case unknown
}
