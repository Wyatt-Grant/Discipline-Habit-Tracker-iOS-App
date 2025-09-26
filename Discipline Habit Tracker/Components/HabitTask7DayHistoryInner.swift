//
//  HabitTask7DayHistoryInner.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-11-26.
//

import SwiftUI

struct HabitTask7DayHistoryInner: View {
  var task: HabitTask

  let timeFormatter = DateFormatter()
  @State private var isRistricted = false
  @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  func setVars() {
    var currentDateString: String {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd"
      return formatter.string(from: Date())
    }

    timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let restrictTime =
      timeFormatter.date(from: "\(currentDateString) \(task.restrict_time ?? "")") ?? Date()
    isRistricted =
      (task.restrict_before == 1 && restrictTime < Date())
      || (task.restrict_before == 0 && restrictTime > Date())
    isRistricted = isRistricted && task.restrict == 1
  }

  var body: some View {
    ZStack {
      if task.count >= task.target_count {
        Image(systemName: "checkmark.circle.fill")
          .offset(x: 10)
          .font(.system(size: 40))
          .foregroundColor(theme)
      } else if isRistricted {
        Image(systemName: "clock.badge.exclamationmark")
          .offset(x: 10)
          .font(.system(size: 40))
          .foregroundColor(.gray)
      } else if task.is_task_due_today == 1 {
        Text("\(task.count)/\(task.target_count)")
          .font(.title2)
          .offset(x: 10)
      } else {
        Image(systemName: "xmark.circle.fill")
          .offset(x: 10)
          .font(.system(size: 40))
          .foregroundColor(.gray)
      }
    }
    .onReceive(timer) { _ in
      setVars()
    }
    .onAppear {
      setVars()
    }
  }
}
