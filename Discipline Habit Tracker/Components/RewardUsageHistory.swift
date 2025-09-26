//
//  RewardHistory.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-11-20.
//

import SwiftUI

struct RewardUsageHistory: View {
  @Environment(\.colorScheme) var colorScheme

  @Binding var reward: Reward

  @State private var values: [Int] = [0, 0, 0, 0, 0, 0, 0]
  @State private var waiting = false
  @State private var lastDate = ""

  func getActionLabel(value: Int) -> String {
    switch value {
    case 0:
      return "Bought by Sub"
    case 1:
      return "Used by Sub"
    case 2:
      return "Given by Dom"
    case 3:
      return "Taken by Dom"
    case 4:
      return "Auto-Given by Dom"
    case 5:
      return "Auto-Taken by Dom"
    default:
      return "Unknown"
    }
  }

  func getActionIcon(value: Int) -> String {
    switch value {
    case 0:
      return "dollarsign"
    case 1:
      return "checkmark"
    case 2:
      return "gift"
    case 3:
      return "arrow.uturn.left"
    case 4:
      return "gift"
    case 5:
      return "arrow.uturn.left"
    default:
      return "questionmark"
    }
  }

  var body: some View {
    List {
      ForEach(0..<reward.history.count, id: \.self) { index in
        let history = reward.history[index]
        if index == 0 || reward.history[index - 1].date != history.date {
          Section(header: Text(history.date)) {
            ForEach(0..<reward.history.count, id: \.self) { index_inner in
              let history_inner = reward.history[index_inner]
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
