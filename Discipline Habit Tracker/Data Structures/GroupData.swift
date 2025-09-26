//
//  GroupData.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-11-26.
//

import SwiftUI

/// Structure for group
struct Group: Identifiable {
  let id: Int
  let name: String
  let color: String
}

/// Structure for group in json
struct JsonGroup: Codable {
  let id: Int?
  let dynamic_id: Int?
  let name: String?
  let color: String?
  let created_at: String?
  let updated_at: String?

  enum CodingKeys: String, CodingKey {

    case id = "id"
    case dynamic_id = "dynamic_id"
    case name = "name"
    case color = "color"
    case created_at = "created_at"
    case updated_at = "updated_at"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decodeIfPresent(Int.self, forKey: .id)
    dynamic_id = try values.decodeIfPresent(Int.self, forKey: .dynamic_id)
    name = try values.decodeIfPresent(String.self, forKey: .name)
    color = try values.decodeIfPresent(String.self, forKey: .color)
    created_at = try values.decodeIfPresent(String.self, forKey: .created_at)
    updated_at = try values.decodeIfPresent(String.self, forKey: .updated_at)
  }
}

/// Structure for group base
struct JsonGroupBase: Codable {
  let groups: [JsonGroup]?

  enum CodingKeys: String, CodingKey {

    case groups = "groups"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    groups = try values.decodeIfPresent([JsonGroup].self, forKey: .groups)
  }

}

/// convert json to regular group
func JsonToGroup(group: JsonGroup) -> Group {
  return Group(
    id: group.id ?? 0,
    name: group.name ?? "",
    color: group.color ?? ""
  )
}

/// clone a group
func cloneGroup(group: Group) -> Group {
  return Group(
    id: group.id,
    name: group.name,
    color: group.color
  )
}

/// create an empty group
func emptyGroup() -> Group {
  return Group(
    id: 0,
    name: "",
    color: ""
  )
}
