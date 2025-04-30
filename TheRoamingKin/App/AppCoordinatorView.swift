////
////  AppCoordinatorView.swift
////  TheRoamingKin
////
////  Created by Lovice Sunuwar on 27/04/2025.
////
////  AppCoordinatorView.swift
////  TheRoamingKin
////
////  Created by Lovice Sunuwar on 27/04/2025.
//import SwiftUI
//
//struct AppCoordinatorView: View {
//    @EnvironmentObject private var coordinator: AppCoordinator //
//    
//    var body: some View {
//        switch coordinator.loginViewModel.authState {
//        case .unauthenticated:
//            LoginView(viewModel: <#LoginViewModel#>)
//                .environmentObject(coordinator.loginViewModel)
//                .onAppear {
//                    print("🟥 Showing LoginView (authState = unauthenticated)")
//                }
//
//        case .needsUsername:
//            UsernamePickView()
//                .environmentObject(coordinator.loginViewModel)
//                .onAppear {
//                    print("🟨 Showing UsernamePickView (authState = needsUsername)")
//                }
//
//        case .authenticated:
//            NavigationStack {
//                HomeView()
//                    .environmentObject(coordinator.loginViewModel)
//                    .onAppear {
//                        print("🟩 Showing HomeView (authState = authenticated)")
//                    }
//            }
//        }
//    }
//}
