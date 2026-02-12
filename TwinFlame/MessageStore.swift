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
        "I love the way you smile when I tell a joke so bad it's good.",
        "Every night when it's dark, I'll look up into the stars and think of you.",
        "The way your eyes light up when you look at me makes my heart melt.",
        "You have cutest and most bubbliest laugh.",
        "Your voice conveys so much care and sweetness when you reassure me.",
        "I love when I can really make you laugh so sincerely.",
        "I love when I randomly wake up to you watching me sleep",
        "Despite any fears you may have, I love how you always trust me in every adventure.",
        "I love how supportive you are when you remind me to be I'm proud of myself.",
        "You always encourage me to follow my passions, and that is one of the best gifts I could ever receive.",
        "Your kindness lets you see the best in everyone which brightens us all",
        "I love how you always make me feel safe and loved, no matter what.",
        "I've always felt us drawn to each other, starting when we hiked in Arkansas.",
        "Heaven is playing Zelda Windwaker together after ordering old school bagels.",
        "I've felt no worse pain than when I lost you, and something I loved was always out of reach.",
        "Life was magic when we started dating: Hot cocoa, snow dinos, playing yoshi.",
        "Remember when we cuddled on the McFarlin field as we started to freeze?",
        "I can't believe you ever thought you weren't smart enough, just look how far you've come.",
        "I love how adventurous and curious you've become.",
        "All the memories of when you were a HOST and then a peer-mentor always showed me that you are one of the bravest people I know.",
        "Remember when we checked into our first airbnb in hotsprings and spent three wonderful days exploring the trails and city?",
    ]

    static let startDate: Date = {
        var dateComponents = DateComponents()
        dateComponents.year = 2026
        dateComponents.month = 2
        dateComponents.day = 1
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

