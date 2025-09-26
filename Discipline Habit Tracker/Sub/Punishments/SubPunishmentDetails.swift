//
//  SubPunishmentDetails.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-28.
//

import SimpleToast
import SwiftUI

struct SubPunishmentDetails: View {
  @Binding var punishment: Punishment
  @State private var waiting = false
  @State private var selectedOption = "Details"
  @State private var showToast = false

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Picker("Options", selection: $selectedOption) {
        Text("Details").tag("Details")
        Text("History").tag("History")
      }
      .padding()
      .pickerStyle(SegmentedPickerStyle())
      if selectedOption == "Details" {
        Text("x\(punishment.value)")
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
            Text("Complete")
              .bold()
              .foregroundColor(Color(UIColor.systemBackground))
              .frame(height: 50)
              .frame(maxWidth: .infinity)
              .background(waiting || punishment.value <= 0 ? .gray : theme)
              .cornerRadius(10)
              .contentShape(Rectangle())
          }
          .disabled(waiting || punishment.value <= 0)
          .padding()
          Spacer()
        }
      } else {
        PunishmentUsageHistory(punishment: $punishment)
        Spacer()
      }
    }
    .navigationBarTitle(punishment.name, displayMode: .inline)
    .toolbarBackground(theme, for: .navigationBar)
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
