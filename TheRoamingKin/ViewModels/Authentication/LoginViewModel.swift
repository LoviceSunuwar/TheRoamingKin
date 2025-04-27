//
//  LoginViewModel.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 26/04/2025.
//

import Foundation
import Combine

final class LoginViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private let authService = AuthService() // handle auth calls

    func signInWithGoogle() {
        authService.signInWithGoogle()
    }

    func signInWithFacebook() {
        authService.signInWithFacebook()
    }

    func signInWithApple() {
        authService.signInWithApple()
    }
}
