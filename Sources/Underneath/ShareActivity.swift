//
//  ActivityForShare.swift
//  underneath
//
//  Created by Kevin Du on 7/15/25.
//

#if canImport(UIKit) && !os(watchOS)
  import Logging
  import UIKit

  extension URL: @retroactive Identifiable {
    public var id: String { path() }
  }

  public struct ShareActivity {
    @MainActor
    public static func show(for activityItems: [Any], onDisappear: (() -> Void)? = nil) {
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
      if let onDisappear = onDisappear {
        let delegate = ActivityDelegate(onDisappear: onDisappear)
        activityVC.presentationController?.delegate = delegate
        // 需要把 delegate 强引用保存，避免被释放（比如关联到 activityVC）
        objc_setAssociatedObject(activityVC, "activityDelegate", delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      }

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

  class ActivityDelegate: NSObject, UIAdaptivePresentationControllerDelegate {
    let onDisappear: () -> Void

    init(onDisappear: @escaping () -> Void) {
      self.onDisappear = onDisappear
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
      onDisappear()
    }
  }
#endif
