//
//  OS.swift
//  Underneath
//
//  Created by Kevin Du on 9/16/25.
//

import DeviceKit
import SwiftUI

public enum OS {
  public static let rather26 =
    if #available(iOS 26, watchOS 26, macOS 26, tvOS 26, *) {
      true
    } else {
      false
    }

  @available(iOS 16.0, *)
  @MainActor
  public static func openAppSettings() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else {
      return
    }
    if UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }

  public static func getAppInfo() -> String {
    // Record device info and app version
    let unknown = "unknown"
    let device = Device.current
    let systemName = device.systemName ?? unknown
    let systemVersion = device.systemVersion ?? unknown
    let model = device.description

    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? unknown
    let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? unknown

    return "model=\(model), system=\(systemName) \(systemVersion), appVersion=\(appVersion) (\(appBuild))"
  }
}
