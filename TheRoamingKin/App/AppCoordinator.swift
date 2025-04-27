//
//  AppCoordinator.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 26/04/2025.
//

import SwiftUI
import Combine

final class AppCoordinator: ObservableObject {

    func start() -> some View {
        LoginView() // default screen for now
    }
}
