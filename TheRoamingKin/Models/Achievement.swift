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
    var id: UUID = UUID()
    let title: String
    let description: String
    let imageName: String
    let attributeAffected: AttributeType
    let points: Int
    var triggerPOICategory: String? = nil
    var requiredPhotoLabel: String? = nil
    var requiredSessionActive: Bool = false

    enum AttributeType: String, Codable {
        case strength
        case constitution
        case dexterity
        case intelligence
        case wisdom
        case none
    }
}
