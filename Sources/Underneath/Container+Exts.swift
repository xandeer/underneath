//
//  File.swift
//  Underneath
//
//  Created by Kevin Du on 7/18/25.
//

#if canImport(UIKit) && !os(watchOS)
  import Factory

  extension Container {
    public var shareController: Factory<ShareController> {
      self { ShareController() }.singleton
    }
  }
#endif
