//
//  PunishmentDetails.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-26.
//

import SimpleToast
import SwiftUI

struct DomPunishmentDetails: View {
  @Environment(\.colorScheme) var colorScheme

  @Binding var punishment: Punishment
  @State private var waiting = false
  @State private var showEditPunishmentView = false
  @State private var selectedOption = "Details"
  @State private var habitTasks = [HabitTask]()
  @State private var switchStates = [false]
  @State private var showToast = false

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Picker("Options", selection: $selectedOption) {
        Text("Details").tag("Details")
        Text("Auto Assign").tag("Auto Assign")
        Text("History").tag("History")
      }
      .padding()
      .pickerStyle(SegmentedPickerStyle())
      if selectedOption == "Details" {
        Text("\(punishment.value) Assigned")
          .font(.title)
          .padding()
        Text(punishment.description)
          .padding()
        Spacer()
        HStack {
          Spacer()
          Button(action: {
            Task {
              await incrimentPunishment(add: false, id: punishment.id)
            }
          }) {
            Text("Forgive")
              .bold()
              .foregroundColor(colorScheme == .dark ? .white : .black)
              .frame(width: 160, height: 50)
              .background(waiting || punishment.value <= 0 ? .gray : theme)
              .colorInvert()
              .cornerRadius(10)
              .contentShape(Rectangle())
          }
          .disabled(waiting || punishment.value <= 0)
          .padding()
          Spacer()
          Button(action: {
            Task {
              await incrimentPunishment(add: true, id: punishment.id)
            }
          }) {
            Text("Punish")
              .bold()
              .foregroundColor(Color(UIColor.systemBackground))
              .frame(width: 160, height: 50)
              .background(waiting ? .gray : theme)
              .cornerRadius(10)
              .contentShape(Rectangle())
          }
          .disabled(waiting)
          .padding()
          Spacer()
        }
      } else if selectedOption == "Auto Assign" {
        if waiting && habitTasks.count == 0 {
          VStack {
            HStack {
              ProgressView("Loading")
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
            }
          }
        } else {
          List {
            ForEach(Array(habitTasks.enumerated()), id: \.offset) { index, task in
              HStack {
                Toggle(task.name, isOn: $switchStates[index])
                  .onChange(of: switchStates[index]) { oldValue, newValue in
                    Task {
                      await togglePunishmentForTask(taskId: task.id, assign: switchStates[index])
                    }
                  }
              }
            }
          }
          .listStyle(.plain)
        }
        Spacer()
          .onAppear {
            Task {
              await fetchTasks()
            }
          }
      } else {
        PunishmentUsageHistory(punishment: $punishment)
        Spacer()
      }
    }
    .navigationBarTitle(punishment.name, displayMode: .inline)
    .toolbarBackground(theme, for: .navigationBar)
    .navigationBarItems(
      trailing: Button(action: {
        showEditPunishmentView = true
      }) {
        Image(systemName: "pencil")
        Text("Edit")
      }
    )
    .navigationDestination(isPresented: $showEditPunishmentView) {
      CreateEditPunishment(punishment: $punishment, editMode: true)
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
            switchStates.append(punishment.tasks.contains(task.id ?? 0))
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

  func togglePunishmentForTask(taskId: Int, assign: Bool) async {
    waiting = true
    var request = createAuthRequest(
      url: base_url
        + "/api/\(assign ? "" : "un")assign-punishment/\(String(punishment.id))/\(String(taskId))")
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

  func incrimentPunishment(add: Bool, id: Int) async {
    waiting = true
    var request = createAuthRequest(
      url: base_url + "/api/" + (add ? "add" : "remove") + "-punishment/" + String(id))
    request.httpMethod = "POST"
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let data = data {
        punishment = Punishment(
          id: punishment.id,
          name: punishment.name,
          description: punishment.description,
          value: punishment.value + (add ? 1 : -1),
          history: punishment.history.map { history in
            PunishmentHistory(
              id: history.id,
              date: history.date,
              punishment_id: history.punishment_id,
              action: history.action,
              created_at: history.created_at,
              updated_at: history.updated_at
            )
          },
          tasks: punishment.tasks
        )
      } else {
        showToast = true
      }
      waiting = false
    }.resume()
  }
}
