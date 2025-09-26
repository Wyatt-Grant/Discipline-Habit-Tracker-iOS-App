//
//  ContentView.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-18.
//

import SwiftUI

public let ROLE_DOM = 1
public let ROLE_SUB = 2

public var base_url = "https://discipline.dedyn.io"

public var user_token = ""
public var user_id = 0
public var user_full_name = ""
public var user_name = ""
public var user_role = 0

public var APNToken = ""

public var theme = Color.red

public var points = -999_999_999
public var bank = -1
public var assigned = -1
public var remaining = -1

class StateManager: ObservableObject {
  @Published private(set) var isLoggedIn = false
  func changeLogin(state: Bool) {
    withAnimation {
      isLoggedIn = state
    }
  }
}

struct ContentView: View {
  @StateObject var stateManager = StateManager()
  @State private var selectedMode = UserDefaults.standard.string(forKey: "COLOR_MODE") ?? "System"
  @State private var selectedTheme = ColorData().loadColor()
  @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  init() {
    UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(
      theme)
    theme = ColorData().loadColor()
  }

  var body: some View {
    VStack {
      if stateManager.isLoggedIn {
        if user_role == ROLE_DOM {
          DomView(stateManager: stateManager)
            .transition(.scale)
        } else if user_role == ROLE_SUB {
          SubView(stateManager: stateManager)
            .transition(.scale)
        } else {
          Text("Invalid User")
        }
      } else {
        LoginView(stateManager: stateManager)
          .transition(.scale)
      }
    }
    .onReceive(timer) { _ in
      selectedMode = UserDefaults.standard.string(forKey: "COLOR_MODE") ?? "System"
      selectedTheme = ColorData().loadColor()
    }
    .accentColor(selectedTheme)
    .preferredColorScheme(
      selectedMode == "Dark" ? .dark : (selectedMode == "Light" ? .light : .none)
    )
    .background(Color(UIColor.systemBackground))
  }
}
