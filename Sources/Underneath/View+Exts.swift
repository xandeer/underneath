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
    public func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
      if condition {
        transform(self)
      } else {
        self
      }
    }
  }
#endif
