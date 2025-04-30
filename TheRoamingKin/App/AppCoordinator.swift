//
//  AppCoordinator.swift
//  TheRoamingKin
//
import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var loginViewModel = LoginViewModel()
}
