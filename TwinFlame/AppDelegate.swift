//
//  AppDelegate.swift
//  TwinFlame
//
//  Created by Julian Abhari on 1/31/26.
//

import UIKit
import FirebaseCore
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()

        // Play launch track once per app run.
        AudioLaunchPlayer.shared.playLaunchTrackIfNeeded()

        // Set UNUserNotificationCenter delegate to show alerts while app is foregrounded.
        UNUserNotificationCenter.current().delegate = self

        // Configure and schedule daily reminders (defaults to 12:12 local).
        Task {
            await DailyReminderScheduler.shared.configureAndScheduleDailyReminders()

            // TEST ONLY: Schedule a notification one minute from launch.
            // After you verify it arrives, keep this commented out.
            // await DailyReminderScheduler.shared.scheduleOneMinuteTestNotification()

            // DEBUG: print all scheduled notifications (including ours).
            // await DailyReminderScheduler.shared.debugPrintScheduledNotifications()
        }

        // DEBUG: One-time seeding of DailyMessages from local
//        Task {
//            do {
//                try await FirebaseManager.shared.seedDailyMessagesFromLocal()
//                print("DailyMessages seeded")
//            } catch {
//                print("Seeding failed: \(error)")
//            }
//        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application's current state in case it is terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Present notifications as alerts/sounds while app is in foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        if #available(iOS 14.0, *) {
            return [.banner, .list, .sound]
        } else {
            return [.alert, .sound]
        }
    }

    // Handle taps if needed (navigate into app, etc.)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        // You can inspect response.notification.request.identifier to route if needed.
    }
}
