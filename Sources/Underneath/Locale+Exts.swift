//
//  Locale+Exts.swift
//  Underneath
//
//  Created by Kevin Du on 10/14/25.
//

import Foundation

extension Locale {
  static func isSimplifiedChinese(_ locale: Locale = .current) -> Bool {
    if locale.identifier.contains("zh_Hans") || locale.identifier.contains("zh-Hans") {
      return true
    }
    // Fallback 到 app 的本地化语言
    let appLanguage = Bundle.main.preferredLocalizations.first ?? "en"
    return appLanguage.hasPrefix("zh-Hans")
  }
}
