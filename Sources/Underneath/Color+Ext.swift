//
//  Color+Ext.swift
//  alpha
//
//  Created by Kevin Du on 6/11/25.
//

import SwiftUI

extension Color {
  public init(hex: UInt, alpha: Double = 1.0) {
    self.init(
      .sRGB,
      red: Double((hex >> 16) & 0xFF) / 255,
      green: Double((hex >> 8) & 0xFF) / 255,
      blue: Double(hex & 0xFF) / 255,
      opacity: alpha
    )
  }

  public static let softCream = Color(hex: 0xF4EEE6)
}

public struct CodableColor: Codable, Equatable, Hashable, Sendable {
  public var red: Double
  public var green: Double
  public var blue: Double
  public var alpha: Double

  public init(_ color: Color = .white) {
    // Extract RGB components from SwiftUI Color
    let uiColor = UIColor(color)
    var redComponent: CGFloat = 0
    var greenComponent: CGFloat = 0
    var blueComponent: CGFloat = 0
    var alphaComponent: CGFloat = 0
    uiColor.getRed(&redComponent, green: &greenComponent, blue: &blueComponent, alpha: &alphaComponent)

    self.red = Double(redComponent)
    self.green = Double(greenComponent)
    self.blue = Double(blueComponent)
    self.alpha = Double(alphaComponent)
  }

  public var color: Color {
    Color(red: red, green: green, blue: blue, opacity: alpha)
  }
}
