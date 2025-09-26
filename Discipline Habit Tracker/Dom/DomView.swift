//
//  TaskView.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-19.
//

import SwiftUI

struct DomView: View {
  @StateObject var stateManager = StateManager()

  var body: some View {
    TabView {
      DomHabitTasks()
        .tabItem {
          Label("Tasks", systemImage: "checklist.checked")
        }
      DomPunishments()
        .tabItem {
          Label("Punishments", systemImage: "oar.2.crossed")
        }
      DomRewards()
        .tabItem {
          Label("Rewards", systemImage: "fireworks")
        }
      DomMessages()
        .tabItem {
          Label("Messages", systemImage: "text.bubble")
        }
      DomOtherTab(stateManager: stateManager)
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
