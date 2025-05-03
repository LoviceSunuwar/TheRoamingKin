//
//  AchievementLibrary.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 02/05/2025.
//

import Foundation

struct AchievementLibrary {
    static let allAchievements: [Achievement] = [
        Achievement(title: "Walker", description: "Walked 1000 steps", imageName: "figure.walk"),
        Achievement(title: "Explorer", description: "Walked 5000 steps", imageName: "map.fill"),
        Achievement(title: "Endurance Pro", description: "Walked 10,000 steps", imageName: "figure.hiking"),
        Achievement(title: "Sprinter", description: "Walked 100m in a minute", imageName: "figure.run"),
        Achievement(title: "Bookworm", description: "Found a library and clicked a book", imageName: "book.fill"),
        Achievement(title: "Fisherman", description: "Found a beach and clicked a fish", imageName: "fish.fill"),
        Achievement(title: "Naturalist", description: "Took a photo of a tree", imageName: "leaf.fill"),
        Achievement(title: "Voyager", description: "Traveled at 30-40 km/h", imageName: "car.fill"),
        Achievement(title: "Shuttle Explorer", description: "Traveled over 80 km/h", imageName: "airplane"),
        Achievement(title: "Campfire Hero", description: "Found a campground", imageName: "flame.fill"),
        Achievement(title: "Night Owl", description: "Walked 2km after sunset", imageName: "moon.stars.fill"),
        Achievement(title: "Cafe Hopper", description: "Visited 3 cafes in a day", imageName: "cup.and.saucer.fill"),
        Achievement(title: "Meditator", description: "Spent 30 minutes in a park", imageName: "tree.fill"),
        Achievement(title: "Lifesaver", description: "Visited a hospital", imageName: "cross.case.fill"),
        Achievement(title: "Performer", description: "Visited a theater", imageName: "theatermasks.fill"),
        Achievement(title: "Storyteller", description: "Visited a museum", imageName: "building.columns.fill"),
        Achievement(title: "Strength Booster", description: "Burned 200 active calories", imageName: "bolt.fill"),
        Achievement(title: "Forest Whisperer", description: "Found a national park", imageName: "leaf.arrow.circlepath"),
        Achievement(title: "Scholar", description: "Walked into a University zone", imageName: "graduationcap.fill"),
        Achievement(title: "Trail Blazer", description: "Discovered 10 POIs in one day", imageName: "mappin.and.ellipse")
    ]
}
