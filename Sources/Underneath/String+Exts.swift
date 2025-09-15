//
//  File.swift
//  Underneath
//
//  Created by Kevin Du on 9/15/25.
//

import SwiftUI

extension String {
  public var justified: AttributedString {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .justified

    let attr = NSAttributedString(
      string: self,
      attributes: [.paragraphStyle: paragraph]
    )
    return AttributedString(attr)
  }
}
