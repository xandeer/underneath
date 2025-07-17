//
//  ActivityForShare.swift
//  underneath
//
//  Created by Kevin Du on 7/15/25.
//

#if canImport(UIKit) && !os(watchOS)
  import Logging
  import UIKit
  import SwiftUI

  @Observable
  public class ShareController {
    public var isPresented: Bool = false
    public var activityItems: [Any] = []

    public init(isPresented: Bool = false, activityItems: [Any] = []) {
      self.isPresented = isPresented
      self.activityItems = activityItems
    }

    @MainActor
    public func share(items: [Any]) {
      self.activityItems = items
      self.isPresented = true
    }

    @MainActor
    public func share(_ item: Any) {
      share(items: [item])
    }
  }

  extension URL: @retroactive Identifiable {
    public var id: String { path() }
  }

  public struct ActivityView: UIViewControllerRepresentable {
    public let activityItems: [Any]
    public var applicationActivities: [UIActivity]? = nil

    public init(activityItems: [Any], applicationActivities: [UIActivity]? = nil) {
      self.activityItems = activityItems
      self.applicationActivities = applicationActivities
    }

    public func makeUIViewController(context: Context) -> UIActivityViewController {
      UIActivityViewController(
        activityItems: activityItems,
        applicationActivities: applicationActivities
      )
    }

    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
  }
#endif
