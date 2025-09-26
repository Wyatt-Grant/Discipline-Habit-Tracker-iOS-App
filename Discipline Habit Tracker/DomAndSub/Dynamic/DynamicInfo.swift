//
//  DynamicInfo.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-11-02.
//

import SimpleToast
import SwiftUI

struct DynamicInfo: View {
  @Environment(\.scenePhase) private var scenePhase

  @State private var waiting = true
  @State private var dynamic = emptyDynamic()
  @State private var showToast = false

  var body: some View {
    NavigationStack {
      VStack {
        if waiting && dynamic.id == 0 {
          ProgressView("Loading")
        } else {
          VStack {
            Text("Name")
              .font(.headline)
              .foregroundColor(.gray)
            Text(dynamic.name)
              .font(.title)
            Spacer()
            Text("UUID")
              .font(.headline)
              .foregroundColor(.gray)
            Text(dynamic.UUID)
              .font(.title)
              .contextMenu {
                Button(action: {
                  UIPasteboard.general.string = dynamic.UUID
                }) {
                  Text("Copy to clipboard")
                  Image(systemName: "doc.on.doc")
                }
              }
            Spacer()
            Text("Time Zone")
              .font(.headline)
              .foregroundColor(.gray)
            Text(dynamic.time_zone)
              .font(.title)
            Spacer()
            Text("Dominant")
              .font(.headline)
              .foregroundColor(.gray)
            Text(dynamic.dom)
              .font(.title)
            Spacer()
            Text("Submissive")
              .font(.headline)
              .foregroundColor(.gray)
            Text(dynamic.sub)
              .font(.title)
            Spacer()
            Text("Created")
              .font(.headline)
              .foregroundColor(.gray)
            Text(dynamic.created_at)
              .font(.title)
            Text("(~\(dynamic.created_at_humans))")
              .font(.title)
            Spacer()
            Spacer()
          }
        }
      }
      .padding()
      .navigationBarHidden(true)
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
      .onAppear {
        Task {
          await getDynamic()
        }
      }
    }
  }

  func getDynamic() async {
    waiting = true
    var request = createAuthRequest(url: base_url + "/api/dynamic")
    request.httpMethod = "GET"
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      waiting = false
      if let data = data {
        if let jsonData = try? JSONDecoder().decode(JsonDynamicBase.self, from: data) {
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
        } else {
          showToast = true
        }
      } else {
        showToast = true
      }
    }.resume()
  }
}
