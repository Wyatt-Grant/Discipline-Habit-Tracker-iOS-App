//
//  DynamicData.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-11-02.
//

import SwiftUI

/// Structure for dynamic
struct Dynamic: Identifiable {
  let id: Int
  let name: String
  let UUID: String
  let sub: String
  let dom: String
  let time_zone: String
  let default_reward_emojis: String
  let created_at: String
  let created_at_humans: String
}

/// Structure for dynamic in json
struct JsonDynamic: Codable {
  let id: Int?
  let name: String?
  let UUID: String?
  let sub: String?
  let dom: String?
  let time_zone: String?
  let default_reward_emojis: String?
  let created_at: String?
  let created_at_humans: String?

  enum CodingKeys: String, CodingKey {
    case id = "id"
    case name = "name"
    case UUID = "UUID"
    case sub = "sub"
    case dom = "dom"
    case time_zone = "time_zone"
    case default_reward_emojis = "default_reward_emojis"
    case created_at = "created_at"
    case created_at_humans = "created_at_humans"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decodeIfPresent(Int.self, forKey: .id)
    name = try values.decodeIfPresent(String.self, forKey: .name)
    UUID = try values.decodeIfPresent(String.self, forKey: .UUID)
    sub = try values.decodeIfPresent(String.self, forKey: .sub)
    dom = try values.decodeIfPresent(String.self, forKey: .dom)
    time_zone = try values.decodeIfPresent(String.self, forKey: .time_zone)
    default_reward_emojis = try values.decodeIfPresent(String.self, forKey: .default_reward_emojis)
    created_at = try values.decodeIfPresent(String.self, forKey: .created_at)
    created_at_humans = try values.decodeIfPresent(String.self, forKey: .created_at_humans)
  }

}

/// Structure for dynamic base
struct JsonDynamicBase: Codable {
  let dynamic: JsonDynamic?

  enum CodingKeys: String, CodingKey {
    case dynamic = "dynamic"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    dynamic = try values.decodeIfPresent(JsonDynamic.self, forKey: .dynamic)
  }

}

/// convert dynamic to regular rule
func JsonToDynamic(dynamic: JsonDynamic) -> Dynamic {
  return Dynamic(
    id: dynamic.id ?? 0,
    name: dynamic.name ?? "",
    UUID: dynamic.UUID ?? "",
    sub: dynamic.sub ?? "",
    dom: dynamic.dom ?? "",
    time_zone: dynamic.time_zone ?? "",
    default_reward_emojis: dynamic.default_reward_emojis ?? "",
    created_at: dynamic.created_at ?? "",
    created_at_humans: dynamic.created_at ?? ""
  )
}

/// clone a dynamic
func cloneDynamic(dynamic: Dynamic) -> Dynamic {
  return Dynamic(
    id: dynamic.id,
    name: dynamic.name,
    UUID: dynamic.UUID,
    sub: dynamic.sub,
    dom: dynamic.dom,
    time_zone: dynamic.time_zone,
    default_reward_emojis: dynamic.default_reward_emojis,
    created_at: dynamic.created_at,
    created_at_humans: dynamic.created_at
  )
}

/// create an empty dynamic
func emptyDynamic() -> Dynamic {
  return Dynamic(
    id: 0,
    name: "",
    UUID: "",
    sub: "",
    dom: "",
    time_zone: "",
    default_reward_emojis: "",
    created_at: "",
    created_at_humans: ""
  )
}
