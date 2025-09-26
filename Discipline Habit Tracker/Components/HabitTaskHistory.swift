//
//  HabitTaskHistory.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-11-08.
//

import SwiftUI

struct HabitTaskHistory: View {
  @Environment(\.colorScheme) var colorScheme

  @Binding var task: HabitTask

  @State private var values: [Int] = [0, 0, 0, 0, 0, 0, 0]
  @State private var waiting = false

  var body: some View {
    List {
      ForEach(0..<7) { index in
        let history = task.history.first(where: {
          $0.date == getFormattedCurrentDayOfMonth(-index)
        })
        if history != nil {

          Section(header: Text(history?.date ?? "")) {
            if history?.was_complete == 1 {
              HStack {
                Image(systemName: "checkmark.circle.fill")
                  .foregroundColor(theme)
                if user_role == ROLE_SUB {
                  Text("Complete")
                  Spacer()
                  Text("\(history?.count ?? 0)/\(history?.target_count ?? 0)")
                } else {
                  Stepper(
                    "Complete \(history?.count ?? 0)/\(history?.target_count ?? 0)",
                    value: $values[index], in: -999...909
                  )
                  .onChange(of: values[index]) { oldValue, newValue in
                    Task {
                      await completeTaskHistory(
                        complete: newValue > oldValue, id: history?.id ?? 0)
                    }
                  }
                  .disabled(waiting)
                }
              }
            } else {
              HStack {
                Image(systemName: "xmark.circle.fill")
                  .foregroundColor(theme)
                  .colorInvert()
                if user_role == ROLE_SUB {
                  Text("Failed")
                  Spacer()
                  Text("\(history?.count ?? 0)/\(history?.target_count ?? 0)")
                } else {
                  Stepper(
                    "Failed \(history?.count ?? 0)/\(history?.target_count ?? 0)",
                    value: $values[index], in: -999...909
                  )
                  .onChange(of: values[index]) { oldValue, newValue in
                    Task {
                      await completeTaskHistory(
                        complete: newValue > oldValue, id: history?.id ?? 0)
                    }
                  }
                  .disabled(waiting)
                }
              }
            }
          }
        }
      }
    }
  }

  func completeTaskHistory(complete: Bool, id: Int) async {
    waiting = true
    var request = createAuthRequest(
      url: base_url + "/api/" + (complete ? "" : "un") + "complete-task-history/" + String(id))
    request.httpMethod = "POST"
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let data = data {
        if (try? JSONDecoder().decode(JsonCompleteMessageBase.self, from: data)) != nil {
          Task { @MainActor in
            task = HabitTask(
              id: task.id,
              group_id: task.group_id,
              color: task.color,
              name: task.name,
              description: task.description,
              value: task.value,
              count: task.count,
              max_count: task.max_count,
              target_count: task.target_count,
              history: task.history.map { history in
                let c = history.id == id ? history.count + (complete ? 1 : -1) : history.count
                return History(
                  id: history.id,
                  date: history.date,
                  task_id: history.task_id,
                  was_complete: c >= history.target_count ? 1 : 0,
                  count: c > 0 ? c : 0,
                  target_count: history.target_count,
                  created_at: history.created_at,
                  updated_at: history.updated_at
                )
              },
              rrule: task.rrule,
              start: task.start,
              end: task.end,
              remove_points_on_failure: task.remove_points_on_failure,
              is_task_due_today: task.is_task_due_today,
              rule_text: task.rule_text,
              remind: task.remind,
              remind_time: task.remind_time,
              restrict: task.restrict,
              restrict_before: task.restrict_before,
              restrict_time: task.restrict_time,
              time_zone: task.time_zone
            )
          }
        }
      }
      waiting = false
    }.resume()
  }
}
