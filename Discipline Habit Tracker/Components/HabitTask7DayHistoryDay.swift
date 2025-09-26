//
//  HabitTask7DayHistoryDay.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2024-01-24.
//

import SwiftUI

struct HabitTask7DayHistoryDay: View {
  var task: HabitTask
  var history: History?
  var wasNotComplete: Bool
  var xPos: CGFloat
  var yPos: CGFloat
  var index: Int

  var body: some View {
    ZStack {
      if history != nil || (index == 0 && task.is_task_due_today == 1) {
        Circle()
          .foregroundColor(theme)
          .frame(width: 22, height: 22)
          .position(x: xPos, y: yPos)
      }

      if wasNotComplete {
        Circle()
          .foregroundColor(Color(UIColor.systemBackground))
          .frame(width: 20, height: 20)
          .position(x: xPos, y: yPos)
      }

      if index == 0 && task.is_task_due_today == 1 {
        let dateNum = getCurrentDayOfMonth(timeZone: task.time_zone)
        let date = (dateNum <= 9 ? "0" : "") + String(dateNum)
        Text(date)
          .font(.footnote)
          .foregroundColor(
            task.count < task.target_count ? theme : Color(UIColor.systemBackground)
          )
          .position(x: xPos, y: yPos)
      } else if history != nil {
        Text((history?.date ?? "").suffix(2))
          .font(.footnote)
          .foregroundColor(
            history?.was_complete == 0 ? theme : Color(UIColor.systemBackground)
          )
          .position(x: xPos, y: yPos)
      }
    }
  }
}
