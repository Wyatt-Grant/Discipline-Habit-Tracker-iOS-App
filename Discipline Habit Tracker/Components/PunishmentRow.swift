//
//  PunishmentRow.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-28.
//

import SwiftUI

struct PunishmentRow: View {
  var punishment: Punishment

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 0) {
        Text(punishment.name)
          .font(.title3)
        Text(punishment.description)
          .font(.subheadline)
          .foregroundColor(.gray)
        Spacer()
      }
      Spacer()
      VStack {
        if punishment.value > 0 {
          Text("x\(String(punishment.value))")
            .font(.title)
            .padding(Edge.Set.bottom, 5)
            .padding(Edge.Set.trailing, 5)
        }
      }
      Image(systemName: "chevron.right")
        .foregroundColor(theme.opacity(0.5))
        .font(.system(size: 24))
    }
    .padding()
  }
}
