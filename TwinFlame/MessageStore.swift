//
//  MessageStore.swift
//  TwinFlame
//
//  Created by Julian Abhari on 2/8/26.
//

import Foundation

struct MessageStore {
    // Local fallback messages; still used as seed/fallback text.
    static let messages: [String] = [
        "Goog",
        "Goog",
    ]

    static let startDate: Date = {
        var dateComponents = DateComponents()
        dateComponents.year = 2026
        dateComponents.month = 2
        dateComponents.day = 8
        return Calendar.current.date(from: dateComponents) ?? Date()
    }()

    // Prefer remote count; fallback to local messages.count
    static func preferredMessagesCount(using repository: DailyMessagesRepository) async -> Int {
        do {
            let remoteCount = try await repository.dailyMessagesCount()
            if remoteCount > 0 {
                return remoteCount
            }
        } catch {
            // swallow and fall back
        }
        return messages.count
    }

    // Expose today's index as a single source of truth, preferring remote count
    static func messageIndexForToday(using repository: DailyMessagesRepository) async -> Int {
        let count = await preferredMessagesCount(using: repository)
        guard count > 0 else { return 0 }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = calendar.startOfDay(for: startDate)

        let components = calendar.dateComponents([.day], from: start, to: today)
        let dayDifference = components.day ?? 0

        if dayDifference < 0 {
            return 0
        }

        return dayDifference % count
    }

    // Synchronous fallback index (uses local messages only)
    static func messageIndexForTodayLocalOnly() -> Int {
        guard !messages.isEmpty else { return 0 }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = calendar.startOfDay(for: startDate)

        let components = calendar.dateComponents([.day], from: start, to: today)
        let dayDifference = components.day ?? 0

        if dayDifference < 0 {
            return 0
        }

        return dayDifference % messages.count
    }

    // Return the local message for a specific index (safe with fallback)
    static func messageForIndex(_ index: Int) -> String {
        guard !messages.isEmpty else { return "TwinFlame" }
        let safeIndex = ((index % messages.count) + messages.count) % messages.count
        return messages[safeIndex]
    }

    // Async helper to get today's index and message, preferring remote count
    static func getTodaysIndexAndLocalFallback(using repository: DailyMessagesRepository) async -> (index: Int, localText: String) {
        let index = await messageIndexForToday(using: repository)
        return (index, messageForIndex(index))
    }
}

