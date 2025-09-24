//
//  MailComposer.swift
//  underneath
//
//  Created by Kevin Du on 9/19/25.
//

#if canImport(MessageUI)
  import Logging
  import MessageUI
  import SwiftUI

  public struct MailComposer: UIViewControllerRepresentable {
    var subject: String
    var recipients: [String]
    var body: String
    var attachments: [(data: Data, mimeType: String, fileName: String)] = []
    var onFinish: ((Result<MFMailComposeResult, Error>) -> Void)?

    public init(
      subject: String,
      recipients: [String],
      body: String,
      attachments: [(data: Data, mimeType: String, fileName: String)],
      onFinish: ((Result<MFMailComposeResult, Error>) -> Void)? = nil
    ) {
      self.subject = subject
      self.recipients = recipients
      self.body = body
      self.attachments = attachments
      self.onFinish = onFinish
    }

    public func makeUIViewController(context: Context) -> MFMailComposeViewController {
      let composer = MFMailComposeViewController()
      composer.mailComposeDelegate = context.coordinator
      composer.setSubject(subject)
      composer.setToRecipients(recipients)
      composer.setMessageBody(body, isHTML: false)

      for attachment in attachments {
        composer.addAttachmentData(
          attachment.data,
          mimeType: attachment.mimeType,
          fileName: attachment.fileName
        )
      }

      return composer
    }

    public func updateUIViewController(_ composer: MFMailComposeViewController, context: Context) {
      for attachment in attachments {
        composer.addAttachmentData(
          attachment.data,
          mimeType: attachment.mimeType,
          fileName: attachment.fileName
        )
      }
    }

    public func makeCoordinator() -> Coordinator {
      Coordinator(onFinish: onFinish)
    }

    public class Coordinator: NSObject, @preconcurrency MFMailComposeViewControllerDelegate {
      var onFinish: ((Result<MFMailComposeResult, Error>) -> Void)?

      init(onFinish: ((Result<MFMailComposeResult, Error>) -> Void)?) {
        self.onFinish = onFinish
      }

      @MainActor public func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
      ) {
        if let error = error {
          onFinish?(.failure(error))
        } else {
          onFinish?(.success(result))
        }
        controller.dismiss(animated: true)
      }
    }
  }

  public struct MailFeedbackComposer<Content: View>: View {
    var subject: String
    var recipients: [String]
    var content: String = ""
    @ViewBuilder let label: () -> Content

    public init(
      subject: String,
      recipients: [String],
      content: String = "",
      label: @escaping () -> Content,
    ) {
      self.subject = subject
      self.recipients = recipients
      self.content = content
      self.label = label
    }

    @State private var showFeedback: Bool = false
    @State private var attachments: [(data: Data, mimeType: String, fileName: String)] = []

    private let logger = Logger(label: "MailFeedback")

    public var body: some View {
      if MFMailComposeViewController.canSendMail() {
        label()
          .fullTap { showFeedback = true }
          .sheet(isPresented: $showFeedback) {
            MailComposer(
              subject: subject,
              recipients: recipients,
              body: OS.getAppInfo() + "\n\n" + content,
              attachments: attachments,
              onFinish: { result in
                switch result {
                case .success(let mailResult):
                  logger.info("Result: \(mailResult.description)")
                case .failure(let error):
                  logger.error("\(error.localizedDescription)")
                }
              }
            )
            .task {
              var attachments: [(data: Data, mimeType: String, fileName: String)] = []
              for log in Logger.getLogs() ?? [] {
                if let data = try? Data(contentsOf: log) {
                  attachments.append((data, "text/plain", log.lastPathComponent + ".log"))
                }
              }
              self.attachments = attachments
            }
          }
      }
    }
  }

  extension MFMailComposeResult {
    fileprivate var description: String {
      switch self {
      case .cancelled: return "Cancelled"
      case .sent: return "Sent"
      case .saved: return "Saved"
      case .failed: return "Failed"
      @unknown default: return "Unknown"
      }
    }
  }

#endif
