//
//  DomRules.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-11-01.
//

import SimpleToast
import SwiftUI

struct DomRules: View {
  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.colorScheme) var colorScheme

  @State private var waiting = true
  @State private var showingDeleteAlert = false
  @State private var showCreateRuleView = false
  @State private var showEditRuleView = false
  @State private var rules = [Rule]()
  @State private var selectedRule = emptyRule()
  @State private var showToast = false

  var body: some View {
    NavigationStack {
      VStack {
        if waiting && rules.count == 0 {
          ProgressView("Loading")
        } else {
          ZStack {
            VStack {
              List {
                ForEach(rules) { rule in
                  RuleRow(rule: rule)
                    .listRowInsets(EdgeInsets())
                    .contentShape(Rectangle())
                    .onTapGesture {
                      selectedRule = cloneRule(rule: rule)
                      showEditRuleView = true
                    }
                }
                .onDelete { indexSet in
                  for i in indexSet.makeIterator() {
                    selectedRule = rules[i]
                    Task {
                      await deleteRule()
                    }
                  }
                  rules.remove(atOffsets: indexSet)

                }
              }
              .listStyle(.plain)
              .refreshable {
                Task {
                  await getRules()
                }
              }
              .navigationDestination(isPresented: $showCreateRuleView) {
                CreateEditRule(rule: $selectedRule, editMode: false)
              }
              .navigationDestination(isPresented: $showEditRuleView) {
                CreateEditRule(rule: $selectedRule, editMode: true)
              }
              .navigationBarTitle("", displayMode: .inline)
              .toolbarBackground(
                colorScheme == .dark ? Color.black : Color.white,
                for: .navigationBar
              )
              .navigationBarItems(
                trailing: Button(action: {
                  showCreateRuleView = true
                }) {
                  Image(systemName: "plus")
                  Text("Add")
                })
            }
          }
        }
      }.onAppear {
        Task {
          await getRules()
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

  func getRules() async {
    var request = createAuthRequest(url: base_url + "/api/rules")
    request.httpMethod = "GET"
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let data = data {
        if let jsonData = try? JSONDecoder().decode(JsonRuleBase.self, from: data) {
          withAnimation {
            if jsonData.rules?.count != rules.count {
              rules = [Rule]()
              for rule in jsonData.rules ?? [JsonRule]() {
                rules.append(JsonToRule(rule: rule))
              }
            } else {
              var index = 0
              for rule in jsonData.rules ?? [JsonRule]() {
                rules[index] = JsonToRule(rule: rule)
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

  func deleteRule() async {
    waiting = true
    var request = createAuthRequest(url: base_url + "/api/rule/" + String(selectedRule.id))
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
