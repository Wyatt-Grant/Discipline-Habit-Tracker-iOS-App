//
//  SubRewards.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-28.
//

import SimpleToast
import SwiftUI

struct SubRewards: View {
  @Environment(\.scenePhase) private var scenePhase

  @State private var waiting = true
  @State private var showRewardsDetailsView = false
  @State private var showingDeleteAlert = false
  @State private var rewards = [Reward]()
  @State private var selectedReward = emptyReward()
  @State private var localPoints = -9_999_999
  @State private var timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
  @State private var showToast = false

  var body: some View {
    NavigationStack {
      VStack {
        if waiting && rewards.count == 0 {
          ProgressView("Loading")
        } else {
          ZStack {
            VStack(spacing: 0) {
              List {
                ForEach(rewards) { reward in
                  RewardRow(reward: reward, showBank: false, showCost: true)
                    .listRowInsets(EdgeInsets())
                    .contentShape(Rectangle())
                    .onTapGesture {
                      selectedReward = cloneReward(reward: reward)
                      showRewardsDetailsView = true
                    }
                }
              }
              .listStyle(.plain)
              .refreshable {
                Task {
                  await getRewards()
                  await getPoints()
                }
              }
              .navigationTitle("Rewards")
              .navigationDestination(isPresented: $showRewardsDetailsView) {
                SubRewardDetails(reward: $selectedReward)
              }
              .navigationBarItems(
                trailing:
                  VStack {
                    Text(localPoints == -9_999_999 ? "Loading" : "\(localPoints) Points")
                  }
              )
            }
          }
        }
      }
      .onReceive(timer) { _ in
        localPoints = points
      }
      .onChange(of: scenePhase) { newScenePhase, oldScenePhase in
        if newScenePhase == .background {
          Task {
            await getRewards()
            await getPoints()
          }
        }
      }
      .onAppear {
        Task {
          await getRewards()
          await getPoints()
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

  func getRewards() async {
    var request = createAuthRequest(url: base_url + "/api/rewards")
    request.httpMethod = "GET"
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let data = data {
        if let jsonData = try? JSONDecoder().decode(JsonRewardBase.self, from: data) {
          withAnimation {
            if jsonData.rewards?.count != rewards.count {
              rewards = [Reward]()
              for reward in jsonData.rewards ?? [JsonReward]() {
                rewards.append(JsonToReward(reward: reward))
              }
            } else {
              var index = 0
              for reward in jsonData.rewards ?? [JsonReward]() {
                rewards[index] = JsonToReward(reward: reward)
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
}
