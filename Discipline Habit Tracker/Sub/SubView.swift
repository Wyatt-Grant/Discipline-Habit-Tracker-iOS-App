//
//  SubView.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-28.
//

import SwiftUI

struct SubView: View {
  @StateObject var stateManager = StateManager()

  var body: some View {
    TabView {
      SubHabitTasks()
        .tabItem {
          Label("Tasks", systemImage: "checklist.checked")
        }
      SubPunishments()
        .tabItem {
          Label("Punishments", systemImage: "oar.2.crossed")
        }
      SubRewards()
        .tabItem {
          Label("Rewards", systemImage: "fireworks")
        }
      SubBank()
        .tabItem {
          Label("Bank", systemImage: "dollarsign")
        }
      SubOtherTab(stateManager: stateManager)
        .tabItem {
          Label("More", systemImage: "ellipsis")
        }
    }
    .onAppear {
      Task {
        await setAPN()
      }
    }
  }

  func setAPN() async {
    var request = createAuthRequest(url: base_url + "/api/setAPN?APN=\(APNToken)&device_name=iOS")
    request.httpMethod = "POST"
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      print("set \(APNToken)")
    }.resume()
  }
}
