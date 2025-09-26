//
//  ReminderData.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-11-30.
//

import SwiftUI

/// Structure for group
struct Reminder: Identifiable {
  let id: String
  let date_time: String
  let title: String
  let description: String
  let count: String
  let time_zone: String
}

/// Structure for group in json
struct JsonReminder: Codable {
  let id: String?
  let date_time: String?
  let title: String?
  let description: String?
  let count: String?
  let time_zone: String?

  enum CodingKeys: String, CodingKey {
    case id = "id"
    case date_time = "date_time"
    case title = "title"
    case description = "description"
    case count = "count"
    case time_zone = "time_zone"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decodeIfPresent(String.self, forKey: .id)
    date_time = try values.decodeIfPresent(String.self, forKey: .date_time)
    title = try values.decodeIfPresent(String.self, forKey: .title)
    description = try values.decodeIfPresent(String.self, forKey: .description)
    count = try values.decodeIfPresent(String.self, forKey: .count)
    time_zone = try values.decodeIfPresent(String.self, forKey: .time_zone)
  }
}

struct JsonReminderBase: Codable {
  let reminders: [JsonReminder]?

  enum CodingKeys: String, CodingKey {

    case reminders = "reminders"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    reminders = try values.decodeIfPresent([JsonReminder].self, forKey: .reminders)
  }
}

/// convert json to regular group
func JsonToReminder(reminder: JsonReminder) -> Reminder {
  return Reminder(
    id: reminder.id ?? "",
    date_time: reminder.date_time ?? "",
    title: reminder.title ?? "",
    description: reminder.description ?? "",
    count: reminder.count ?? "",
    time_zone: reminder.time_zone ?? ""
  )
}
