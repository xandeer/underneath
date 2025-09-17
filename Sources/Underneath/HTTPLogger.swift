@preconcurrency import Dispatch
import Foundation
import Puppy

public struct HTTPLogger: Loggerable, Sendable {
  public let label: String
  public let queue: DispatchQueue
  public let logLevel: LogLevel
  public let logFormat: LogFormattable?

  private let endpoint: URL
  private let timeout: TimeInterval
  private let session: URLSession

  public init(
    _ label: String,
    endpoint: URL,
    logLevel: LogLevel = .info,
    timeout: TimeInterval = 10.0,
    logFormat: LogFormattable? = nil
  ) {
    self.label = label
    self.queue = DispatchQueue(label: "\(label).httplogger")
    self.logLevel = logLevel
    self.logFormat = logFormat
    self.endpoint = endpoint
    self.timeout = timeout

    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = timeout
    config.timeoutIntervalForResource = timeout
    self.session = URLSession(configuration: config)
  }

  public func log(_ level: LogLevel, string: String) {
    queue.async {
      let logEntry = [
        "content": string
      ]

      Task {
        await self.sendLog(logEntry)
      }
    }
  }

  private func sendLog(_ logEntry: [String: String]) async {
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: logEntry)

      var request = URLRequest(url: endpoint)
      request.httpMethod = "POST"
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.httpBody = jsonData

      let (_, response) = try await session.data(for: request)

      if let httpResponse = response as? HTTPURLResponse,
        !(200...299).contains(httpResponse.statusCode)
      {
        print("HTTPLogger: Failed to send log, status code: \(httpResponse.statusCode)")
      }
    } catch {
      print("HTTPLogger: Error sending log - \(error)")
    }
  }
}
