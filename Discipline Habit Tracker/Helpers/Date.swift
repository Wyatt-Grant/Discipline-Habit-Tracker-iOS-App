//
//  Date.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-27.
//

import SwiftUI

func getCurrentDayOfMonth(timeZone: String) -> Int {
  var calendar = Calendar(identifier: .gregorian)
  calendar.timeZone = TimeZone(identifier: timeZone) ?? TimeZone.current

  let currentDate = Date()
  let modifiedDate = calendar.date(byAdding: .day, value: 0, to: currentDate) ?? Date()

  let dayOfMonth = calendar.component(.day, from: modifiedDate)
  return dayOfMonth
}

func getCurrentYear() -> Int {
  let calendar = Calendar.current
  let currentDate = Date()
  let year = calendar.component(.year, from: currentDate)
  return year
}

func getCurrentMonth() -> Int {
  let calendar = Calendar.current
  let currentDate = Date()
  let month = calendar.component(.month, from: currentDate)
  return month
}

func getCurrentDay() -> Int {
  let calendar = Calendar.current
  let currentDate = Date()
  let day = calendar.component(.day, from: currentDate)
  return day
}

func getFormattedCurrentDayOfMonth(_ days: Int) -> String {
  let calendar = Calendar.current
  let currentDate = Date()
  let modifiedDate = calendar.date(byAdding: .day, value: days, to: currentDate)!

  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "YYYY-MM-dd"

  return dateFormatter.string(from: modifiedDate)
}
