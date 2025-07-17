//
//  LoggingService.swift
//  underneath
//
//  Created by Kevin Du on 7/15/25.
//

import DeviceKit
import Foundation
import Logging
import Puppy

extension Logger {
  public static func setup(_ label: String = Bundle.main.bundleIdentifier ?? "Underneath") {
    let logFormatter = TimestampLogFormatter()

    // 1. Console logger with timestamp
    let console = ConsoleLogger(label, logLevel: .debug, logFormat: logFormatter)

    // 2. File rotation logger with timestamp
    let fileURL = FileManager.default
      .urls(for: .documentDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("logs/picpin.log")

    let rotationConfig = RotationConfig(
      suffixExtension: .date_uuid,
      maxFileSize: 5 * 1024 * 1024,
      maxArchivedFilesCount: 3
    )

    guard
      let fileLogger = try? FileRotationLogger(
        label,
        logFormat: logFormatter,
        fileURL: fileURL,
        rotationConfig: rotationConfig
      )
    else {
      Logger(label: "Logger").error("Failed to init FileRotationLogger")
      return
    }

    let puppy = Puppy(loggers: [console, fileLogger])

    LoggingSystem.bootstrap { label in
      var handler = PuppyLogHandler(label: label, puppy: puppy)
      #if DEBUG
        handler.logLevel = .debug
      #else
        handler.logLevel = .info
      #endif
      return handler
    }

    recordAppInfo()
  }

  private static func recordAppInfo() {
    // Record device info and app version
    let unknown = "unknown"
    let device = Device.current
    let systemName = device.systemName ?? unknown
    let systemVersion = device.systemVersion ?? unknown
    let model = device.description

    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? unknown
    let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? unknown

    Logger(label: "DeviceInfo").info(
      "model=\(model), system=\(systemName) \(systemVersion), appVersion=\(appVersion) (\(appBuild))"
    )
  }

  @MainActor
  public static func getLogs() -> [URL]? {
    let docs = FileManager.default
      .urls(for: .documentDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("logs")

    let files = (try? FileManager.default.contentsOfDirectory(at: docs, includingPropertiesForKeys: nil)) ?? []

    guard !files.isEmpty else {
      Logger(label: "Log").warning("No log files found to share")
      return nil
    }

    return files
  }
}

// Custom log formatter with timestamps
private struct TimestampLogFormatter: LogFormattable {
  private let dateFormatter: DateFormatter

  init() {
    dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
  }

  func formatMessage(
    _ level: LogLevel,
    message: String,
    tag: String,
    function: String,
    file: String,
    line: UInt,
    swiftLogInfo: [String: String],
    label: String,
    date: Date,
    threadID: UInt64
  ) -> String {
    var swiftLogLabel = swiftLogInfo["label"] ?? ""
    if !swiftLogLabel.isEmpty {
      swiftLogLabel = " \(swiftLogLabel)"
    }

    return "\(dateFormatter.string(from: date)) [\(level)]\(swiftLogLabel): \(message)"
  }
}
