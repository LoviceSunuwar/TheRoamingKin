//
//  Achievement.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 03/05/2025.
//

import Foundation
import UserNotifications
import SwiftUI

// Achievement.swift

import Foundation

struct Achievement: Identifiable, Codable, Equatable {
    var id: UUID {
        UUID(uuidString: UUIDNamespace.makeUUID(from: title)) ?? UUID()
    }
    let title: String
    let description: String
    let imageName: String
    let attributeAffected: AttributeType
    let points: Int
    var triggerPOICategory: String? = nil
    var requiredPhotoLabel: String? = nil
    var requiredSessionActive: Bool = false
    var healthMetricType: HealthMetricType = .none
    var requiredHealthValue: Double? = nil

    enum AttributeType: String, Codable {
        case strength
        case constitution
        case dexterity
        case intelligence
        case wisdom
        case none
    }

    enum HealthMetricType: String, Codable {
        case steps
        case distance
        case calories
        case none
    }
}
