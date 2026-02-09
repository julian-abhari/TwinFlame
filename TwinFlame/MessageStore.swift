//
//  MessageStore.swift
//  TwinFlame
//
//  Created by Julian Abhari on 2/8/26.
//

import Foundation

struct MessageStore {
    static let messages: [String] = [
        "You are my sun, my moon, and all my stars.",
        "I love you more than words can wield the matter.",
        "To me, you are perfect.",
        "You have bewitched me, body and soul.",
        "I wish I had done everything on earth with you.",
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
