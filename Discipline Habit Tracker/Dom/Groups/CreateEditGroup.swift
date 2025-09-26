//
//  CreateEditGroup.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-11-26.
//

import SimpleToast
import SwiftUI

struct CreateEditGroup: View {
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.presentationMode) var presentation

  @Binding var group: Group
  public var editMode = false

  @State private var name = ""
  @State private var selectedColor = Color.yellow
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
          TextField("Name", text: $name, axis: .vertical)
            .padding()
            .frame(width: 350)
            .background(colorScheme == .dark ? .white.opacity(0.20) : .black.opacity(0.05))
            .cornerRadius(10)
            .contentShape(Rectangle())
          ColorPicker("Color", selection: $selectedColor)
            .frame(width: 350)
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
            await createGroup()
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
    }
    .navigationBarTitle(editMode ? "Edit Group" : "Create New group", displayMode: .inline)
    .contentShape(Rectangle())
    .onAppear {
      if editMode {
        name = group.name
        selectedColor = Color(hex: group.color)
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

  func createGroup() async {
    waiting = true
    var request = createAuthRequest(
      url: base_url + "/api/group" + (editMode ? "/\(group.id)" : "s"))
    request.httpMethod = editMode ? "PUT" : "POST"
    let body: [String: Any] = ["name": name, "color": selectedColor.toHex ?? ""]
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
