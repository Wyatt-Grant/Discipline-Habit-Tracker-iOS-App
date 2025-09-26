//
//  DomMessages.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-25.
//

import SimpleToast
import SwiftUI

struct DomMessages: View {
  @Environment(\.scenePhase) private var scenePhase

  @State private var waiting = true
  @State private var showCreateMessageView = false
  @State private var showMessageDetailsView = false
  @State private var showingDeleteAlert = false
  @State private var messages = [Message]()
  @State private var selectedMessage: Message = emptyMessage()
  @State private var showToast = false

  var body: some View {
    NavigationStack {
      VStack {
        if waiting && messages.count == 0 {
          ProgressView("Loading")
        } else {
          ZStack {
            VStack {
              List {
                ForEach(messages) { message in
                  MessageRow(message: message)
                    .listRowInsets(EdgeInsets())
                    .contentShape(Rectangle())
                    .onTapGesture {
                      selectedMessage = cloneMessage(message: message)
                      showMessageDetailsView = true
                    }
                }
                .onDelete { indexSet in
                  for i in indexSet.makeIterator() {
                    selectedMessage = messages[i]
                    Task {
                      await deleteMessage()
                    }
                  }
                  messages.remove(atOffsets: indexSet)

                }
              }
              .listStyle(.plain)
              .refreshable {
                Task {
                  await getMessages()
                }
              }
              .navigationTitle("Messages")
              .navigationBarItems(
                trailing: Button(action: {
                  showCreateMessageView = true
                }) {
                  Image(systemName: "plus")
                  Text("Add")
                }
              )
              .navigationDestination(isPresented: $showCreateMessageView) {
                CreateEditMessage(message: $selectedMessage, editMode: false)
              }
              .navigationDestination(isPresented: $showMessageDetailsView) {
                MessageDetails(message: $selectedMessage)
              }
            }
          }
        }
      }.onAppear {
        Task {
          await getMessages()
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

  func getMessages() async {
    var request = createAuthRequest(url: base_url + "/api/messages")
    request.httpMethod = "GET"
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let data = data {
        if let jsonData = try? JSONDecoder().decode(JsonMessageBase.self, from: data) {
          withAnimation {
            if jsonData.messages?.count != messages.count {
              messages = [Message]()
              for message in jsonData.messages ?? [JsonMessage]() {
                messages.append(JsonToMessage(message: message))
              }
            } else {
              var index = 0
              for message in jsonData.messages ?? [JsonMessage]() {
                messages[index] = JsonToMessage(message: message)
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

  func deleteMessage() async {
    waiting = true
    var request = createAuthRequest(url: base_url + "/api/message/" + String(selectedMessage.id))
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
