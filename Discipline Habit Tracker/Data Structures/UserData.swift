//
//  UserData.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-28.
//

import SwiftUI

struct User: Identifiable {
  let id: Int
  let name: String
  let user_name: String
  let role: Int
  let points: Int
  let created_at: String
  let updated_at: String
}

struct JsonUser: Codable {
  let id: Int?
  let name: String?
  let user_name: String?
  let role: Int?
  let points: Int?
  let created_at: String?
  let updated_at: String?

  enum CodingKeys: String, CodingKey {

    case id = "id"
    case name = "name"
    case user_name = "user_name"
    case role = "role"
    case points = "points"
    case created_at = "created_at"
    case updated_at = "updated_at"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decodeIfPresent(Int.self, forKey: .id)
    name = try values.decodeIfPresent(String.self, forKey: .name)
    user_name = try values.decodeIfPresent(String.self, forKey: .user_name)
    role = try values.decodeIfPresent(Int.self, forKey: .role)
    points = try values.decodeIfPresent(Int.self, forKey: .points)
    created_at = try values.decodeIfPresent(String.self, forKey: .created_at)
    updated_at = try values.decodeIfPresent(String.self, forKey: .updated_at)
  }

}

struct JsonUserBase: Codable {
  let token: String?
  let user: JsonUser?
  let message: String?

  enum CodingKeys: String, CodingKey {
    case token = "token"
    case user = "user"
    case message = "message"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    token = try values.decodeIfPresent(String.self, forKey: .token)
    user = try values.decodeIfPresent(JsonUser.self, forKey: .user)
    message = try values.decodeIfPresent(String.self, forKey: .message)
  }

}
