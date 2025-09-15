//
//  SoftKeyboard.swift
//  alpha
//
//  Created by Kevin Du on 5/21/25.
//

import SwiftUI

extension View {
  public func hideKeyboardOnTap<T: Hashable>(focusedField: FocusState<T?>.Binding) -> some View {
    fullTap {
      focusedField.wrappedValue = nil
    }
  }

  public func hideKeyboardOnTap(focusedField: FocusState<Bool>.Binding) -> some View {
    fullTap {
      focusedField.wrappedValue = false
    }
  }
}
