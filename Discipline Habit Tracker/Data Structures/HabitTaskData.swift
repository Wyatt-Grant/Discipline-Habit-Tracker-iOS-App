//
//  TasksData.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-27.
//

import SwiftUI

/// Structure for basic tasks
struct HabitTask: Identifiable {
  let id: Int
  let group_id: Int
  let color: String
  let name: String
  let description: String
  let value: Int
  let count: Int
  let max_count: Int
  let target_count: Int
  let history: [History]
  let rrule: String
  let start: String?
  let end: String?
  let remove_points_on_failure: Int
  let is_task_due_today: Int
  let rule_text: String
  let remind: Int
  let remind_time: String?
  let restrict: Int
  let restrict_before: Int
  let restrict_time: String?
  let time_zone: String
}

/// Structure for basic tasks in json
struct JsonHabitTask: Codable {
  let id: Int?
  let group_id: Int?
  let color: String?
  let dynamic_id: Int?
  let name: String?
  let description: String?
  let value: Int?
  let count: Int?
  let target_count: Int?
  let max_count: Int?
  let created_at: String?
  let updated_at: String?
  let history: [JsonHistory]?
  let rrule: String?
  let start: String?
  let end: String?
  let remove_points_on_failure: Int?
  let is_task_due_today: Int?
  let rule_text: String?
  let remind: Int?
  let remind_time: String?
  let restrict: Int?
  let restrict_before: Int?
  let restrict_time: String?
  let time_zone: String?

  enum CodingKeys: String, CodingKey {
    case id = "id"
    case group_id = "group_id"
    case color = "color"
    case dynamic_id = "dynamic_id"
    case name = "name"
    case description = "description"
    case value = "value"
    case count = "count"
    case target_count = "target_count"
    case max_count = "max_count"
    case created_at = "created_at"
    case updated_at = "updated_at"
    case history = "history"
    case rrule = "rrule"
    case start = "start"
    case end = "end"
    case remove_points_on_failure = "remove_points_on_failure"
    case is_task_due_today = "is_task_due_today"
    case rule_text = "rule_text"
    case remind = "remind"
    case remind_time = "remind_time"
    case restrict = "restrict"
    case restrict_before = "restrict_before"
    case restrict_time = "restrict_time"
    case time_zone = "time_zone"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decodeIfPresent(Int.self, forKey: .id)
    group_id = try values.decodeIfPresent(Int.self, forKey: .group_id)
    color = try values.decodeIfPresent(String.self, forKey: .color)
    dynamic_id = try values.decodeIfPresent(Int.self, forKey: .dynamic_id)
    name = try values.decodeIfPresent(String.self, forKey: .name)
    description = try values.decodeIfPresent(String.self, forKey: .description)
    value = try values.decodeIfPresent(Int.self, forKey: .value)
    count = try values.decodeIfPresent(Int.self, forKey: .count)
    target_count = try values.decodeIfPresent(Int.self, forKey: .target_count)
    max_count = try values.decodeIfPresent(Int.self, forKey: .max_count)
    created_at = try values.decodeIfPresent(String.self, forKey: .created_at)
    updated_at = try values.decodeIfPresent(String.self, forKey: .updated_at)
    history = try values.decodeIfPresent([JsonHistory].self, forKey: .history)
    rrule = try values.decodeIfPresent(String.self, forKey: .rrule)
    start = try values.decodeIfPresent(String.self, forKey: .start)
    end = try values.decodeIfPresent(String.self, forKey: .end)
    remove_points_on_failure = try values.decodeIfPresent(
      Int.self, forKey: .remove_points_on_failure)
    is_task_due_today = try values.decodeIfPresent(Int.self, forKey: .is_task_due_today)
    rule_text = try values.decodeIfPresent(String.self, forKey: .rule_text)
    remind = try values.decodeIfPresent(Int.self, forKey: .remind)
    remind_time = try values.decodeIfPresent(String.self, forKey: .remind_time)
    restrict = try values.decodeIfPresent(Int.self, forKey: .restrict)
    restrict_before = try values.decodeIfPresent(Int.self, forKey: .restrict_before)
    restrict_time = try values.decodeIfPresent(String.self, forKey: .restrict_time)
    time_zone = try values.decodeIfPresent(String.self, forKey: .time_zone)
  }

}

/// Structure for basic history
struct History: Identifiable {
  let id: Int
  let date: String
  let task_id: Int
  let was_complete: Int
  let count: Int
  let target_count: Int
  let created_at: String
  let updated_at: String
}

/// Structure for basic history in json
struct JsonHistory: Codable {
  let id: Int?
  let date: String?
  let task_id: Int?
  let was_complete: Int?
  let count: Int?
  let target_count: Int?
  let created_at: String?
  let updated_at: String?

  enum CodingKeys: String, CodingKey {

