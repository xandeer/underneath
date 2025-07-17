//
//  ActivityForShare.swift
//  underneath
//
//  Created by Kevin Du on 7/15/25.
//

#if canImport(UIKit)
  import Logging
  import UIKit

  extension URL: @retroactive Identifiable {
    public var id: String { path() }
  }

  public struct ShareActivity {
    @MainActor
    public static func show(for activityItems: [Any]) {
      // Get root view controller
      guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
        let window = windowScene.windows.first,
        let rootViewController = window.rootViewController
      else {
        Logger(label: "ShareActivity").warning("Unable to find root view controller")
        return
      }

      // Create activity view controller with activityItems
      let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

      // Configure for iPad
      if let popover = activityVC.popoverPresentationController {
        popover.sourceView = rootViewController.view
        popover.sourceRect = CGRect(
          x: rootViewController.view.bounds.midX,
          y: rootViewController.view.bounds.midY,
          width: 0,
          height: 0
        )
        popover.permittedArrowDirections = []
      }

      rootViewController.present(activityVC, animated: true)
    }
  }
#endif
