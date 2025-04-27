//
//  ContentView.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 26/04/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack { // basic navstack for screen flow
            VStack {
                Text("The Roaming Kin")
                    .font(.largeTitle.bold())
                    .padding()

                Text("Welcome to the adventure!")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    ContentView()
}
