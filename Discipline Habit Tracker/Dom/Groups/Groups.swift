//
//  Groups.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-11-26.
//

import SimpleToast
import SwiftUI

struct Groups: View {
  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.colorScheme) var colorScheme

  @State private var waiting = true
  @State private var showingDeleteAlert = false
  @State private var showCreateGroupView = false
  @State private var showGroupDetailsView = false
  @State private var groups = [Group]()
  @State private var showToast = false
  @State private var selectedGroup = emptyGroup()

  private func move(from source: IndexSet, to destination: Int) {
    groups.move(fromOffsets: source, toOffset: destination)
    Task {
      await sortGroups()
    }
  }

  var body: some View {
    NavigationStack {
      VStack {
        if waiting && groups.count == 0 {
          ProgressView("Loading")
        } else {
          ZStack {
            VStack {
              List {
                ForEach(groups) { group in
                  GroupRow(group: group)
                    .listRowInsets(EdgeInsets())
                    .contentShape(Rectangle())
                    .onTapGesture {
                      selectedGroup = cloneGroup(group: group)
                      showGroupDetailsView = true
                    }
                }
                .onDelete { indexSet in
                  for i in indexSet.makeIterator() {
                    selectedGroup = groups[i]
                    Task {
                      await deleteGroup()
                    }
                  }
                  groups.remove(atOffsets: indexSet)

                }
                .onMove(perform: move)
              }
              .toolbar {
                EditButton()
              }
              .listStyle(.plain)
              .refreshable {
                Task {
                  await getGroups()
                }
              }
              .navigationDestination(isPresented: $showCreateGroupView) {
                CreateEditGroup(group: $selectedGroup, editMode: false)
              }
              .navigationDestination(isPresented: $showGroupDetailsView) {
                GroupDetails(group: $selectedGroup)
              }
              .navigationBarTitle("", displayMode: .inline)
              .toolbarBackground(
                colorScheme == .dark ? Color.black : Color.white,
                for: .navigationBar
              )
              .navigationBarItems(
                leading: Button(action: {
                  showCreateGroupView = true
                }) {
                  Image(systemName: "plus")
                  Text("Add")
                })
            }
          }
        }
      }.onAppear {
        Task {
          await getGroups()
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

  func getGroups() async {
    var request = createAuthRequest(url: base_url + "/api/groups")
    request.httpMethod = "GET"
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let data = data {
        if let jsonData = try? JSONDecoder().decode(JsonGroupBase.self, from: data) {
          withAnimation {
            if jsonData.groups?.count != groups.count {
              groups = [Group]()
              for group in jsonData.groups ?? [JsonGroup]() {
                groups.append(JsonToGroup(group: group))
              }
            } else {
              var index = 0
              for group in jsonData.groups ?? [JsonGroup]() {
                groups[index] = JsonToGroup(group: group)
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

  func sortGroups() async {
    waiting = true
    var request = createAuthRequest(url: base_url + "/api/sort-groups")
    request.httpMethod = "POST"
    let body: [String: Any] = [
      "sorted_group_ids": groups.map { String($0.id) }.joined(separator: ",")
    ]
    let jsonData = try? JSONSerialization.data(withJSONObject: body)
    request.httpBody = jsonData
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      if data != nil {
        //
      } else {
        showToast = true
      }
      waiting = false
    }.resume()
  }

  func deleteGroup() async {
    waiting = true
    var request = createAuthRequest(url: base_url + "/api/group/" + String(selectedGroup.id))
    request.httpMethod = "DELETE"
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      if data != nil {
        //
      } else {
        showToast = true
      }
      waiting = false
    }.resume()
  }
}
