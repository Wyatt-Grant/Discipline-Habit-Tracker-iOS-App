//
//  PunishmentDetails.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-28.
//

import SimpleToast
import SwiftUI

struct SubRewardDetails: View {
  @Binding var reward: Reward
  @State private var waiting = false
  @State private var selectedOption = "Details"
  @State private var showToast = false

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Picker("Options", selection: $selectedOption) {
        Text("Details").tag("Details")
        Text("History").tag("History")
      }
      .padding()
      .pickerStyle(SegmentedPickerStyle())
      if selectedOption == "Details" {
        Text("Cost \(reward.value)")
          .font(.title)
          .padding()
        Text("Bank \(reward.bank)")
          .font(.title)
          .padding()
        Text(reward.description)
          .padding()
        Spacer()
        HStack {
          Spacer()
          Button(action: {
            Task {
              await incrimentReward(add: true, id: reward.id)
            }
          }) {
            Text("Buy")
              .bold()
              .foregroundColor(Color(UIColor.systemBackground))
              .frame(height: 50)
              .frame(maxWidth: .infinity)
              .background((waiting || points < reward.value) ? .gray : theme)
              .cornerRadius(10)
              .contentShape(Rectangle())
          }
          .disabled(waiting || points < reward.value)
          .padding()
          Spacer()
        }
      } else {
        RewardUsageHistory(reward: $reward)
        Spacer()
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
    .navigationBarTitle(reward.name, displayMode: .inline)
    .toolbarBackground(theme, for: .navigationBar)
  }

  func incrimentReward(add: Bool, id: Int) async {
    waiting = true
    var request = createAuthRequest(
      url: base_url + "/api/" + (add ? "add" : "remove") + "-reward/" + String(id))
    request.httpMethod = "POST"
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let data = data {
        reward = Reward(
          id: reward.id,
          name: reward.name,
          description: reward.description,
          value: reward.value,
          bank: reward.bank + (add ? 1 : -1),
          history: reward.history.map { history in
            RewardHistory(
              id: history.id,
              date: history.date,
              reward_id: history.reward_id,
              action: history.action,
              created_at: history.created_at,
              updated_at: history.updated_at
            )
          },
          tasks: reward.tasks
        )
      } else {
        showToast = true
      }
      waiting = false
    }.resume()
  }
}
