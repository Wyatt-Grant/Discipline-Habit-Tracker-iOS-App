//
//  RewardData.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-28.
//

import SwiftUI

/// Structure for rewards
struct Reward: Identifiable {
  let id: Int
  let name: String
  let description: String
  let value: Int
  let bank: Int
  let history: [RewardHistory]
  let tasks: [Int]
}

/// Structure for rewards in json
struct JsonReward: Codable {
  let id: Int?
  let dynamic_id: Int?
  let name: String?
  let description: String?
  let value: Int?
  let bank: Int?
  let created_at: String?
  let updated_at: String?
  let history: [RewardJsonHistory]?
  let tasks: [RewardTasks]?

  enum CodingKeys: String, CodingKey {
    case id = "id"
    case dynamic_id = "dynamic_id"
    case name = "name"
    case description = "description"
    case value = "value"
    case bank = "bank"
    case created_at = "created_at"
    case updated_at = "updated_at"
    case history = "history"
    case tasks = "tasks"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decodeIfPresent(Int.self, forKey: .id)
    dynamic_id = try values.decodeIfPresent(Int.self, forKey: .dynamic_id)
    name = try values.decodeIfPresent(String.self, forKey: .name)
    description = try values.decodeIfPresent(String.self, forKey: .description)
    value = try values.decodeIfPresent(Int.self, forKey: .value)
    bank = try values.decodeIfPresent(Int.self, forKey: .bank)
    created_at = try values.decodeIfPresent(String.self, forKey: .created_at)
    updated_at = try values.decodeIfPresent(String.self, forKey: .updated_at)
    history = try values.decodeIfPresent([RewardJsonHistory].self, forKey: .history)
    tasks = try values.decodeIfPresent([RewardTasks].self, forKey: .tasks)
  }

}

/// Structure for reward base
struct JsonRewardBase: Codable {
  let rewards: [JsonReward]?

  enum CodingKeys: String, CodingKey {

    case rewards = "rewards"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    rewards = try values.decodeIfPresent([JsonReward].self, forKey: .rewards)
  }

}

/// Structure for reward basic history
struct RewardHistory: Identifiable {
  let id: Int
  let date: String
  let reward_id: Int
  let action: Int
  let created_at: String
  let updated_at: String
}

/// Structure for reward history base
struct RewardJsonHistory: Codable {
  let id: Int?
  let date: String?
  let reward_id: Int?
  let action: Int?
  let created_at: String?
  let updated_at: String?

  enum CodingKeys: String, CodingKey {

    case id = "id"
    case date = "date"
    case reward_id = "reward_id"
    case action = "action"
    case created_at = "created_at"
    case updated_at = "updated_at"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decodeIfPresent(Int.self, forKey: .id)
    date = try values.decodeIfPresent(String.self, forKey: .date)
    reward_id = try values.decodeIfPresent(Int.self, forKey: .reward_id)
    action = try values.decodeIfPresent(Int.self, forKey: .action)
    created_at = try values.decodeIfPresent(String.self, forKey: .created_at)
    updated_at = try values.decodeIfPresent(String.self, forKey: .updated_at)
  }

}

/// Structure for reward tasks
struct RewardTasks: Codable {
  let id: Int?
  let pivot: jsonRewardsTasksPivot?

  enum CodingKeys: String, CodingKey {

    case id = "id"
    case pivot = "pivot"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decodeIfPresent(Int.self, forKey: .id)
    pivot = try values.decodeIfPresent(jsonRewardsTasksPivot.self, forKey: .pivot)
  }

}

/// Structure for task_reward pivot
struct jsonRewardsTasksPivot: Codable {
  let reward_id: Int?
  let task_id: Int?

  enum CodingKeys: String, CodingKey {

    case reward_id = "reward_id"
    case task_id = "task_id"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    reward_id = try values.decodeIfPresent(Int.self, forKey: .reward_id)
    task_id = try values.decodeIfPresent(Int.self, forKey: .task_id)
  }

}

func rewardTasksToIntArray(tasks: [RewardTasks]) -> [Int] {
  return tasks.map { task in
    let newObject = Int(task.id ?? 0)
    return newObject
  }
}

/// Structure for points base
struct JsonPointsBase: Codable {
  let points: Int?

  enum CodingKeys: String, CodingKey {
    case points = "points"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    points = try values.decodeIfPresent(Int.self, forKey: .points)
  }

}

/// convert json to regular reward
func JsonToReward(reward: JsonReward) -> Reward {
  return Reward(
    id: reward.id ?? 0,
    name: reward.name ?? "",
    description: reward.description ?? "",
    value: reward.value ?? 0,
    bank: reward.bank ?? 0,
    history: reward.history?.map { history in
      RewardHistory(
        id: history.id ?? 0,
        date: history.date ?? "",
        reward_id: history.reward_id ?? 0,
        action: history.action ?? -1,
        created_at: history.created_at ?? "",
        updated_at: history.updated_at ?? ""
      )
    } ?? [
      RewardHistory(
        id: 0,
        date: "",
        reward_id: 0,
        action: -1,
        created_at: "",
        updated_at: ""
      )
    ],
    tasks: rewardTasksToIntArray(tasks: reward.tasks ?? [])
  )
}

/// clone a reward
func cloneReward(reward: Reward) -> Reward {
  return Reward(
    id: reward.id,
    name: reward.name,
    description: reward.description,
    value: reward.value,
    bank: reward.bank,
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
}

/// create an empty reward
func emptyReward() -> Reward {
  return Reward(
    id: 0,
    name: "",
    description: "",
    value: 0,
    bank: 0,
    history: [
      RewardHistory(
        id: 0,
        date: "",
        reward_id: 0,
        action: -1,
        created_at: "",
        updated_at: ""
      )
    ],
    tasks: []
  )
}
