//
//  OS.swift
//  Underneath
//
//  Created by Kevin Du on 9/16/25.
//

import SwiftUI

public enum OS {
  public static let rather26 =
    if #available(iOS 26, *) {
      true
    } else {
      false
    }

  @MainActor
  public static func openAppSettings() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else {
      return
    }
    if UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }
}
