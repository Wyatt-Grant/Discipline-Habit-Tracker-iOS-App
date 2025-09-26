//
//  RuleRow.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-11-01.
//

import SwiftUI

struct RuleRow: View {
  var rule: Rule

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 0) {
        Text(rule.description)
          .font(.headline)
          .foregroundColor(.gray)
      }
      if user_role == ROLE_DOM {
        Spacer()
        Image(systemName: "chevron.right")
          .foregroundColor(theme.opacity(0.5))
          .font(.system(size: 24))
      }
    }
    .padding()
  }
}
