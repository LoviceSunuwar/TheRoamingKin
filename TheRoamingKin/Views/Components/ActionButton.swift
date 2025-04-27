//
//  CustomButton.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 26/04/2025.
//

import SwiftUI

struct ActionButton: View {
    let text: String
    let backgroundColor: Color
    let foregroundColor: Color
    let imageName: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if let imageName = imageName {
                    Image(systemName: imageName) // use system icons for now
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }

                Text(text)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
        }
    }
}

#Preview {
    ActionButton(
        text: "Continue with Apple",
        backgroundColor: .black,
        foregroundColor: .white,
        imageName: "applelogo", // placeholder
        action: {}
    )
}
