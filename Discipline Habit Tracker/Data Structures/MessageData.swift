//
//  MessageData.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-28.
//

import SwiftUI

/// Structure for message
struct Message: Identifiable {
  let id: Int
  let name: String
  let description: String
  let tasks: [Int]
}

/// Structure for message in json
struct JsonMessage: Codable {
  let id: Int?
  let dynamic_id: Int?
  let name: String?
  let description: String?
  let created_at: String?
  let updated_at: String?
  let tasks: [MessageTasks]?

  enum CodingKeys: String, CodingKey {

    case id = "id"
    case dynamic_id = "dynamic_id"
    case name = "name"
    case description = "description"
    case created_at = "created_at"
    case updated_at = "updated_at"
    case tasks = "tasks"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decodeIfPresent(Int.self, forKey: .id)
    dynamic_id = try values.decodeIfPresent(Int.self, forKey: .dynamic_id)
    name = try values.decodeIfPresent(String.self, forKey: .name)
    description = try values.decodeIfPresent(String.self, forKey: .description)
    created_at = try values.decodeIfPresent(String.self, forKey: .created_at)
    updated_at = try values.decodeIfPresent(String.self, forKey: .updated_at)
    tasks = try values.decodeIfPresent([MessageTasks].self, forKey: .tasks)
  }

}

/// Structure for message base
struct JsonMessageBase: Codable {
  let messages: [JsonMessage]?

  enum CodingKeys: String, CodingKey {

    case messages = "messages"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    messages = try values.decodeIfPresent([JsonMessage].self, forKey: .messages)
  }

}

/// Structure for message tasks
struct MessageTasks: Codable {
  let id: Int?
  let pivot: jsonMessagesTasksPivot?

  enum CodingKeys: String, CodingKey {

    case id = "id"
    case pivot = "pivot"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decodeIfPresent(Int.self, forKey: .id)
    pivot = try values.decodeIfPresent(jsonMessagesTasksPivot.self, forKey: .pivot)
  }

}

/// Structure for task_message pivot
struct jsonMessagesTasksPivot: Codable {
  let message_id: Int?
  let task_id: Int?

  enum CodingKeys: String, CodingKey {

    case message_id = "message_id"
    case task_id = "task_id"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    message_id = try values.decodeIfPresent(Int.self, forKey: .message_id)
    task_id = try values.decodeIfPresent(Int.self, forKey: .task_id)
  }

}

func messageTasksToIntArray(tasks: [MessageTasks]) -> [Int] {
  return tasks.map { task in
    let newObject = Int(task.id ?? 0)
    return newObject
  }
}

/// convert json to regular message
func JsonToMessage(message: JsonMessage) -> Message {
  return Message(
    id: message.id ?? 0,
    name: message.name ?? "",
    description: message.description ?? "",
    tasks: messageTasksToIntArray(tasks: message.tasks ?? [])
  )
}

/// clone a message
func cloneMessage(message: Message) -> Message {
  return Message(
    id: message.id,
    name: message.name,
    description: message.description,
    tasks: message.tasks
  )
}

/// create an empty message
func emptyMessage() -> Message {
  return Message(
    id: 0,
    name: "",
    description: "",
    tasks: []
  )
}
