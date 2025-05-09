//
//  AttributesService.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 02/05/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct AttributesService {
    static func uploadAttributes(strength: Int, constitution: Int, dexterity: Int, intelligence: Int, wisdom: Int) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        Task {
            let db = Firestore.firestore()
            let attributesData: [String: Any] = [
                "strength": strength,
                "constitution": constitution,
                "dexterity": dexterity,
                "intelligence": intelligence,
                "wisdom": wisdom
            ]

            do {
                try await db.collection("users")
                    .document(uid)
                    .collection("attributes")
                    .document("current")
                    .setData(attributesData, merge: true)

                print("✅ Attributes uploaded successfully.")
            } catch {
                print("❌ Error uploading attributes: \(error.localizedDescription)")
            }
        }
    }
}
