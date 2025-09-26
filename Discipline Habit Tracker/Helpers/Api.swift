//
//  TasksApi.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-27.
//

import SwiftUI

func createAuthRequest(url: String) -> URLRequest {
  let serviceUrl = URL(string: url)!
  var request = URLRequest(url: serviceUrl)
  request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
  request.setValue("Application/json", forHTTPHeaderField: "Accept")
  request.setValue("Bearer \(user_token)", forHTTPHeaderField: "Authorization")
  request.timeoutInterval = 30

  return request
}

func createRequest(url: String) -> URLRequest {
  let serviceUrl = URL(string: url)!
  var request = URLRequest(url: serviceUrl)
  request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
  request.setValue("Application/json", forHTTPHeaderField: "Accept")
  request.timeoutInterval = 30

  return request
}

func getPoints() async {
  var request = createAuthRequest(url: base_url + "/api/points")
  request.httpMethod = "GET"
  URLSession.shared.dataTask(with: request) { (data, response, error) in
    if let data = data {
      if let jsonData = try? JSONDecoder().decode(JsonPointsBase.self, from: data) {
        points = jsonData.points ?? 0
      }
    }
  }.resume()
}

func incrementPoints(add: Bool) async {
  var request = createAuthRequest(url: base_url + "/api/" + (add ? "add-" : "remove-") + "point")
  request.httpMethod = "POST"
  URLSession.shared.dataTask(with: request) { (data, response, error) in
    if let data = data {
      if let jsonData = try? JSONDecoder().decode(JsonPointsBase.self, from: data) {
        points = jsonData.points ?? 0
      }
    }
  }.resume()
}

func getRemaining() async {
  var request = createAuthRequest(url: base_url + "/api/tasks/remaining")
  request.httpMethod = "GET"
  URLSession.shared.dataTask(with: request) { (data, response, error) in
    if let data = data {
      if let jsonData = try? JSONDecoder().decode(JsonCountBase.self, from: data) {
        remaining = Int(jsonData.count ?? "") ?? 0
      }
    }
  }.resume()
}

func getBank() async {
  var request = createAuthRequest(url: base_url + "/api/bank")
  request.httpMethod = "GET"
  URLSession.shared.dataTask(with: request) { (data, response, error) in
    if let data = data {
      if let jsonData = try? JSONDecoder().decode(JsonCountBase.self, from: data) {
        bank = Int(jsonData.count ?? "") ?? 0
      }
    }
  }.resume()
}

func getAssigned() async {
  var request = createAuthRequest(url: base_url + "/api/punishments/assigned")
  request.httpMethod = "GET"
  URLSession.shared.dataTask(with: request) { (data, response, error) in
    if let data = data {
      if let jsonData = try? JSONDecoder().decode(JsonCountBase.self, from: data) {
        assigned = Int(jsonData.count ?? "") ?? 0
      }
    }
  }.resume()
}
