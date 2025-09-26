//
//  GroupRow.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-11-26.
//

import SwiftUI

struct GroupRow: View {
  var group: Group

  var body: some View {
    HStack {
      Rectangle()
        .fill(Color(hex: group.color))
        .frame(width: 6)

      VStack(alignment: .leading, spacing: 0) {
        Text(group.name)
          .font(.headline)
          .foregroundColor(.gray)
      }
      Spacer()
      Image(systemName: "chevron.right")
        .foregroundColor(theme.opacity(0.5))
        .font(.system(size: 24))
    }
    .padding()
  }
}
