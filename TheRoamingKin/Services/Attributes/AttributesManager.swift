//
//  AttributesManager.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 02/05/2025.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class AttributesManager: ObservableObject {
    static let shared = AttributesManager()

    @Published var strength: Int = 0
    @Published var constitution: Int = 0
    @Published var dexterity: Int = 0
    @Published var intelligence: Int = 0
    @Published var wisdom: Int = 0

    private let db = Firestore.firestore()

    func claimPoints(for attribute: String, points: Int) {
        switch attribute {
        case "strength":
            strength += points
        case "constitution":
            constitution += points
        case "dexterity":
            dexterity += points
        case "intelligence":
            intelligence += points
        case "wisdom":
            wisdom += points
        default:
            break
        }
    }

    func loadAttributes() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        do {
            let document = try await db.collection("users")
                .document(uid)
                .collection("attributes")
                .document("current")
                .getDocument()

            if let data = document.data() {
                DispatchQueue.main.async {
                    self.strength = data["strength"] as? Int ?? 0
                    self.constitution = data["constitution"] as? Int ?? 0
                    self.dexterity = data["dexterity"] as? Int ?? 0
                    self.intelligence = data["intelligence"] as? Int ?? 0
                    self.wisdom = data["wisdom"] as? Int ?? 0
                    print("✅ Synced attributes from Firebase")
                }
            }
        } catch {
            print("❌ Failed to load attributes: \(error.localizedDescription)")
        }
    }

    func resetAttributes() {
        strength = 0
        constitution = 0
        dexterity = 0
        intelligence = 0
        wisdom = 0
    }
}
