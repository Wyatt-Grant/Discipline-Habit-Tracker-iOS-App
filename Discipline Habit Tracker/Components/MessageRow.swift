//
//  MessageRow.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-28.
//

import SwiftUI

struct MessageRow: View {
  var message: Message

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 0) {
        Text(message.name)
          .font(.title3)
        Text(message.description)
          .font(.subheadline)
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
