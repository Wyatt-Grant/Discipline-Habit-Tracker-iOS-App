//
//  CreateNewTask.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-25.
//

import SimpleToast
import SwiftUI

struct CreateEditReward: View {
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.presentationMode) var presentation

  @Binding var reward: Reward
  public var editMode = false

  @State private var name = ""
  @State private var desc = ""
  @State private var value = 1
  @State private var waiting = false
  @State private var showToast = false

  var body: some View {
    ZStack {
      Color.clear
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
          self.endTextEditing()
        }
      VStack {
        Form {
          TextField("Name", text: $name)
            .padding()
            .background(colorScheme == .dark ? .white.opacity(0.20) : .black.opacity(0.05))
            .cornerRadius(10)
          TextField("Description", text: $desc, axis: .vertical)
            .padding()
            .lineLimit(5, reservesSpace: true)
            .background(colorScheme == .dark ? .white.opacity(0.20) : .black.opacity(0.05))
            .cornerRadius(10)
            .navigationBarTitle(
              editMode ? "Edit Reward" : "Create New Reward", displayMode: .inline)
          Stepper("Cost \(value)", value: $value, in: 0...99)
            .padding()
        }
        .simultaneousGesture(
          DragGesture().onChanged({
            if 0 < $0.translation.height {
              self.endTextEditing()
            }
          })
        )
        Spacer()
        Button(action: {
          Task {
            await createReward()
          }
        }) {
          Text("Save")
            .bold()
            .foregroundColor(Color(UIColor.systemBackground))
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(waiting ? .gray : theme)
            .cornerRadius(10)
            .disabled(waiting)
            .contentShape(Rectangle())
        }
      }
    }
    .toolbarBackground(theme, for: .navigationBar)
    .padding(.top, 10)
    .contentShape(Rectangle())
    .onAppear {
      if editMode {
        name = reward.name
        desc = reward.description
        value = reward.value
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

  func createReward() async {
    waiting = true
    var request = createAuthRequest(
      url: base_url + "/api/reward" + (editMode ? "/\(reward.id)" : "s"))
    request.httpMethod = editMode ? "PUT" : "POST"
    let body: [String: Any] = ["name": name, "description": desc, "value": value, "bank": 0]
    let jsonData = try? JSONSerialization.data(withJSONObject: body)
    request.httpBody = jsonData
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let data = data {
        if let jsonData = try? JSONDecoder().decode(JsonCompleteMessageBase.self, from: data) {
          if jsonData.message == "something went wrong" {
            showToast = true
          } else {
            Task { @MainActor in
              reward = Reward(
                id: reward.id,
                name: name,
                description: desc,
                value: value,
                bank: reward.bank,
                history: reward.history.map { history in
                  RewardHistory(
                    id: history.id,
                    date: history.date,
                    reward_id: history.reward_id,
                    action: history.action,
                    created_at: history.created_at,
                    updated_at: history.updated_at
                  )
                },
                tasks: reward.tasks
              )
              self.presentation.wrappedValue.dismiss()
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