    case id = "id"
    case date = "date"
    case task_id = "task_id"
    case was_complete = "was_complete"
    case count = "count"
    case target_count = "target_count"
    case created_at = "created_at"
    case updated_at = "updated_at"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decodeIfPresent(Int.self, forKey: .id)
    date = try values.decodeIfPresent(String.self, forKey: .date)
    task_id = try values.decodeIfPresent(Int.self, forKey: .task_id)
    was_complete = try values.decodeIfPresent(Int.self, forKey: .was_complete)
    count = try values.decodeIfPresent(Int.self, forKey: .count)
    target_count = try values.decodeIfPresent(Int.self, forKey: .target_count)
    created_at = try values.decodeIfPresent(String.self, forKey: .created_at)
    updated_at = try values.decodeIfPresent(String.self, forKey: .updated_at)
  }

}

/// Structure for task base
struct JsonTaskBase: Codable {
  let tasks: [JsonHabitTask]?

  enum CodingKeys: String, CodingKey {
    case tasks = "tasks"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    tasks = try values.decodeIfPresent([JsonHabitTask].self, forKey: .tasks)
  }

}

/// convert json to regular HabitTask
func JsonToHabitTask(habitTask: JsonHabitTask) -> HabitTask {
  return HabitTask(
    id: habitTask.id ?? 0,
    group_id: habitTask.group_id ?? 0,
    color: habitTask.color ?? "",
    name: habitTask.name ?? "",
    description: habitTask.description ?? "",
    value: habitTask.value ?? 0,
    count: habitTask.count ?? 0,
    max_count: habitTask.max_count ?? 0,
    target_count: habitTask.target_count ?? 0,
    history: habitTask.history?.map { history in
      History(
        id: history.id ?? 0,
        date: history.date ?? "",
        task_id: history.task_id ?? 0,
        was_complete: history.was_complete ?? 0,
        count: history.count ?? 0,
        target_count: history.target_count ?? 0,
        created_at: history.created_at ?? "",
        updated_at: history.updated_at ?? ""
      )
    } ?? [
      History(
        id: 0,
        date: "",
        task_id: 0,
        was_complete: 0,
        count: 0,
        target_count: 0,
        created_at: "",
        updated_at: ""
      )
    ],
    rrule: habitTask.rrule ?? "",
    start: habitTask.start ?? "",
    end: habitTask.end ?? "",
    remove_points_on_failure: habitTask.remove_points_on_failure ?? 0,
    is_task_due_today: habitTask.is_task_due_today ?? 0,
    rule_text: habitTask.rule_text ?? "",
    remind: habitTask.remind ?? 0,
    remind_time: habitTask.remind_time ?? "",
    restrict: habitTask.restrict ?? 0,
    restrict_before: habitTask.restrict_before ?? 0,
    restrict_time: habitTask.restrict_time ?? "",
    time_zone: habitTask.time_zone ?? ""

  )
}

/// clone a HabitTask
func cloneHabitTask(habitTask: HabitTask) -> HabitTask {
  return HabitTask(
    id: habitTask.id,
    group_id: habitTask.group_id,
    color: habitTask.color,
    name: habitTask.name,
    description: habitTask.description,
    value: habitTask.value,
    count: habitTask.count,
    max_count: habitTask.max_count,
    target_count: habitTask.target_count,
    history: habitTask.history.map { history in
      History(
        id: history.id,
        date: history.date,
        task_id: history.task_id,
        was_complete: history.was_complete,
        count: history.count,
        target_count: history.target_count,
        created_at: history.created_at,
        updated_at: history.updated_at
      )
    },
    rrule: habitTask.rrule,
    start: habitTask.start,
    end: habitTask.end,
    remove_points_on_failure: habitTask.remove_points_on_failure,
    is_task_due_today: habitTask.is_task_due_today,
    rule_text: habitTask.rule_text,
    remind: habitTask.remind,
    remind_time: habitTask.remind_time,
    restrict: habitTask.restrict,
    restrict_before: habitTask.restrict_before,
    restrict_time: habitTask.restrict_time,
    time_zone: habitTask.time_zone
  )
}

/// create an empty HabitTask
func emptyHabitTask() -> HabitTask {
  return HabitTask(
    id: 0,
    group_id: 0,
    color: "",
    name: "",
    description: "",
    value: 0,
    count: 0,
    max_count: 0,
    target_count: 0,
    history: [
      History(
        id: 0,
        date: "",
        task_id: 0,
        was_complete: 0,
        count: 0,
        target_count: 0,
        created_at: "",
        updated_at: ""
      )
    ],
    rrule: "",
    start: nil,
    end: nil,
    remove_points_on_failure: 0,
    is_task_due_today: 0,
    rule_text: "",
    remind: 0,
    remind_time: "",
    restrict: 0,
    restrict_before: 0,
    restrict_time: "",
    time_zone: ""
  )
}
