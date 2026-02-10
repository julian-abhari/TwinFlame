//
//  MessageStore.swift
//  TwinFlame
//
//  Created by Julian Abhari on 2/8/26.
//

import Foundation

struct MessageStore {
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
    ]

    static let startDate: Date = {
        var dateComponents = DateComponents()
        dateComponents.year = 2026
        dateComponents.month = 2
        dateComponents.day = 8
        return Calendar.current.date(from: dateComponents) ?? Date()
    }()

    static func getTodaysMessage() -> String {
        if messages.isEmpty {
            return "TwinFlame"
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = calendar.startOfDay(for: startDate)

        let components = calendar.dateComponents([.day], from: start, to: today)
        let dayDifference = components.day ?? 0

        if dayDifference < 0 {
            return messages.first!
        }

        let messageIndex = dayDifference % messages.count
        return messages[messageIndex]
    }
}
