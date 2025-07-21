//
//  Haptic.swift
//
//  Created by Kevin Du on 6/20/25.
//

#if os(iOS)
  import SwiftUI

  @MainActor
  public class Haptic {
    private let hapticInterval: CGFloat
    private let haptic: UIImpactFeedbackGenerator

    private var lastHapticValue: CGFloat = 0

    public init(hapticInterval: CGFloat, style: UIImpactFeedbackGenerator.FeedbackStyle) {
      self.hapticInterval = hapticInterval
      self.haptic = UIImpactFeedbackGenerator(style: style)
      haptic.prepare()
    }

    public func triggerHapticIfNeeded(_ newValue: CGFloat, _ interval: CGFloat? = nil) {
      if abs(lastHapticValue - newValue) > interval ?? hapticInterval {
        haptic.impactOccurred()
        lastHapticValue = newValue
      }
    }

    public func impactOccurred() {
      haptic.impactOccurred()
    }
  }
#endif
