struct AchievementLibrary {
    static let allAchievements: [Achievement] = [
        Achievement(title: "Guild Registration", description: "Welcome to the Adventurer’s Guild!", imageName: "person.crop.circle.badge.checkmark", attributeAffected: .constitution, points: 2),

        Achievement(title: "Walker", description: "Walked 1000 steps", imageName: "figure.walk", attributeAffected: .constitution, points: 1),
        Achievement(title: "Explorer", description: "Walked 5000 steps", imageName: "map.fill", attributeAffected: .dexterity, points: 2),
        Achievement(title: "Endurance Pro", description: "Walked 10,000 steps", imageName: "figure.hiking", attributeAffected: .constitution, points: 3),
        Achievement(title: "Sprinter", description: "Walked 100m in a minute", imageName: "figure.run", attributeAffected: .dexterity, points: 3),

        Achievement(title: "Bookworm", description: "Found a library", imageName: "book.fill", attributeAffected: .intelligence, points: 3),
        Achievement(title: "Fisherman", description: "Found a beach", imageName: "fish.fill", attributeAffected: .wisdom, points: 2),
        Achievement(title: "Naturalist", description: "Took a photo of a tree", imageName: "leaf.fill", attributeAffected: .wisdom, points: 2),

        Achievement(title: "Voyager", description: "Traveled at 30-40 km/h", imageName: "car.fill", attributeAffected: .dexterity, points: 2),
        Achievement(title: "Shuttle Explorer", description: "Traveled over 80 km/h", imageName: "airplane", attributeAffected: .dexterity, points: 3),

        Achievement(title: "Campfire Hero", description: "Found a campground", imageName: "flame.fill", attributeAffected: .constitution, points: 2),
        Achievement(title: "Night Owl", description: "Walked 2km after sunset", imageName: "moon.stars.fill", attributeAffected: .wisdom, points: 2),

        Achievement(title: "Cafe Hopper", description: "Visited 3 cafes in a day", imageName: "cup.and.saucer.fill", attributeAffected: .wisdom, points: 2), // ❗ corrected to wisdom
        Achievement(title: "Meditator", description: "Spent 30 minutes in a park", imageName: "tree.fill", attributeAffected: .wisdom, points: 3),
        Achievement(title: "Lifesaver", description: "Visited a hospital", imageName: "cross.case.fill", attributeAffected: .constitution, points: 3),

        Achievement(title: "Performer", description: "Visited a theater", imageName: "theatermasks.fill", attributeAffected: .intelligence, points: 2), // ❗ corrected to intelligence
        Achievement(title: "Storyteller", description: "Visited a museum", imageName: "building.columns.fill", attributeAffected: .intelligence, points: 2),

        Achievement(title: "Strength Booster", description: "Burned 200 active calories", imageName: "bolt.fill", attributeAffected: .strength, points: 4),
        Achievement(title: "Forest Whisperer", description: "Found a national park", imageName: "leaf.arrow.circlepath", attributeAffected: .wisdom, points: 2),
        Achievement(title: "Scholar", description: "Walked into a University zone", imageName: "graduationcap.fill", attributeAffected: .intelligence, points: 4),

        Achievement(title: "Trail Blazer", description: "Discovered 10 POIs in one day", imageName: "mappin.and.ellipse", attributeAffected: .dexterity, points: 2)
    ]
}
