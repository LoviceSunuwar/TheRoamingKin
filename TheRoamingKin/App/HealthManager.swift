//
//  HealthManager.swift
//  TheRoamingKin
//
//  Created by Lovice Sunuwar on 02/05/2025.
//

import Foundation
import HealthKit

@MainActor
class HealthManager {
    private let healthStore = HKHealthStore()

    init() {}

    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("❌ Health data not available")
            return
        }

        let typesToRead: Set = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]

        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            print("✅ HealthKit authorization granted")
        } catch {
            print("❌ HealthKit authorization failed: \(error.localizedDescription)")
        }
    }

    func fetchTodayStepCount() async -> Double {
        await fetchSumQuantity(for: .stepCount)
    }

    func fetchTodayActiveCalories() async -> Double {
        await fetchSumQuantity(for: .activeEnergyBurned)
    }

    func fetchTodayWalkingDistance() async -> Double {
        await fetchSumQuantity(for: .distanceWalkingRunning)
    }

    private func fetchSumQuantity(for identifier: HKQuantityTypeIdentifier) async -> Double {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            return 0
        }

        let now = Date()
        guard let startOfDay = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: now)) else {
            return 0
        }

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                guard let result = result, let sum = result.sumQuantity() else {
                    continuation.resume(returning: 0)
                    return
                }

                let unit: HKUnit
                switch identifier {
                case .stepCount:
                    unit = HKUnit.count()
                case .activeEnergyBurned:
                    unit = HKUnit.kilocalorie()
                case .distanceWalkingRunning:
                    unit = HKUnit.meter()
                default:
                    unit = HKUnit.count()
                }

                let value = sum.doubleValue(for: unit)
                continuation.resume(returning: value)
            }

            healthStore.execute(query)
        }
    }
}
