//
//  TaskDetails.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-22.
//

import EffectsLibrary
import SimpleToast
import SwiftUI

struct HabitTaskDetails: View {
  @Environment(\.colorScheme) var colorScheme

  @Binding var task: HabitTask

  let timeFormatter = DateFormatter()
  @State private var isRistricted = false
  @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  @State private var waiting = false
  @State private var showingAlert = false
  @State private var alertMessage = "Nice work!"
  @State var alertEmojis: [Content] = [
    .emoji("🎉", 0.7),
    .emoji("🎊", 0.7),
    .emoji("🥳", 0.7),
    .emoji("🎁", 0.6),
  ]
  @State private var showEditHabitTaskView = false
  @State private var selectedOption = "Details"
  @State private var showToast = false

  func setVars() {
    var currentDateString: String {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd"
      return formatter.string(from: Date())
    }

    timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    timeFormatter.timeZone = TimeZone(identifier: task.time_zone)!
    let restrictTime =
      timeFormatter.date(from: "\(currentDateString) \(task.restrict_time ?? "")") ?? Date()
    isRistricted =
      (task.restrict_before == 1 && restrictTime < Date())
      || (task.restrict_before == 0 && restrictTime > Date())
    isRistricted = isRistricted && task.restrict == 1
  }

  func convertToPercent(floatValue: Float) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .percent  // This is inside a function, so it's ok
    let percentString = numberFormatter.string(from: NSNumber(value: floatValue))
    return percentString ?? ""
  }

  var body: some View {
    ZStack {
      VStack(alignment: .leading, spacing: 0) {
        Picker("Options", selection: $selectedOption) {
          Text("Details").tag("Details")
          Text("History").tag("History")
        }
        .padding()
        .pickerStyle(SegmentedPickerStyle())
        if selectedOption == "Details" {
          var percent = Float(task.count) / Float(task.target_count)
          ProgressView(value: percent) {
            Text(convertToPercent(floatValue: percent))
          }
          .padding()
          .font(.title2)
          Text(task.description)
            .padding()
          Spacer()
          HStack {
            if task.is_task_due_today == 1 {
              Spacer()
              Button(action: {
                Task {
                  await completeTask(complete: false)
                }
              }) {
                Text("Revert")
                  .bold()
                  .foregroundColor(colorScheme == .dark ? .white : .black)
                  .frame(width: 160, height: 50)
                  .background(
                    waiting || task.count == 0 || (isRistricted && user_role == ROLE_SUB)
                      ? .gray : theme
                  )
                  .colorInvert()
                  .cornerRadius(10)
                  .contentShape(Rectangle())
              }
              .disabled(waiting || task.count == 0 || (isRistricted && user_role == ROLE_SUB))
              .padding()
              Spacer()
              Button(action: {
                Task {
                  await completeTask(complete: true)
                }
              }) {
                Text("Complete")
                  .bold()
                  .foregroundColor(Color(UIColor.systemBackground))
                  .frame(width: 160, height: 50)
                  .background(
                    waiting || task.count == task.max_count
                      || (isRistricted && user_role == ROLE_SUB) ? .gray : theme
                  )
                  .cornerRadius(10)
                  .contentShape(Rectangle())
              }
              .disabled(
                waiting || task.count == task.max_count || (isRistricted && user_role == ROLE_SUB)
              )
              .padding()
              Spacer()
            }
          }
        } else {
          HabitTaskHistory(task: $task)
          Spacer()
        }
      }
      .navigationBarTitle(task.name, displayMode: .inline)
      .toolbarBackground(theme, for: .navigationBar)
      .navigationBarItems(
        trailing: Button(action: {
          if user_role == ROLE_DOM {
            showEditHabitTaskView = true
          }
        }) {
          if user_role == ROLE_DOM {
            Image(systemName: "pencil")
            Text("Edit")
          }
        }
      )
      .navigationDestination(isPresented: $showEditHabitTaskView) {
        if user_role == ROLE_DOM {
          CreateEditHabitTask(habitTask: $task, editMode: true)
        }
      }
      if showingAlert {
        ConfettiView(
          config: ConfettiConfig(content: alertEmojis))
      }
    }
    .alert(alertMessage, isPresented: $showingAlert) {
      Button("OK", role: .cancel) {
        showingAlert = false
      }
    }
    .onReceive(timer) { _ in
      setVars()
    }
    .onAppear {
      setVars()
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

  func completeTask(complete: Bool) async {
    waiting = true
    var request = createAuthRequest(
      url: base_url + "/api/" + (complete ? "" : "un") + "complete-task/" + String(task.id))
    request.httpMethod = "POST"
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let data = data {
        //          let jsonData = try JSONDecoder().decode(JsonCompleteMessageBase.self, from: data)
        if let jsonData = try? JSONDecoder().decode(JsonCompleteMessageBase.self, from: data) {
          Task { @MainActor in
            task = cloneHabitTask(habitTask: task)
            task = HabitTask(
              id: task.id,
              group_id: task.group_id,
              color: task.color,
              name: task.name,
              description: task.description,
              value: task.value,
              count: task.count + (complete ? 1 : -1),
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
            alertMessage = jsonData.message ?? ""
            alertEmojis = []
            for emoji in jsonData.emojis ?? "" {
              alertEmojis.append(.emoji(emoji, 0.7))
            }
            if user_role == ROLE_SUB && complete && alertMessage != "NONE" && alertMessage != "" {
              showingAlert = true
            }
          }
        } else {
          showToast = true
        }
      } else {
        showToast = true
      }
      waiting = false
    }.resume()
  }
}
