//
//  AttributesManager.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 02/05/2025.
//

import Foundation

@MainActor
class AttributesManager: ObservableObject {
    @Published var strength: Int = 10
    @Published var constitution: Int = 10
    @Published var dexterity: Int = 10
    @Published var intelligence: Int = 10
    @Published var wisdom: Int = 10

    private var lastClaimDates: [String: Date] = [:]

    func canClaim(for attribute: String) -> Bool {
        guard let lastClaimDate = lastClaimDates[attribute] else { return true }
        return !Calendar.current.isDateInToday(lastClaimDate)
    }

    func claimPoints(for attribute: String, points: Int) {
        guard canClaim(for: attribute) else {
            print("❌ Already claimed for \(attribute) today")
            return
        }

        switch attribute.lowercased() {
        case "strength": strength += points
        case "constitution": constitution += points
        case "dexterity": dexterity += points
        case "intelligence": intelligence += points
        case "wisdom": wisdom += points
        default: break
        }

        lastClaimDates[attribute] = Date()
        print("✅ \(points) points added to \(attribute.capitalized)")
    }
}
