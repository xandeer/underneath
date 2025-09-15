//
//  File.swift
//  Underneath
//
//  Created by Kevin Du on 7/17/25.
//

#if canImport(UIKit)
  import SwiftUI

  extension View {
    #if !os(watchOS)
      public func snapshot() -> UIImage? {
        let r = ImageRenderer(content: self)
        r.scale = UIScreen.main.scale
        return r.uiImage
      }
    #endif

    @ViewBuilder
    public func `if`<Content: View>(_ condition: Bool, then: (Self) -> Content, els: ((Self) -> Content)? = nil)
      -> some View
    {
      if condition {
        then(self)
      } else {
        if let els = els {
          els(self)
        } else {
          self
        }
      }
    }
  }
#endif

extension View {
  public func frameSize(_ size: CGFloat) -> some View {
    frame(width: size, height: size)
  }

  public func greedyWidth() -> some View {
    frame(maxWidth: .infinity)
  }

  public func greedyHeight() -> some View {
    frame(maxHeight: .infinity)
  }

  public func greedySize() -> some View {
    greedyWidth().greedyHeight()
  }

  public func largeRounded() -> some View {
    clipShape(RoundedRectangle.large)
  }

  public func fullTap(_ perform: @escaping () -> Void) -> some View {
    contentShape(Rectangle())
      .onTapGesture(perform: perform)
  }
}

extension RoundedRectangle {
  public static let large = RoundedRectangle(cornerRadius: 20)
}
