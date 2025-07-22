//
//  ModelContext+Ext.swift
//  underneath
//
//  Created by Kevin Du on 5/26/25.
//

import Foundation
import SwiftData

extension ModelContext {
  public func persistentModel<T>(withID objectID: PersistentIdentifier) throws -> T?
  where T: PersistentModel {
    if let registered: T = registeredModel(for: objectID) {
      return registered
    }
    if let notRegistered: T = model(for: objectID) as? T {
      return notRegistered
    }

    var fetchDescriptor = FetchDescriptor<T>(
      predicate: #Predicate { $0.persistentModelID == objectID }
    )

    fetchDescriptor.fetchLimit = 1

    return (try? fetch(fetchDescriptor))?.first
  }
}

public struct Model<T: PersistentModel>: Sendable, Codable, Equatable, Hashable {
  public let persistentIdentifier: PersistentIdentifier

  public init(persistentIdentifier: PersistentIdentifier) {
    self.persistentIdentifier = persistentIdentifier
  }
}

extension Model {
  public init(_ model: T) {
    self.init(persistentIdentifier: model.persistentModelID)
  }
}

extension ModelContext {
  public func getOptional<T>(_ model: Model<T>) throws -> T?
  where T: PersistentModel {
    try? self.persistentModel(withID: model.persistentIdentifier)
  }
}
