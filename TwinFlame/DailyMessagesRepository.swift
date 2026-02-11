// DailyMessagesRepository.swift

import Foundation

public protocol DailyMessagesRepository: AnyObject {
    func fetchDailyMessage(for index: Int) async throws -> DailyMessage
    func upsertDailyMessage(for index: Int, text: String) async throws
    func seedDailyMessagesFromLocal() async throws
    // New: total number of daily messages available (primarily from Firestore)
    func dailyMessagesCount() async throws -> Int
}

