//
//  PunishmentUsageHistory.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-11-21.
//

import SwiftUI

struct PunishmentUsageHistory: View {
  @Environment(\.colorScheme) var colorScheme

  @Binding var punishment: Punishment

  @State private var values: [Int] = [0, 0, 0, 0, 0, 0, 0]
  @State private var waiting = false
  @State private var lastDate = ""

  func getActionLabel(value: Int) -> String {
    switch value {
    case 0:
      return "Assigned"
    case 1:
      return "Complete"
    case 2:
      return "Forgiven"
    case 3:
      return "Auto-Assigned"
    default:
      return "Unknown"
    }
  }

  func getActionIcon(value: Int) -> String {
    switch value {
    case 0:
      return "scope"
    case 1:
      return "checkmark"
    case 2:
      return "hands.and.sparkles.fill"
    case 3:
      return "scope"
    default:
      return "questionmark"
    }
  }

  var body: some View {
    List {
      ForEach(0..<punishment.history.count, id: \.self) { index in
        let history = punishment.history[index]
        if index == 0 || punishment.history[index - 1].date != history.date {
          Section(header: Text(history.date)) {
            ForEach(0..<punishment.history.count, id: \.self) { index_inner in
              let history_inner = punishment.history[index_inner]
              if history_inner.date == history.date {
                HStack {
                  Image(systemName: getActionIcon(value: history_inner.action))
                    .foregroundColor(theme)
                  Text(getActionLabel(value: history_inner.action))
                }
              }
            }
          }
        }
      }
    }
  }
}
