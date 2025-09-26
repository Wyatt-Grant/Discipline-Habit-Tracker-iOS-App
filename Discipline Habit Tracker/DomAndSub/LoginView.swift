//
//  LoginView.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-21.
//

import SimpleToast
import SwiftUI

extension View {
  func endTextEditing() {
    UIApplication.shared.sendAction(
      #selector(UIResponder.resignFirstResponder),
      to: nil, from: nil, for: nil)
  }
}

struct LoginView: View {
  @Environment(\.colorScheme) var colorScheme

  @StateObject var stateManager = StateManager()

  @State private var user_name = UserDefaults.standard.string(forKey: "USERNAME") ?? ""
  @State private var password = UserDefaults.standard.string(forKey: "PASSWORD") ?? ""
  @State private var invalid_user = false
  @State private var show_login_screen = false
  @State private var show_register = false
  @State private var waiting = false
  @State private var showToast = false
  @State private var remeberMe =
    UserDefaults.standard.string(forKey: "USERNAME") != nil
    && UserDefaults.standard.string(forKey: "PASSWORD") != nil

  let wasInfoSaved =
    UserDefaults.standard.string(forKey: "USERNAME") != nil
    && UserDefaults.standard.string(forKey: "PASSWORD") != nil

  var body: some View {
    NavigationStack {
      ZStack {
        theme
          .ignoresSafeArea()
        Circle()
          .scale(1.9)
          .foregroundColor(Color(UIColor.systemBackground).opacity(0.33))
        Circle()
          .scale(1.6)
          .foregroundColor(Color(UIColor.systemBackground).opacity(0.66))
        Circle()
          .scale(1.3)
          .foregroundColor(Color(UIColor.systemBackground))
          .onTapGesture {
            self.endTextEditing()
          }

        VStack {
          Text("Discipline")
            .font(.largeTitle)
            .bold()
          Text("Habit Tracker")
            .bold()
          if !wasInfoSaved {
            Spacer().frame(width: 300, height: 60)
            TextField("User Name", text: $user_name)
              .padding()
              .frame(width: 350)
              .background(colorScheme == .dark ? .white.opacity(0.20) : .black.opacity(0.05))
              .cornerRadius(10)
              .disabled(waiting)
              .autocapitalization(.none)
              .disableAutocorrection(true)
              .overlay(
                RoundedRectangle(cornerRadius: 10)
                  .stroke(Color.red, lineWidth: invalid_user ? 2 : 0)
              )
            SecureTextFieldWithReveal(text: $password, waiting: $waiting, invalid: $invalid_user)
            Toggle("Remember Me", isOn: $remeberMe)
              .disabled(waiting)
              .frame(width: 350)
            Button("Register here") {
              show_register = true
            }
            .buttonStyle(.plain)
            .foregroundColor(.blue)
            .navigationDestination(isPresented: $show_register) {
              Register()
            }
            Spacer().frame(width: 300, height: 60)
            Button(action: {
              Task {
                if remeberMe {
                  UserDefaults.standard.set(user_name, forKey: "USERNAME")
                  UserDefaults.standard.set(password, forKey: "PASSWORD")
                }

                invalid_user = false
                await AuthUser()
              }
            }) {
              Text("Login")
                .bold()
                .foregroundColor(Color(UIColor.systemBackground))
                .frame(width: 200, height: 50)
                .background(waiting || (user_name == "" && password == "") ? .gray : theme)
                .cornerRadius(10)
                .disabled(waiting || (user_name == "" && password == ""))
                .contentShape(Rectangle())
            }
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
      .onAppear(perform: {
        if user_name != "" && password != "" {
          Task {
            await AuthUser()
          }
        }
      })
    }
  }

  func AuthUser() async {
    waiting = true
    var request = createRequest(
      url: base_url + "/api/token?user_name=\(user_name)&password=\(password)&device_name=iOS")
    request.httpMethod = "POST"
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let data = data {
        if let jsonData = try? JSONDecoder().decode(JsonUserBase.self, from: data) {
          Task { @MainActor in
            if jsonData.user?.role == ROLE_DOM || jsonData.user?.role == ROLE_SUB {
              user_token = jsonData.token ?? ""
              user_id = jsonData.user?.id ?? 0
              user_name = jsonData.user?.user_name ?? ""
              user_role = jsonData.user?.role ?? 0
              user_full_name = jsonData.user?.name ?? ""

              stateManager.changeLogin(state: true)
            }
          }

          Task { @MainActor in
            waiting = false
            if jsonData.message?.count ?? 0 > 0 {
              invalid_user = true
              showToast = true
            }
          }
        } else {
          showToast = true
        }
      }
    }.resume()
  }
}
