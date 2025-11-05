//
//  AppEnumStorage.swift
//  Underneath
//
//  Created by Kevin Du on 11/5/25.
//

import SwiftUI

@propertyWrapper
public struct AppEnumStorage<Value: RawRepresentable>: DynamicProperty {
  private let key: String
  private let defaultValue: Value
  @AppStorage private var rawValue: Value.RawValue

  public init(
    _ key: String,
    default defaultValue: Value,
    store: UserDefaults? = nil
  ) where Value.RawValue == String {
    self.key = key
    self.defaultValue = defaultValue
    if let store {
      self._rawValue = AppStorage(wrappedValue: defaultValue.rawValue, key, store: store)
    } else {
      self._rawValue = AppStorage(wrappedValue: defaultValue.rawValue, key)
    }
  }

  public init(
    _ key: String,
    default defaultValue: Value,
    store: UserDefaults? = nil
  ) where Value.RawValue == Int {
    self.key = key
    self.defaultValue = defaultValue
    if let store {
      self._rawValue = AppStorage(wrappedValue: defaultValue.rawValue, key, store: store)
    } else {
      self._rawValue = AppStorage(wrappedValue: defaultValue.rawValue, key)
    }
  }

  public var wrappedValue: Value {
    get { Value(rawValue: rawValue) ?? defaultValue }
    nonmutating set { rawValue = newValue.rawValue }
  }

  public var projectedValue: Binding<Value> {
    Binding(
      get: { Value(rawValue: rawValue) ?? defaultValue },
      set: { rawValue = $0.rawValue }
    )
  }
}
