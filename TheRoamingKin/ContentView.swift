//
//  ContentView.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 26/04/2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        NavigationStack {
            switch viewModel.authState {
            case .unauthenticated:
                LoginView(viewModel: viewModel)
                
            case .needsUsername:
                UsernamePickView(loginViewModel: viewModel)
                
            case .authenticated:
                HomeView()
            }
        }
    }
}
