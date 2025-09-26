//
//  SecureTextFieldWithReveal.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2024-01-08.
//

import SwiftUI

struct SecureTextFieldWithReveal: View {
  @Environment(\.colorScheme) var colorScheme

  @FocusState var focus1: Bool
  @FocusState var focus2: Bool
  @State var showPassword: Bool = false
  @Binding var text: String
  @Binding var waiting: Bool
  @Binding var invalid: Bool

  var body: some View {
    HStack {
      ZStack(alignment: .trailing) {
        if showPassword {
          TextField("Password", text: $text)
            .padding()
            .textContentType(.password)
            .focused($focus1)
            .frame(width: 350)
            .background(colorScheme == .dark ? .white.opacity(0.20) : .black.opacity(0.05))
            .cornerRadius(10)
            .disabled(waiting)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .overlay(
              RoundedRectangle(cornerRadius: 10)
                .stroke(Color.red, lineWidth: invalid ? 2 : 0)
            )
        } else {
          SecureField("Password", text: $text)
            .padding()
            .textContentType(.password)
            .focused($focus2)
            .frame(width: 350)
            .background(colorScheme == .dark ? .white.opacity(0.20) : .black.opacity(0.05))
            .cornerRadius(10)
            .disabled(waiting)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .overlay(
              RoundedRectangle(cornerRadius: 10)
                .stroke(Color.red, lineWidth: invalid ? 2 : 0)
            )
        }
        Button(
          action: {
            showPassword.toggle()
            if showPassword { focus1 = true } else { focus2 = true }
          },
          label: {
            Image(systemName: self.showPassword ? "eye.slash.fill" : "eye.fill")
              .foregroundColor(.gray)
              .font(.system(size: 16, weight: .regular))
              .padding()
          })
      }
    }
  }
}
