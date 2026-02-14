import Foundation
import UserNotifications

final class DailyReminderScheduler {

    static let shared = DailyReminderScheduler()

    // Identifier prefix so we only manage our own pending requests.
    private let identifierPrefix = "daily_reminder_"

    // Playful captions to rotate through (titles or bodies as desired).
    private let captions: [String] = [
        "Something special is here for you",
        "Take a quick break, you've earned it",
        "Here's something that may cheer you up",
        "Hope you're having a great day",
        "Your daily sparkle is here",
        "Take a moment for yourself",
        "A quick note to make you smile"
    ]

    // Public entry: request auth and (re)schedule the next batch.
    func configureAndScheduleDailyReminders(
        daysToSchedule: Int = 30,
        fireHour: Int = 12,
        fireMinute: Int = 12
    ) async {
        let granted = await requestAuthorizationIfNeeded()
        guard granted else {
            // Authorization denied or not granted; nothing to schedule.
            return
        }

        // Remove previously scheduled reminders we own, then schedule a fresh set.
        await removePendingDailyReminders()
        await scheduleNextDays(daysToSchedule, hour: fireHour, minute: fireMinute)
    }

    // Schedules a single test notification for one minute from now.
    // Call this during testing; keep the call commented out in production.
    func scheduleOneMinuteTestNotification() async {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = "Test Reminder"
        content.body = "This is a test notification scheduled one minute from launch."
        content.sound = .default

        let fireDate = Date().addingTimeInterval(60)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(60, fireDate.timeIntervalSinceNow), repeats: false)

        let request = UNNotificationRequest(identifier: "\(identifierPrefix)test_\(UUID().uuidString)", content: content, trigger: trigger)
        do {
            try await center.add(request)
        } catch {
            print("DailyReminderScheduler: Failed to schedule test notification: \(error)")
        }
    }

    // MARK: - Debug

    // Prints all pending scheduled notifications (not just ours)
    func debugPrintScheduledNotifications() async {
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()

        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = .current
        df.dateStyle = .medium
        df.timeStyle = .short

        print("DailyReminderScheduler: Pending notifications count = \(pending.count)")
        for req in pending {
            let isOurs = req.identifier.hasPrefix(identifierPrefix)
            let title = req.content.title
            let body = req.content.body

            var triggerDescription = "Unknown trigger"
            var nextDateDescription = "n/a"

            if let trigger = req.trigger {
                switch trigger {
                case let cal as UNCalendarNotificationTrigger:
                    triggerDescription = "UNCalendarNotificationTrigger(repeats=\(cal.repeats))"
                    if let next = cal.nextTriggerDate() {
                        nextDateDescription = df.string(from: next)
                    }
                case let ti as UNTimeIntervalNotificationTrigger:
                    triggerDescription = "UNTimeIntervalNotificationTrigger(interval=\(ti.timeInterval), repeats=\(ti.repeats))"
                    if let next = ti.nextTriggerDate() {
                        nextDateDescription = df.string(from: next)
                    }
                case let loc as UNLocationNotificationTrigger:
                    triggerDescription = "UNLocationNotificationTrigger(repeats=\(loc.repeats))"
                    // UNLocationNotificationTrigger doesn’t provide nextTriggerDate()
                default:
                    triggerDescription = String(describing: type(of: trigger))
                }
            }

            print("""
            - id: \(req.identifier)\(isOurs ? " [ours]" : "")
              title: "\(title)"
              body: "\(body)"
              trigger: \(triggerDescription)
              nextFire: \(nextDateDescription)
            """)
        }
    }

    // MARK: - Private helpers

    private func requestAuthorizationIfNeeded() async -> Bool {
        let center = UNUserNotificationCenter.current()

        let currentSettings = await center.notificationSettings()
        switch currentSettings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            do {
                try await center.requestAuthorization(options: [.alert, .sound, .badge])
                let updated = await center.notificationSettings()
                switch updated.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    return true
                default:
                    return false
                }
            } catch {
                print("DailyReminderScheduler: Authorization request failed: \(error)")
                return false
            }
        @unknown default:
            return false
        }
    }

    private func scheduleNextDays(_ count: Int, hour: Int, minute: Int) async {
        guard count > 0 else { return }

        let center = UNUserNotificationCenter.current()
        let calendar = Calendar.current
        let now = Date()

        // Compute the first fire date (today at hour:minute, or tomorrow if time already passed).
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = hour
        components.minute = minute
        components.second = 0

        let todayTarget = calendar.date(from: components) ?? now
        let firstDate = (todayTarget > now) ? todayTarget : calendar.date(byAdding: .day, value: 1, to: todayTarget) ?? now.addingTimeInterval(24 * 60 * 60)

        for i in 0..<count {
            guard let fireDate = calendar.date(byAdding: .day, value: i, to: firstDate) else { continue }

            // Rotate captions across days.
            let captionIndex = i % captions.count
            let caption = captions[captionIndex]

            let content = UNMutableNotificationContent()
            content.title = caption
            content.body = "Open TwinFlame to see today’s message."
            content.sound = .default

            // Use a calendar trigger for the exact local date/time (no repeats so we can vary content).
            let triggerDate = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

            let id = identifierFor(date: fireDate)
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

            do {
                try await center.add(request)
            } catch {
                print("DailyReminderScheduler: Failed to schedule \(id): \(error)")
            }
        }
    }

    private func removePendingDailyReminders() async {
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()
        let ours = pending
            .map { $0.identifier }
            .filter { $0.hasPrefix(identifierPrefix) }

        guard !ours.isEmpty else { return }
        center.removePendingNotificationRequests(withIdentifiers: ours)
    }

    private func identifierFor(date: Date) -> String {
        // Format date to YYYYMMDD for stable identifiers per day.
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyyMMdd"
        return "\(identifierPrefix)\(formatter.string(from: date))"
    }
}
