//
//  PunishmentData.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-28.
//

import SwiftUI

/// Structure for punishments
struct Punishment: Identifiable {
  let id: Int
  let name: String
  let description: String
  let value: Int
  let history: [PunishmentHistory]
  let tasks: [Int]
}

/// Structure for punishments in json
struct JsonPunishment: Codable {
  let id: Int?
  let dynamic_id: Int?
  let name: String?
  let description: String?
  let value: Int?
  let created_at: String?
  let updated_at: String?
  let history: [PunishmentJsonHistory]?
  let tasks: [PunishmentTasks]?

  enum CodingKeys: String, CodingKey {

    case id = "id"
    case dynamic_id = "dynamic_id"
    case name = "name"
    case description = "description"
    case value = "value"
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
    created_at = try values.decodeIfPresent(String.self, forKey: .created_at)
    updated_at = try values.decodeIfPresent(String.self, forKey: .updated_at)
    history = try values.decodeIfPresent([PunishmentJsonHistory].self, forKey: .history)
    tasks = try values.decodeIfPresent([PunishmentTasks].self, forKey: .tasks)
  }

}

/// Structure for punishment base
struct JsonPunishmentBase: Codable {
  let punishments: [JsonPunishment]?

  enum CodingKeys: String, CodingKey {
    case punishments = "punishments"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    punishments = try values.decodeIfPresent([JsonPunishment].self, forKey: .punishments)
  }

}

/// Structure for punishment basic history
struct PunishmentHistory: Identifiable {
  let id: Int
  let date: String
  let punishment_id: Int
  let action: Int
  let created_at: String
  let updated_at: String
}

/// Structure for punishment history base
struct PunishmentJsonHistory: Codable {
  let id: Int?
  let date: String?
  let punishment_id: Int?
  let action: Int?
  let created_at: String?
  let updated_at: String?

  enum CodingKeys: String, CodingKey {

    case id = "id"
    case date = "date"
    case punishment_id = "punishment_id"
    case action = "action"
    case created_at = "created_at"
    case updated_at = "updated_at"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decodeIfPresent(Int.self, forKey: .id)
    date = try values.decodeIfPresent(String.self, forKey: .date)
    punishment_id = try values.decodeIfPresent(Int.self, forKey: .punishment_id)
    action = try values.decodeIfPresent(Int.self, forKey: .action)
    created_at = try values.decodeIfPresent(String.self, forKey: .created_at)
    updated_at = try values.decodeIfPresent(String.self, forKey: .updated_at)
  }

}

/// Structure for punishment tasks
struct PunishmentTasks: Codable {
  let id: Int?
  let pivot: jsonPunishmentsTasksPivot?

  enum CodingKeys: String, CodingKey {

    case id = "id"
    case pivot = "pivot"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decodeIfPresent(Int.self, forKey: .id)
    pivot = try values.decodeIfPresent(jsonPunishmentsTasksPivot.self, forKey: .pivot)
  }

}

/// Structure for task_punishment pivot
struct jsonPunishmentsTasksPivot: Codable {
  let punishment_id: Int?
  let task_id: Int?

  enum CodingKeys: String, CodingKey {

    case punishment_id = "punishment_id"
    case task_id = "task_id"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    punishment_id = try values.decodeIfPresent(Int.self, forKey: .punishment_id)
    task_id = try values.decodeIfPresent(Int.self, forKey: .task_id)
  }

}

func punishmentTasksToIntArray(tasks: [PunishmentTasks]) -> [Int] {
  return tasks.map { task in
    let newObject = Int(task.id ?? 0)
    return newObject
  }
}

/// convert json to regular punishment
func JsonToPunishment(punishment: JsonPunishment) -> Punishment {
  return Punishment(
    id: punishment.id ?? 0,
    name: punishment.name ?? "",
    description: punishment.description ?? "",
    value: punishment.value ?? 0,
    history: punishment.history?.map { history in
      PunishmentHistory(
        id: history.id ?? 0,
        date: history.date ?? "",
        punishment_id: history.punishment_id ?? 0,
        action: history.action ?? -1,
        created_at: history.created_at ?? "",
        updated_at: history.updated_at ?? ""
      )
    } ?? [
      PunishmentHistory(
        id: 0,
        date: "",
        punishment_id: 0,
        action: -1,
        created_at: "",
        updated_at: ""
      )
    ],
    tasks: punishmentTasksToIntArray(tasks: punishment.tasks ?? [])
  )
}

/// clone a punishment
func clonePunishment(punishment: Punishment) -> Punishment {
  return Punishment(
    id: punishment.id,
    name: punishment.name,
    description: punishment.description,
    value: punishment.value,
    history: punishment.history.map { history in
      PunishmentHistory(
        id: history.id,
        date: history.date,
        punishment_id: history.punishment_id,
        action: history.action,
        created_at: history.created_at,
        updated_at: history.updated_at
      )
    },
    tasks: punishment.tasks
  )
}

/// create an empty punishment
func emptyPunishment() -> Punishment {
  return Punishment(
    id: 0,
    name: "",
    description: "",
    value: 0,
    history: [
      PunishmentHistory(
        id: 0,
        date: "",
        punishment_id: 0,
        action: -1,
        created_at: "",
        updated_at: ""
      )
    ],
    tasks: []
  )
}
