//
//  GenericData.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-29.
//

import SwiftUI

struct JsonCountBase: Codable {
  let count: String?

  enum CodingKeys: String, CodingKey {

    case count = "count"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    count = try values.decodeIfPresent(String.self, forKey: .count)
  }
}

struct JsonCompleteMessageBase: Codable {
  let message: String?
  let emojis: String?

  enum CodingKeys: String, CodingKey {

    case message = "message"
    case emojis = "emojis"
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    message = try values.decodeIfPresent(String.self, forKey: .message)
    emojis = try values.decodeIfPresent(String.self, forKey: .emojis)
  }
}
