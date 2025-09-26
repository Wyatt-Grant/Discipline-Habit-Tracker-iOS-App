//
//  TaskHistory.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-27.
//

import SwiftUI

struct HabitTask7DayHistory: View {
  //  @Environment(\.colorScheme) var colorScheme

  var task: HabitTask

  var body: some View {
    ZStack {
      GeometryReader { geometry in
        ZStack {
          ForEach(0..<7) { index in
            let history =
              index > 0 && task.history.count > index - 1 ? task.history[index - 1] : nil
            let wasNotComplete =
              (history == nil || history?.was_complete == 0)
              && (index != 0 || task.count < task.target_count)
            let xPos = geometry.size.width / 2 + 36 * cos(CGFloat(index) * 2 * .pi / CGFloat(7))
            let yPos = geometry.size.height / 2 + 36 * sin(CGFloat(index) * 2 * .pi / CGFloat(7))

            HabitTask7DayHistoryDay(
              task: task,
              history: history,
              wasNotComplete: wasNotComplete,
              xPos: xPos,
              yPos: yPos,
              index: index
            )
          }
        }
      }
      .frame(width: 36 + 36 + 22, height: 36 + 36)
      .offset(x: 10)
      .layoutPriority(0.5)

      HabitTask7DayHistoryInner(task: task)
    }
  }
}
