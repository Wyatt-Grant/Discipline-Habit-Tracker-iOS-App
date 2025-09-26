//
//  GroupDetails.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-11-26.
//

import SimpleToast
import SwiftUI

struct GroupDetails: View {
  @Binding var group: Group
  @State private var waiting = true
  @State private var habitTasks = [HabitTask]()
  @State private var switchStates = [false]
  @State private var showEditGroupView = false
  @State private var showToast = false

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      if waiting && habitTasks.count == 0 {
        ProgressView("Loading")
      } else {
        List {
          ForEach(Array(habitTasks.enumerated()), id: \.offset) { index, task in
            HStack {
              Rectangle()
                .fill(Color(hex: task.color))
                .frame(width: 6)
              Toggle(task.name, isOn: $switchStates[index])
                .onChange(of: switchStates[index]) { oldValue, newValue in
                  Task {
                    await toggleGroupForTask(taskId: task.id, assign: switchStates[index])
                  }
                }
            }
          }
        }
        .listStyle(.plain)
      }
    }
    .navigationTitle(group.name)
    .navigationBarItems(
      trailing: Button(action: {
        showEditGroupView = true
      }) {
        Image(systemName: "pencil")
        Text("Edit")
      }
    )
    .navigationDestination(isPresented: $showEditGroupView) {
      CreateEditGroup(group: $group, editMode: true)
    }
    .onAppear {
      Task {
        await fetchTasks()
      }
    }
    .simpleToast(
      isPresented: $showToast, options: SimpleToastOptions(alignment: .bottom, hideAfter: 5)
    ) {
      Label("Whoops! Something went wrong.", systemImage: "exclamationmark.triangle")
        .padding()
        .background(Color.red.opacity(0.8))
        .foregroundColor(Color.white)
        .cornerRadius(10)
        .padding(.top)
    }
  }

  func fetchTasks() async {
    waiting = true
    var request = createAuthRequest(url: base_url + "/api/tasks")
    request.httpMethod = "GET"
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      waiting = false
      if let data = data {
        if let jsonData = try? JSONDecoder().decode(JsonTaskBase.self, from: data) {
          withAnimation {
            if jsonData.tasks?.count != habitTasks.count {
              habitTasks = [HabitTask]()
              switchStates = []
              for task in jsonData.tasks ?? [JsonHabitTask]() {
                habitTasks.append(JsonToHabitTask(habitTask: task))
                switchStates.append(task.group_id == group.id)
              }
            } else {
              var index = 0
              for task in jsonData.tasks ?? [JsonHabitTask]() {
                habitTasks[index] = JsonToHabitTask(habitTask: task)
                switchStates[index] = task.group_id == group.id
                index = index + 1
              }
            }
          }
        } else {
          showToast = true
        }
      } else {
        showToast = true
      }
    }.resume()
  }

  func toggleGroupForTask(taskId: Int, assign: Bool) async {
    waiting = true
    var request = createAuthRequest(
      url: base_url
        + "/api/\(assign ? "" : "un")assign-group/\(String(taskId))/\(String(group.id))")
    request.httpMethod = "POST"
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let data = data {
        Task {
          var index = 0
          for task in habitTasks {
            if task.id == taskId {
              habitTasks[index] = HabitTask(
                id: task.id,
                group_id: group.id,
                color: group.color,
                name: task.name,
                description: task.description,
                value: task.value,
                count: task.count,
                max_count: task.max_count,
                target_count: task.target_count,
                history: task.history.map { history in
                  History(
                    id: history.id,
                    date: history.date,
                    task_id: history.task_id,
                    was_complete: history.was_complete,
                    count: history.count,
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
            index = index + 1
          }
        }
      } else {
        showToast = true
      }
    }.resume()
  }
}
