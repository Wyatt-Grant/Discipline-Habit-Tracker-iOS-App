//
//  DomPunishments.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-23.
//

import SimpleToast
import SwiftUI

struct DomPunishments: View {
  @Environment(\.scenePhase) private var scenePhase

  @State private var waiting = true
  @State private var showPunishmentDetailsView = false
  @State private var showCreatePunishmentView = false
  @State private var showingDeleteAlert = false
  @State private var punishments = [Punishment]()
  @State private var selectedPunishment = emptyPunishment()
  @State private var showToast = false

  func getPunishmentRowWithActions(punishment: Punishment) -> some View {
    return PunishmentRow(punishment: punishment)
      .listRowInsets(EdgeInsets())
      .contentShape(Rectangle())
      .onTapGesture {
        selectedPunishment = clonePunishment(punishment: punishment)
        showPunishmentDetailsView = true
      }
  }

  var body: some View {
    NavigationStack {
      VStack {
        if waiting && punishments.count == 0 {
          ProgressView("Loading")
        } else {
          ZStack {
            VStack {
              List {
                if punishments.first(where: { $0.value > 0 }) != nil {
                  Section(header: Text("Assigned")) {
                    ForEach(punishments) { punishment in
                      if punishment.value > 0 {
                        getPunishmentRowWithActions(punishment: punishment)
                      }

                    }
                    .onDelete { indexSet in
                      for i in indexSet.makeIterator() {
                        selectedPunishment = punishments[i]
                        Task {
                          await deletePunishment()
                        }
                      }
                      punishments.remove(atOffsets: indexSet)

                    }
                  }
                }
                Section(header: Text("All")) {
                  ForEach(punishments) { punishment in
                    if punishment.value == 0 {
                      getPunishmentRowWithActions(punishment: punishment)
                    }

                  }
                  .onDelete { indexSet in
                    for i in indexSet.makeIterator() {
                      selectedPunishment = punishments[i]
                      Task {
                        await deletePunishment()
                      }
                    }
                    punishments.remove(atOffsets: indexSet)

                  }
                }
              }
              .listStyle(.plain)
              .refreshable {
                Task {
                  await fetchPunishments()
                }
              }
              .navigationTitle("Punishments")
              .navigationBarItems(
                trailing: Button(action: {
                  showCreatePunishmentView = true
                }) {
                  Image(systemName: "plus")
                  Text("Add")
                }
              )
              .navigationDestination(isPresented: $showCreatePunishmentView) {
                CreateEditPunishment(punishment: $selectedPunishment, editMode: false)
              }
              .navigationDestination(isPresented: $showPunishmentDetailsView) {
                DomPunishmentDetails(punishment: $selectedPunishment)
              }
            }
          }
        }
      }
      .onChange(of: scenePhase) { newScenePhase, oldScenePhase in
        if newScenePhase == .background {
          Task {
            await fetchPunishments()
          }
        }
      }
      .onAppear {
        Task {
          await fetchPunishments()
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

  func fetchPunishments() async {
    var request = createAuthRequest(url: base_url + "/api/punishments")
    request.httpMethod = "GET"
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let data = data {
        if let jsonData = try? JSONDecoder().decode(JsonPunishmentBase.self, from: data) {
          withAnimation {
            if jsonData.punishments?.count != punishments.count {
              punishments = [Punishment]()
              for punishment in jsonData.punishments ?? [JsonPunishment]() {
                punishments.append(JsonToPunishment(punishment: punishment))
              }
            } else {
              var index = 0
              for punishment in jsonData.punishments ?? [JsonPunishment]() {
                punishments[index] = JsonToPunishment(punishment: punishment)
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

  func deletePunishment() async {
    waiting = true
    var request = createAuthRequest(
      url: base_url + "/api/punishment/" + String(selectedPunishment.id))
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
