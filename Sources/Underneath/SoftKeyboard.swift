//
//  SoftKeyboard.swift
//  alpha
//
//  Created by Kevin Du on 5/21/25.
//

import SwiftUI

public struct HideKeyboardOnTapModifier<FocusValue: Hashable>: ViewModifier {
  private var focusedField: FocusState<FocusValue?>.Binding

  public init(focusedField: FocusState<FocusValue?>.Binding) {
    self.focusedField = focusedField
  }

  public func body(content: Content) -> some View {
    content.fullTap {
      focusedField.wrappedValue = nil
    }
  }
}

extension View {
  public func hideKeyboardOnTap<T: Hashable>(focusedField: FocusState<T?>.Binding) -> some View {
    modifier(HideKeyboardOnTapModifier(focusedField: focusedField))
  }
}
