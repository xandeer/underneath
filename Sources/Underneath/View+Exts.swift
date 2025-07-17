//
//  File.swift
//  Underneath
//
//  Created by Kevin Du on 7/17/25.
//

#if canImport(UIKit)
  import SwiftUI

  #if !os(watchOS)
    extension View {
      public func snapshot() -> UIImage? {
        let r = ImageRenderer(content: self)
        r.scale = UIScreen.main.scale
        return r.uiImage
      }
    }
  #endif
#endif
