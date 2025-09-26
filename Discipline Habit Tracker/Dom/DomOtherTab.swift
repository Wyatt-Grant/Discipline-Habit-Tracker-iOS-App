//
//  OtherTab.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-11-08.
//

import SwiftUI

struct DomOtherTab: View {
  @StateObject var stateManager = StateManager()
  @State private var selectedOption = "Rules"

  var body: some View {
    VStack {
      Picker("Options", selection: $selectedOption) {
        Text("Rules").tag("Rules")
        Text("Dynamic").tag("Dynamic")
        Text("Groups").tag("Groups")
        Text("Settings").tag("Settings")
      }
      .padding()
      .pickerStyle(SegmentedPickerStyle())
      if selectedOption == "Settings" {
        SettingsView(stateManager: stateManager)
      } else if selectedOption == "Rules" {
        DomRules()
      } else if selectedOption == "Dynamic" {
        DynamicInfo()
      } else if selectedOption == "Groups" {
        Groups()
      }
    }
  }
}
