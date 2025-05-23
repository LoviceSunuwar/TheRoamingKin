//
//  ProfanityFilter.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 22/05/2025.
//

import Foundation

struct ProfanityFilter {
    static let bannedWords: Set<String> = [
        "fuck", "shit", "bitch", "asshole", "bastard", "slut", "dick", "nigger", "nigga", "cunt"
    ]

    static func containsProfanity(_ text: String) -> Bool {
        let normalized = normalize(text)
        let words = normalized.components(separatedBy: CharacterSet.alphanumerics.inverted)
        return words.contains { bannedWords.contains($0) }
    }

    static func normalize(_ text: String) -> String {
        var cleaned = text.lowercased()

        cleaned = cleaned.replacingOccurrences(of: "(.)\\1{2,}", with: "$1", options: .regularExpression)

        // Replace leetspeak and common substitutions
        let substitutions: [String: String] = [
            "0": "o", "1": "i", "3": "e", "4": "a", "5": "s", "7": "t",
            "@": "a", "$": "s", "!": "i", "€": "e"
        ]
        for (key, value) in substitutions {
            cleaned = cleaned.replacingOccurrences(of: key, with: value)
        }

        return cleaned
    }
}
