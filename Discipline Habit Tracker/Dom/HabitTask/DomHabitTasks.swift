//
//  DomTasks.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-20.
//

import SimpleToast
import SwiftUI

struct DomHabitTasks: View {
  @Environment(\.scenePhase) private var scenePhase

  @State private var waiting = true
  @State private var showCreateTaskView = false
  @State private var showTaskDetailsView = false
  @State private var showingDeleteAlert = false
  @State private var habitTasks = [HabitTask]()
  @State private var selectedHabitTask = emptyHabitTask()
  @State private var dynamic = emptyDynamic()
  @State private var showToast = false

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
                        getHabitTaskRowWithActions(task: task)
                      }
                    }
                    .onDelete { indexSet in
                      for i in indexSet.makeIterator() {
                        selectedHabitTask = habitTasks[i]
                        Task {
                          await deleteTask()
                        }
                      }
                      habitTasks.remove(atOffsets: indexSet)

                    }
                  }
                }
                if habitTasks.filter({ $0.count < $0.target_count && $0.is_task_due_today == 1 })
                  .count >= 1
                {
                  Section(header: Text("Incomplete")) {
                    ForEach(habitTasks) { task in
                      if task.count < task.target_count && task.is_task_due_today == 1 {
                        getHabitTaskRowWithActions(task: task)
                      }
                    }
                    .onDelete { indexSet in
                      for i in indexSet.makeIterator() {
                        selectedHabitTask = habitTasks[i]
                        Task {
                          await deleteTask()
                        }
                      }
                      habitTasks.remove(atOffsets: indexSet)

                    }
                  }
                }
                if habitTasks.filter({ $0.is_task_due_today == 0 }).count >= 1 {
                  Section(header: Text("Not due today")) {
                    ForEach(habitTasks) { task in
                      if task.is_task_due_today == 0 {
                        getHabitTaskRowWithActions(task: task)
                      }
                    }
                    .onDelete { indexSet in
                      for i in indexSet.makeIterator() {
                        selectedHabitTask = habitTasks[i]
                        Task {
                          await deleteTask()
                        }
                      }
                      habitTasks.remove(atOffsets: indexSet)

                    }
                  }
                }
              }
              .listStyle(.plain)
              //                            .id(UUID())
              .refreshable {
                Task {
                  await fetchTasks()
                }
              }
              .navigationTitle("Tasks")
              .navigationBarItems(
                trailing: Button(action: {
                  showCreateTaskView = true
                }) {
                  Image(systemName: "plus")
                  Text("Add")
                }
              )
              .navigationDestination(isPresented: $showCreateTaskView) {
                CreateEditHabitTask(habitTask: $selectedHabitTask, editMode: false)
              }
              .navigationDestination(isPresented: $showTaskDetailsView) {
                HabitTaskDetails(task: $selectedHabitTask)
              }
            }
          }
        }
      }
      .onAppear {
        Task {
          await fetchTasks()
        }
      }
      .onChange(of: scenePhase) { newScenePhase, oldScenePhase in
        if newScenePhase == .background {
          Task {
            await fetchTasks()
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

  func fetchTasks() async {
    var request = createAuthRequest(url: base_url + "/api/tasks")
    request.httpMethod = "GET"
    URLSession.shared.dataTask(with: request) { (data, response, error) in
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

  func deleteTask() async {
    waiting = true
    var request = createAuthRequest(url: base_url + "/api/task/" + String(selectedHabitTask.id))
    request.httpMethod = "DELETE"
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let data = data {
        //
      } else {
        showToast = true
      }
      waiting = false
    }.resume()
  }
}
