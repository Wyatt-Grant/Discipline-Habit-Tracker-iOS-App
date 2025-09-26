//
//  Register.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-12-14.
//

import SimpleToast
import SwiftUI

struct Register: View {
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.presentationMode) var presentation

  @State private var waiting = false

  @State private var name = ""
  @State private var userName = ""
  @State private var role = "Dom"
  @State private var password = ""
  @State private var dynamicName = ""
  @State private var timeZone = "Pacific/Wallis"
  @State private var uuid = ""
  @State private var createDynamic = false
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
          Picker("Role", selection: $role) {
            Text("Dom").tag("Dom")
            Text("Sub").tag("Sub")
          }
          .pickerStyle(SegmentedPickerStyle())
          .padding(.top, 6)
          .padding(.bottom, 6)
          TextField("Your name", text: $name)
            .padding()
            .background(colorScheme == .dark ? .white.opacity(0.20) : .black.opacity(0.05))
            .cornerRadius(10)
          TextField("Username", text: $userName)
            .padding()
            .background(colorScheme == .dark ? .white.opacity(0.20) : .black.opacity(0.05))
            .cornerRadius(10)
            .autocapitalization(.none)
            .disableAutocorrection(true)
          SecureField("Password", text: $password)
            .padding()
            .background(colorScheme == .dark ? .white.opacity(0.20) : .black.opacity(0.05))
            .cornerRadius(10)
            .autocapitalization(.none)
            .disableAutocorrection(true)
          Toggle("\(createDynamic ? "Create" : "Join") Dynamic", isOn: $createDynamic)
            .padding(.leading, 6)
            .padding(.trailing, 6)
          if createDynamic {
            TextField("Dynamic Name", text: $dynamicName)
              .padding()
              .background(colorScheme == .dark ? .white.opacity(0.20) : .black.opacity(0.05))
              .cornerRadius(10)
            TimeZonePicker(selectedTimeZone: $timeZone)
          } else {
            TextField("Dynamic UUID", text: $uuid)
              .padding()
              .background(colorScheme == .dark ? .white.opacity(0.20) : .black.opacity(0.05))
              .cornerRadius(10)
          }
        }
        .navigationBarTitle("Register", displayMode: .inline)
        Button(action: {
          Task {
            self.endTextEditing()
            await register()
          }
        }) {
          Text("Save")
            .bold()
            .foregroundColor(Color(UIColor.systemBackground))
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(waiting ? .gray : theme)
            .cornerRadius(10)
            .padding()
            .disabled(waiting)
            .contentShape(Rectangle())
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

  func register() async {
    waiting = true
    var request = createAuthRequest(url: base_url + "/api/register")
    request.httpMethod = "POST"
    let body: [String: Any] = [
      "name": name,
      "user_name": userName,
      "role": role == "Dom" ? ROLE_DOM : ROLE_SUB,
      "password": password,
      "create_dynamic": createDynamic ? 1 : 0,
      "dynamic_time_zone": timeZone,
      "dynamic_name": dynamicName,
      "dynamic_uuid": uuid,
    ]
    let jsonData = try? JSONSerialization.data(withJSONObject: body)
    request.httpBody = jsonData
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let data = data {
        if let jsonData = try? JSONDecoder().decode(JsonCompleteMessageBase.self, from: data) {
          if jsonData.message == "something went wrong" {
            showToast = true
          } else {
            Task { @MainActor in
              self.presentation.wrappedValue.dismiss()
            }
          }
        }
      } else {
        showToast = true
      }
      waiting = false
    }.resume()
  }
}
