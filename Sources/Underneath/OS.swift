//
//  OS.swift
//  Underneath
//
//  Created by Kevin Du on 9/16/25.
//

import Foundation

public enum OS {
  public static let rather26 =
    if #available(iOS 26, *) {
      true
    } else {
      false
    }
}
