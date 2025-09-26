//
//  CreateNewTask.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-25.
//

import SimpleToast
import SwiftUI

struct CreateEditPunishment: View {
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.presentationMode) var presentation

  @Binding var punishment: Punishment
  public var editMode = false

  @State private var name = ""
  @State private var desc = ""
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
            .frame(width: 350)
            .background(colorScheme == .dark ? .white.opacity(0.20) : .black.opacity(0.05))
            .cornerRadius(10)
          TextField("Description", text: $desc, axis: .vertical)
            .padding()
            .frame(width: 350)
            .lineLimit(5, reservesSpace: true)
            .background(colorScheme == .dark ? .white.opacity(0.20) : .black.opacity(0.05))
            .cornerRadius(10)
            .navigationBarTitle(
              editMode ? "Edit Punishment" : "Create New Punishment", displayMode: .inline)
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
            await createPunishment()
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
    .onAppear {
      if editMode {
        name = punishment.name
        desc = punishment.description
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

  func createPunishment() async {
    waiting = true
    var request = createAuthRequest(
      url: base_url + "/api/punishment" + (editMode ? "/\(punishment.id)" : "s"))
    request.httpMethod = editMode ? "PUT" : "POST"
    let body: [String: Any] = ["name": name, "description": desc]
    let jsonData = try? JSONSerialization.data(withJSONObject: body)
    request.httpBody = jsonData
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let data = data {
        if let jsonData = try? JSONDecoder().decode(JsonCompleteMessageBase.self, from: data) {
          if jsonData.message == "something went wrong" {
            showToast = true
          } else {
            Task { @MainActor in
              punishment = Punishment(
                id: punishment.id,
                name: name,
                description: desc,
                value: punishment.value,
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
