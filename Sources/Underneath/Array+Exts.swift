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

extension Array {
  public mutating func moveOneStep(from index: Index, direction: Int) -> Bool {
    let newIndex = index + direction
    guard indices.contains(index),
      indices.contains(newIndex),
      direction == 1 || direction == -1
    else { return false }
    swapAt(index, newIndex)
    return true
  }
}

extension Array where Element: Equatable {
  public mutating func moveOneStep(of element: Element, forward: Bool) -> Bool {
    if let idx = firstIndex(of: element) {
      return moveOneStep(from: idx, direction: forward ? 1 : -1)
    } else {
      return false
    }
  }
}
