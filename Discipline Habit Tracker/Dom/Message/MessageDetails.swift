//
//  PunishmentDetails.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-26.
//

import SimpleToast
import SwiftUI

struct MessageDetails: View {
  @Binding var message: Message
  @State private var waiting = true
  @State private var habitTasks = [HabitTask]()
  @State private var switchStates = [false]
  @State private var showEditMessageView = false
  @State private var showToast = false

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      if waiting && habitTasks.count == 0 {
        ProgressView("Loading")
      } else {
        List {
          ForEach(Array(habitTasks.enumerated()), id: \.offset) { index, task in
            HStack {
              Toggle(task.name, isOn: $switchStates[index])
                .onChange(of: switchStates[index]) { oldValue, newValue in
                  Task {
                    await toggleMessageForTask(taskId: task.id, assign: switchStates[index])
                  }
                }
            }
          }
        }
        .listStyle(.plain)
      }
    }
    .navigationTitle(message.name)
    .navigationBarItems(
      trailing: Button(action: {
        showEditMessageView = true
      }) {
        Image(systemName: "pencil")
        Text("Edit")
      }
    )
    .navigationDestination(isPresented: $showEditMessageView) {
      CreateEditMessage(message: $message, editMode: true)
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
          habitTasks = [HabitTask]()
          switchStates = []
          for task in jsonData.tasks ?? [JsonHabitTask]() {
            habitTasks.append(JsonToHabitTask(habitTask: task))
            switchStates.append(message.tasks.contains(task.id ?? 0))
          }
        } else {
          showToast = true
        }
      } else {
        showToast = true
      }
    }.resume()
  }

  func toggleMessageForTask(taskId: Int, assign: Bool) async {
    waiting = true
    var request = createAuthRequest(
      url: base_url
        + "/api/\(assign ? "" : "un")assign-message/\(String(message.id))/\(String(taskId))")
    request.httpMethod = "POST"
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
