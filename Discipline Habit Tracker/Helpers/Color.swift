//
//  Color.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-28.
//

import SwiftUI

class ColorData {
  private var COLOR_KEY = "COLOR_KEY"
  private let userDefaults = UserDefaults.standard

  func saveColor(color: Color) {
    let color = UIColor(color).cgColor

    if let components = color.components {
      userDefaults.set(components, forKey: COLOR_KEY)
    }
  }

  func loadColor() -> Color {
    guard let array = userDefaults.object(forKey: COLOR_KEY) as? [CGFloat] else { return Color.red }

    let color = Color(
      .sRGB,
      red: array[0],
      green: array[1],
      blue: array[2],
      opacity: array[3])
    return color
  }
}

extension Color {
  var toHex: String? {
    let uiColor = UIColor(self)
    return uiColor.toHex
  }

  init(hex: String) {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)
    let r: UInt64
    let g: UInt64
    let b: UInt64
    switch hex.count {
    case 3:  // RGB (12-bit)
      (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6:  // RGB (24-bit)
      (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
    default:
      (r, g, b) = (1, 1, 0)
    }
    self.init(
      .sRGB,
      red: Double(r) / 255.0,
      green: Double(g) / 255.0,
      blue: Double(b) / 255.0,
      opacity: Double(1)
    )
  }
}

extension UIColor {
  var toHex: String? {
    guard let components = cgColor.components, components.count >= 3 else {
      return nil
    }

    let r = Float(components[0])
    let g = Float(components[1])
    let b = Float(components[2])

    let hexString = String(
      format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))

    return hexString
  }
}
