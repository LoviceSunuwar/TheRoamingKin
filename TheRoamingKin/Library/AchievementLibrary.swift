struct AchievementLibrary {
    static let allAchievements: [Achievement] = [
        // 🔹 Simple "session-only" achievements (no photo, no POI needed)
        Achievement(
            title: "Guild Registration",
            description: "Welcome to the Adventurer’s Guild!",
            imageName: "person.crop.circle.badge.checkmark",
            attributeAffected: .constitution,
            points: 2
        ),

        // 🔹 Distance-based walking achievements
        Achievement(title: "Walker", description: "Walked 1000 steps", imageName: "figure.walk", attributeAffected: .constitution, points: 1),
        Achievement(title: "Explorer", description: "Walked 5000 steps", imageName: "map.fill", attributeAffected: .dexterity, points: 2),
        Achievement(title: "Endurance Pro", description: "Walked 10,000 steps", imageName: "figure.hiking", attributeAffected: .constitution, points: 3),
        Achievement(title: "Sprinter", description: "Walked 100m in a minute", imageName: "figure.run", attributeAffected: .dexterity, points: 3),

        // 🔹 Location + photo achievements (POI + image label)
        Achievement(
            title: "Scholar Advance",
            description: "Clicked a picture of a book near a University",
            imageName: "graduationcap.fill",
            attributeAffected: .intelligence,
            points: 3,
            triggerPOICategory: "university",
            requiredPhotoLabel: "book",
            requiredSessionActive: true
        ),
        Achievement(
            title: "Naturalist",
            description: "Clicked a picture of a tree near a Park",
            imageName: "leaf.fill",
            attributeAffected: .wisdom,
            points: 2,
            triggerPOICategory: "park",
            requiredPhotoLabel: "tree",
            requiredSessionActive: true
        ),
        Achievement(
            title: "Fisherman",
            description: "Clicked a picture of a fish near a Beach",
            imageName: "fish.fill",
            attributeAffected: .wisdom,
            points: 2,
            triggerPOICategory: "beach",
            requiredPhotoLabel: "fish",
            requiredSessionActive: true
        ),

        // 🔹 Location-only achievements (no photo needed, just nearby)
        Achievement(
            title: "Healer's Path",
            description: "Visited a Hospital",
            imageName: "cross.case.fill",
            attributeAffected: .constitution,
            points: 2,
            triggerPOICategory: "hospital",
            requiredSessionActive: true
        ),
        Achievement(
            title: "Cafe Lover",
            description: "Relaxed near a Cafe",
            imageName: "cup.and.saucer.fill",
            attributeAffected: .wisdom,
            points: 2,
            triggerPOICategory: "cafe",
            requiredSessionActive: true
        ),
        Achievement(
            title: "Museum Wanderer",
            description: "Visited a Museum",
            imageName: "building.columns.fill",
            attributeAffected: .intelligence,
            points: 2,
            triggerPOICategory: "museum",
            requiredSessionActive: true
        ),
        Achievement(
            title: "Forever learner",
            description: "You seek knowledge",
            imageName: "building.columns.fill",
            attributeAffected: .intelligence,
            points: 2,
            triggerPOICategory: "university",
            requiredSessionActive: true
        ),

        // 🔹 Photo-only achievements (photo anywhere, no POI needed)
        Achievement(
            title: "Leaf Collector",
            description: "Clicked a picture of a leaf anywhere",
            imageName: "leaf.fill",
            attributeAffected: .wisdom,
            points: 2,
            requiredPhotoLabel: "leaf",
            requiredSessionActive: true
        ),
        Achievement(
            title: "Ocean Explorer",
            description: "Clicked a picture of water anywhere",
            imageName: "drop.fill",
            attributeAffected: .wisdom,
            points: 2,
            requiredPhotoLabel: "water",
            requiredSessionActive: true
        ),
        Achievement(
            title: "Sky Gazer",
            description: "Clicked a picture of clouds anywhere",
            imageName: "cloud.fill",
            attributeAffected: .wisdom,
            points: 2,
            requiredPhotoLabel: "cloud",
            requiredSessionActive: true
        ),

        // Health Based:

        Achievement(
            title: "First Steps",
            description: "Walked 500 steps in a session",
            imageName: "figure.walk",
            attributeAffected: .dexterity,
            points: 3,
            requiredSessionActive: true,
            healthMetricType: .steps,
            requiredHealthValue: 500
        ),
        Achievement(
            title: "Marathoner",
            description: "Walked 5 km in a session",
            imageName: "figure.run",
            attributeAffected: .dexterity,
            points: 5,
            requiredSessionActive: true,
            healthMetricType: .distance,
            requiredHealthValue: 5000 // meters
        ),
        Achievement(
            title: "Energy Burner",
            description: "Burned 500 calories in a session",
            imageName: "flame.fill",
            attributeAffected: .strength,
            points: 4,
            requiredSessionActive: true,
            healthMetricType: .calories,
            requiredHealthValue: 500
        ),

    ]

}
