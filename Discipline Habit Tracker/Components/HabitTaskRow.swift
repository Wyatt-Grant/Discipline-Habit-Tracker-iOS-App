//
//  HabitTaskRow.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-28.
//

import SwiftUI

struct HabitTaskRow: View {
  var habitTask: HabitTask

  let timeFormatter = DateFormatter()
  @State private var isRistricted = false
  @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  func setVars() {
    timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let restrictTime =
      timeFormatter.date(from: "\(habitTask.start ?? "") \(habitTask.restrict_time ?? "")")
      ?? Date()
    //    isRistricted =
    //      (habitTask.restrict_before == 1 && restrictTime < Date())
    //      || (habitTask.restrict_before == 0 && restrictTime > Date())
    isRistricted = /*isRistricted && */ habitTask.restrict == 1
  }

  func formatTime() -> String {
    var currentDateString: String {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd"
      return formatter.string(from: Date())
    }

    timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let restrictTime =
      timeFormatter.date(from: "\(currentDateString) \(habitTask.restrict_time ?? "")")
      ?? Date()
    let formatter = DateFormatter()

    formatter.dateFormat = "h:mm a"
    return formatter.string(from: restrictTime)
  }

  var body: some View {
    HStack {
      Rectangle()
        .fill(habitTask.group_id != 0 ? Color(hex: habitTask.color) : Color.clear)
        .frame(width: 6)

      HabitTask7DayHistory(task: habitTask)

      VStack(alignment: .leading, spacing: 0) {
        Text(habitTask.name)
          .font(.title3)
          .padding(.top, 8)

        Text(habitTask.description)
          .font(.subheadline)
          .foregroundColor(.gray)
          .padding(.bottom, 8)

        Spacer()

        HStack {
          if isRistricted {
            Text(
              "Can only be done \(habitTask.restrict_before == 1 ? "before" : "after") \(formatTime())"
            )
            .font(.caption2)
            .padding(.bottom, 8)
          }
          Spacer()
          Text(habitTask.rule_text)
            .font(.caption2)
            .padding(.bottom, 8)
        }
      }
      .offset(x: 16)
      .layoutPriority(1.0)
      .frame(height: 110)

      Spacer()

      Image(systemName: "chevron.right")
        .foregroundColor(theme.opacity(0.5))
        .font(.system(size: 24))
        .padding()
    }
    .onReceive(timer) { _ in
      setVars()
    }
    .onAppear {
      setVars()
    }
  }
}
