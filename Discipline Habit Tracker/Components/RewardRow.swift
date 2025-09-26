//
//  RewardRow.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-28.
//

import SwiftUI

struct RewardRow: View {
  var reward: Reward
  var showBank: Bool
  var showCost: Bool

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 0) {
        Text(reward.name)
          .font(.title3)
        Text(reward.description)
          .font(.subheadline)
          .foregroundColor(.gray)
      }
      Spacer()
      if showCost {
        VStack {
          Text("Cost")
            .font(.subheadline)
            .foregroundColor(.gray)
          Text(String(reward.value))
            .font(.title)
        }
      }
      if showBank {
        VStack {
          Text("Bank")
            .font(.subheadline)
            .foregroundColor(.gray)
          Text(String(reward.bank))
            .font(.title)
        }
      }
      Image(systemName: "chevron.right")
        .foregroundColor(theme.opacity(0.5))
        .font(.system(size: 24))
    }
    .padding()
  }
}
