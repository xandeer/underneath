//
//  Array+Exts.swift
//  Underneath
//
//  Created by Kevin Du on 7/18/25.
//

import Foundation

extension Array where Element: AnyObject {
  public mutating func removeFirst(object: Element) {
    if let i = firstIndex(where: { $0 === object }) {
      remove(at: i)
    }
  }
}
