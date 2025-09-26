//
//  Discipline_Habit_TrackerApp.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-18.
//

import SwiftUI

@main
struct Discipline_Habit_TrackerApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self)
  var appDelegate

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    // Register for remote notifications
    UNUserNotificationCenter.current().delegate = self
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
      granted, error in
      if granted {
        DispatchQueue.main.async {
          application.registerForRemoteNotifications()
        }
      }
    }
    return true
  }

  func application(
    _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    // Send the device token to your server for push notification setup
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    print("Device Token:", token)
    APNToken = token
  }

  func application(
    _ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("Failed to register for remote notifications:", error.localizedDescription)
  }
}

//class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//          // Add a print statement to confirm that the method is being called
//          print("AppDelegate didFinishLaunchingWithOptions method called")
//          return true
//    }
//
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
//        print("Device Token: \(token)")
//    }
//
//    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//        print("Failed to register for remote notifications: \(error.localizedDescription)")
//    }
//}
