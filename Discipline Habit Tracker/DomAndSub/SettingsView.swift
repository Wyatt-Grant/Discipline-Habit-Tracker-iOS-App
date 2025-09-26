//
//  SettingsView.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-28.
//

import SimpleToast
import SwiftUI

struct SettingsView: View {
  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.colorScheme) var colorScheme
  @StateObject var stateManager = StateManager()

  @State private var waiting = true
  @State private var dynamic = emptyDynamic()
  @State private var timeZone = "Pacific/Wallis"
  @State private var dynamicName = ""
  @State private var domName = ""
  @State private var subName = ""
  @State private var emojis = ""

  @State private var selectedColor = theme
  @State private var selectedMode = UserDefaults.standard.string(forKey: "COLOR_MODE") ?? "System"
  @State private var showToast = false
  @State private var showSuccessToast = false

  var body: some View {
    ZStack {
      Color.clear
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
          self.endTextEditing()
        }
      NavigationStack {
        if waiting && dynamic.id == 0 {
          ProgressView("Loading")
        } else {
          VStack {
            Form {
              ColorPicker("Theme", selection: $selectedColor)
                .onChange(of: selectedColor) { oldValue, newValue in
                  theme = newValue
                  ColorData().saveColor(color: theme)
                }
                .padding()
              Picker("Mode", selection: $selectedMode) {
                Text("System").tag("System")
                Text("Light").tag("Light")
                Text("Dark").tag("Dark")
              }
              .padding()
              .pickerStyle(SegmentedPickerStyle())
              .onChange(of: selectedMode) { oldValue, newValue in
                UserDefaults.standard.set(selectedMode, forKey: "COLOR_MODE")
              }
              if user_role == ROLE_DOM {
                TextField("Dynamic Name", text: $dynamicName)
                  .padding()
                  .background(colorScheme == .dark ? .white.opacity(0.20) : .black.opacity(0.05))
                  .cornerRadius(10)
                TextField("My Name", text: $domName)
                  .padding()
                  .background(colorScheme == .dark ? .white.opacity(0.20) : .black.opacity(0.05))
                  .cornerRadius(10)
                TextField("Sub Name", text: $subName)
                  .padding()
                  .background(colorScheme == .dark ? .white.opacity(0.20) : .black.opacity(0.05))
                  .cornerRadius(10)
                TextField("Completion Emojis", text: $emojis)
                  .padding()
                  .background(colorScheme == .dark ? .white.opacity(0.20) : .black.opacity(0.05))
                  .cornerRadius(10)
                VStack {
                  HStack {
                    TimeZonePicker(selectedTimeZone: $timeZone)
                      .padding(.trailing)
                  }
                  .padding(.top)
                  .padding(.bottom)
                }
              }
              if user_role == ROLE_SUB {
                TextField("My Name", text: $subName)
                  .padding()
                  .background(colorScheme == .dark ? .white.opacity(0.20) : .black.opacity(0.05))
                  .cornerRadius(10)
              }
            }
          }
          .simultaneousGesture(
            DragGesture().onChanged({
              if 0 < $0.translation.height {
                self.endTextEditing()
              }
            })
          )
          .navigationBarTitle("", displayMode: .inline)
          .toolbarBackground(
            colorScheme == .dark ? Color.black : Color.white,
            for: .navigationBar
          )
          .navigationBarItems(
            trailing: Button(action: {
              Task {
                user_token = ""
                user_id = 0
                user_name = ""
                user_role = 0
                user_full_name = ""

                UserDefaults.standard.set(nil, forKey: "USERNAME")
                UserDefaults.standard.set(nil, forKey: "PASSWORD")

                stateManager.changeLogin(state: false)
              }
            }) {
              Image(systemName: "door.right.hand.open")
              Text("Log Out")
            })
          Spacer()
          Button(action: {
            Task {
              self.endTextEditing()
              await updateDynamic()
            }
          }) {
            Text("Save")
              .bold()
              .foregroundColor(Color(UIColor.systemBackground))
              .frame(height: 50)
              .frame(maxWidth: .infinity)
              .background(theme)
              .cornerRadius(10)
              .contentShape(Rectangle())
          }
          .padding()
        }
      }
      .onChange(of: scenePhase) { newScenePhase, oldScenePhase in
        if newScenePhase == .background {
          Task {
            await getDynamic()
          }
        }
      }
      .onAppear {
        Task {
          await getDynamic()
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
      .simpleToast(
        isPresented: $showSuccessToast,
        options: SimpleToastOptions(alignment: .bottom, hideAfter: 5)
      ) {
        Label("Settings saved!", systemImage: "checkmark.circle")
          .padding()
          .background(Color.green.opacity(0.8))
          .foregroundColor(Color.white)
          .cornerRadius(10)
          .padding(.top)
      }
    }
  }

  func updateDynamic() async {
    waiting = true
    var request = createAuthRequest(url: base_url + "/api/dynamic/\(dynamic.id)")
    request.httpMethod = "PUT"
    let body: [String: Any] = [
      "name": dynamicName,
      "time_zone": timeZone,
      "default_reward_emojis": emojis,
      "sub": subName,
      "dom": domName,
    ]
    let jsonData = try? JSONSerialization.data(withJSONObject: body)
    request.httpBody = jsonData
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      if data != nil {
        Task {
          await getDynamic()
        }
      } else {
        showToast = true
      }
    }.resume()
  }

  func getDynamic() async {
    waiting = true
    var request = createAuthRequest(url: base_url + "/api/dynamic")
    request.httpMethod = "GET"
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let data = data {
        if let jsonData = try? JSONDecoder().decode(JsonDynamicBase.self, from: data) {
          Task { @MainActor in
            dynamic = Dynamic(
              id: jsonData.dynamic?.id ?? 0,
              name: jsonData.dynamic?.name ?? "",
              UUID: jsonData.dynamic?.UUID ?? "",
              sub: jsonData.dynamic?.sub ?? "",
              dom: jsonData.dynamic?.dom ?? "",
              time_zone: jsonData.dynamic?.time_zone ?? "",
              default_reward_emojis: jsonData.dynamic?.default_reward_emojis ?? "",
              created_at: jsonData.dynamic?.created_at ?? "",
              created_at_humans: jsonData.dynamic?.created_at_humans ?? ""
            )
            timeZone = dynamic.time_zone
            dynamicName = dynamic.name
            domName = dynamic.dom
            subName = dynamic.sub
            emojis = dynamic.default_reward_emojis
            waiting = false
          }
        } else {
          showToast = true
        }
      } else {
        showToast = true
      }
    }.resume()
  }

  func updateMode(_ mode: String) {
    // Implement any logic here to handle the mode change
    // For example, you can update the app's appearance
    // based on the selected mode.
  }
}
