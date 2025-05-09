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

    @Published var strength: Int = 10
    @Published var constitution: Int = 10
    @Published var dexterity: Int = 10
    @Published var intelligence: Int = 10
    @Published var wisdom: Int = 10

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
                    self.strength = data["strength"] as? Int ?? 10
                    self.constitution = data["constitution"] as? Int ?? 10
                    self.dexterity = data["dexterity"] as? Int ?? 10
                    self.intelligence = data["intelligence"] as? Int ?? 10
                    self.wisdom = data["wisdom"] as? Int ?? 10
                    print("✅ Synced attributes from Firebase")
                }
            }
        } catch {
            print("❌ Failed to load attributes: \(error.localizedDescription)")
        }
    }

    func resetAttributes() {
        strength = 10
        constitution = 10
        dexterity = 10
        intelligence = 10
        wisdom = 10
    }
}
