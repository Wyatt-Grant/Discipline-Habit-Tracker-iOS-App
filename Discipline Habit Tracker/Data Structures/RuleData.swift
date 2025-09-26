//
//  RuleData.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-11-01.
//

import SwiftUI

/// Structure for rule
struct Rule: Identifiable {
  let id: Int
  let description: String
}

/// Structure for rule in json
struct JsonRule: Codable {
  let id: Int?
  let dynamic_id: Int?
  let description: String?
  let created_at: String?
  let updated_at: String?

  enum CodingKeys: String, CodingKey {

    case id = "id"
    case dynamic_id = "dynamic_id"
    case description = "description"
    case created_at = "created_at"
    case updated_at = "updated_at"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decodeIfPresent(Int.self, forKey: .id)
    dynamic_id = try values.decodeIfPresent(Int.self, forKey: .dynamic_id)
    description = try values.decodeIfPresent(String.self, forKey: .description)
    created_at = try values.decodeIfPresent(String.self, forKey: .created_at)
    updated_at = try values.decodeIfPresent(String.self, forKey: .updated_at)
  }

}

/// Structure for rule base
struct JsonRuleBase: Codable {
  let rules: [JsonRule]?

  enum CodingKeys: String, CodingKey {

    case rules = "rules"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    rules = try values.decodeIfPresent([JsonRule].self, forKey: .rules)
  }

}

/// convert json to regular rule
func JsonToRule(rule: JsonRule) -> Rule {
  return Rule(
    id: rule.id ?? 0,
    description: rule.description ?? ""
  )
}

/// clone a rule
func cloneRule(rule: Rule) -> Rule {
  return Rule(
    id: rule.id,
    description: rule.description
  )
}

/// create an empty rule
func emptyRule() -> Rule {
  return Rule(
    id: 0,
    description: ""
  )
}
