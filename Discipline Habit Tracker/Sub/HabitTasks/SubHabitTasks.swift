//
//  DomTasks.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-28.
//

import EffectsLibrary
import EventKit
import SimpleToast
import SwiftUI

struct SubHabitTasks: View {
  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.colorScheme) var colorScheme

  let timeFormatter = DateFormatter()

  @State private var waiting = true
  @State private var showTaskDetailsView = false
  @State private var showingDeleteAlert = false
  @State private var habitTasks = [HabitTask]()
  @State private var reminders = [Reminder]()
  @State private var selectedHabitTask = emptyHabitTask()
  @State private var remaingTasks = -1
  @State private var timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
  @State private var showingAlert = false
  @State private var alertMessage = "Nice work!"
  @State private var showToast = false

  @State var alertEmojis: [Content] = [
    .emoji("🎉", 0.7),
    .emoji("🎊", 0.7),
    .emoji("🥳", 0.7),
    .emoji("🎁", 0.6),
  ]

  func isRistricted(task: HabitTask) -> Bool {
    var currentDateString: String {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd"
      return formatter.string(from: Date())
    }

    timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    timeFormatter.timeZone = TimeZone(identifier: task.time_zone)!
    let restrictTime =
      timeFormatter.date(from: "\(currentDateString) \(task.restrict_time ?? "")") ?? Date()
    let isRistricted =
      (task.restrict_before == 1 && restrictTime < Date())
      || (task.restrict_before == 0 && restrictTime > Date())
    return isRistricted && task.restrict == 1
  }

  func getHabitTaskRowWithActions(task: HabitTask) -> some View {
    return HabitTaskRow(habitTask: task)
      .listRowInsets(EdgeInsets())
      .contentShape(Rectangle())
      .onTapGesture {
        selectedHabitTask = cloneHabitTask(habitTask: task)
        showTaskDetailsView = true
      }
  }

  var body: some View {
    NavigationStack {
      VStack {
        if waiting && habitTasks.count == 0 {
          ProgressView("Loading")
        } else {
          ZStack {
            VStack {
              List {
                if habitTasks.filter({ $0.count >= $0.target_count && $0.is_task_due_today == 1 })
                  .count >= 1
                {
                  Section(header: Text("Complete")) {
                    ForEach(habitTasks) { task in
                      if task.count >= task.target_count && task.is_task_due_today == 1 {
                        let isRestricted = isRistricted(task: task)
                        getHabitTaskRowWithActions(task: task)
                          .swipeActions {
                            Button(action: {
                              Task {
                                let isRestricted = isRistricted(task: task)
                                if !isRestricted {
                                  selectedHabitTask = cloneHabitTask(habitTask: task)
                                  await completeTask(complete: false)
                                }
                              }
                            }) {
                              Label(
                                isRestricted ? "Restricted" : "Revert",
                                systemImage: "xmark.circle.fill")
                            }
                            .tint(isRestricted ? .gray : theme)
                          }
                      }
                    }
                  }
                }
                if habitTasks.filter({ $0.count < $0.target_count && $0.is_task_due_today == 1 })
                  .count >= 1
                {
                  Section(header: Text("Incomplete")) {
                    ForEach(habitTasks) { task in
                      if task.count < task.target_count && task.is_task_due_today == 1 {
                        let isRestricted = isRistricted(task: task)
                        getHabitTaskRowWithActions(task: task)
                          .swipeActions {
                            Button(action: {
                              Task {
                                let isRestricted = isRistricted(task: task)
                                if !isRestricted {
                                  selectedHabitTask = cloneHabitTask(habitTask: task)
                                  await completeTask(complete: true)
                                }
                              }
                            }) {
                              Label(
                                isRestricted ? "Restricted" : "Complete",
                                systemImage: isRestricted
                                  ? "xmark.circle.fill" : "checkmark.circle.fill")
                            }
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .tint(isRestricted ? .gray : theme)
                            .colorInvert()
                          }
                      }
                    }
                  }
                }
              }
              .listStyle(.plain)
              //                            .id(UUID())
              .refreshable {
                Task {
                  await fetchTasks()
                  await getRemaining()
                }
              }
              .navigationTitle("Tasks")
              .navigationDestination(isPresented: $showTaskDetailsView) {
                HabitTaskDetails(task: $selectedHabitTask)
              }
              .navigationBarItems(
                trailing:
                  VStack {
                    Text(remaingTasks >= 0 ? "\(remaingTasks) Remaining" : "Loading")
                  }
              )
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
        }
      }
      .onReceive(timer) { _ in
        remaingTasks = remaining
      }
      .onAppear {
        Task {
          await fetchTasks()
          await getRemaining()
          await fetchReminders()
        }
      }
      .onChange(of: scenePhase) { newScenePhase, oldScenePhase in
        if newScenePhase == .background {
          Task {
            await fetchTasks()
            await getRemaining()
            await fetchReminders()
          }
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
  }

  func completeTask(complete: Bool) async {
    waiting = true
    var request = createAuthRequest(
      url: base_url + "/api/" + (complete ? "" : "un") + "complete-task/"
        + String(selectedHabitTask.id))
    request.httpMethod = "POST"
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let data = data {
        if let jsonData = try? JSONDecoder().decode(JsonCompleteMessageBase.self, from: data) {
          Task { @MainActor in
            selectedHabitTask = cloneHabitTask(habitTask: selectedHabitTask)
            selectedHabitTask = HabitTask(
              id: selectedHabitTask.id,
              group_id: selectedHabitTask.group_id,
              color: selectedHabitTask.color,
              name: selectedHabitTask.name,
              description: selectedHabitTask.description,
              value: selectedHabitTask.value,
              count: selectedHabitTask.count + (complete ? 1 : -1),
              max_count: selectedHabitTask.max_count,
              target_count: selectedHabitTask.target_count,
              history: selectedHabitTask.history.map { history in
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
              rrule: selectedHabitTask.rrule,
              start: selectedHabitTask.start,
              end: selectedHabitTask.end,
              remove_points_on_failure: selectedHabitTask.remove_points_on_failure,
              is_task_due_today: selectedHabitTask.is_task_due_today,
              rule_text: selectedHabitTask.rule_text,
              remind: selectedHabitTask.remind,
              remind_time: selectedHabitTask.remind_time,
              restrict: selectedHabitTask.restrict,
              restrict_before: selectedHabitTask.restrict_before,
              restrict_time: selectedHabitTask.restrict_time,
              time_zone: selectedHabitTask.time_zone
            )
            alertMessage = jsonData.message ?? ""
            alertEmojis = []
            for emoji in jsonData.emojis ?? "" {
              alertEmojis.append(.emoji(emoji, 0.7))
            }
            if user_role == ROLE_SUB && complete && alertMessage != "NONE" && alertMessage != "" {
              showingAlert = true
            }
            await fetchTasks()
            await fetchReminders()
          }
        } else {
          showToast = true
        }
      } else {
        showToast = true
      }
    }.resume()
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
              for task in jsonData.tasks ?? [JsonHabitTask]() {
                habitTasks.append(JsonToHabitTask(habitTask: task))
              }
            } else {
              var index = 0
              for task in jsonData.tasks ?? [JsonHabitTask]() {
                habitTasks[index] = JsonToHabitTask(habitTask: task)
                index = index + 1
              }
            }
          }
          waiting = false
        } else {
          showToast = true
        }
      } else {
        showToast = true
      }
    }.resume()
  }

  func fetchReminders() async {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge, .provisional]) {
      granted, error in
      if error != nil {
        return
      }
    }

    waiting = true
    var request = createAuthRequest(url: base_url + "/api/tasks/reminders")
    request.httpMethod = "GET"
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      waiting = false
      if let data = data {
        if let jsonData = try? JSONDecoder().decode(JsonReminderBase.self, from: data) {
          clearReminders()
          for reminder in jsonData.reminders ?? [JsonReminder]() {
            createReminder(reminder: JsonToReminder(reminder: reminder))
          }
        }
      }
    }.resume()
  }

  func clearReminders() {
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
  }

  func createReminder(reminder: Reminder) {
    let content = UNMutableNotificationContent()
    content.title = reminder.title + " (\(reminder.count))"
    content.body = reminder.description

    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    timeFormatter.timeZone = TimeZone(identifier: reminder.time_zone)!
    var remindTime = timeFormatter.date(from: reminder.date_time) ?? Date()

    let calendar = Calendar.current
    var dateComponents = DateComponents()
    dateComponents.day = calendar.component(.day, from: remindTime)
    dateComponents.month = calendar.component(.month, from: remindTime)
    dateComponents.year = calendar.component(.year, from: remindTime)
    dateComponents.hour = calendar.component(.hour, from: remindTime)
    dateComponents.minute = calendar.component(.minute, from: remindTime)

    let center = UNUserNotificationCenter.current()
    center.getNotificationSettings { settings in
      guard
        (settings.authorizationStatus == .authorized)
          || (settings.authorizationStatus == .provisional)
      else { return }

      content.interruptionLevel = UNNotificationInterruptionLevel.timeSensitive
      content.sound = UNNotificationSound.default

      let trigger = UNCalendarNotificationTrigger(
        dateMatching: dateComponents, repeats: false)

      let request = UNNotificationRequest(
        identifier: reminder.id,
        content: content, trigger: trigger)

      center.add(request) { (error) in
        if error != nil {
          //
        }
      }
    }
  }
}
