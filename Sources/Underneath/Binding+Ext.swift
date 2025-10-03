//
//  Binding+Ext.swift
//  alpha
//
//  Created by Kevin Du on 5/21/25.
//

import SwiftUI

extension Binding {
  /// Returns a binding that updates its value with animation.
  ///
  /// - Returns: A `Binding<Value>` that animates changes to `wrappedValue` using
  ///   the current animation context.
  @MainActor
  public func animated() -> Binding<Value> {
    Binding(
      get: { wrappedValue },
      set: { v in
        withAnimation { wrappedValue = v }
      }
    )
  }

  /// Converts a `Binding<T?>` to `Binding<T>` by providing a default fallback value.
  @MainActor
  public func unwrap<T>(_ defaultValue: T, _ animated: Bool = true) -> Binding<T> where Value == T? {
    Binding<T>(
      get: { wrappedValue ?? defaultValue },
      set: { v in
        if animated {
          withAnimation { wrappedValue = v }
        } else {
          wrappedValue = v
        }
      }
    )
  }
}
