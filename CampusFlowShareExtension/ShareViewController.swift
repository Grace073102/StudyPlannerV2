//
//  ShareViewController.swift
//  CampusFlowShareExtension
//
//  Created by Grace Chi Yen Chong on 20/10/2026.
//


import UIKit
import Social
import UniformTypeIdentifiers
import PDFKit

class ShareViewController: SLComposeServiceViewController {

    private let appGroupID = "group.com.campusflow.shared"

    private enum ShareError: LocalizedError {
        case noPDF
        case invalidPDF
        case sharedContainerUnavailable

        var errorDescription: String? {
            switch self {
            case .noPDF:
                return "No PDF attachment was found. Please share a PDF file."

            case .invalidPDF:
                return "This PDF is invalid, corrupted, or cannot be opened."

            case .sharedContainerUnavailable:
                return "CampusFlow shared storage is unavailable. Please check the App Group configuration."
            }
        }
    }

    override func isContentValid() -> Bool {
        return extensionContext?.inputItems
            .compactMap { $0 as? NSExtensionItem }
            .flatMap { $0.attachments ?? [] }
            .contains {
                $0.hasItemConformingToTypeIdentifier(
                    UTType.pdf.identifier
                )
            } ?? false
    }

    override func didSelectPost() {
        guard let attachments = extensionContext?.inputItems
            .compactMap({ $0 as? NSExtensionItem })
            .flatMap({ $0.attachments ?? [] }),
              let provider = attachments.first(where: {
                  $0.hasItemConformingToTypeIdentifier(
                      UTType.pdf.identifier
                  )
              }) else {
            showError(ShareError.noPDF)
            return
        }

        provider.loadFileRepresentation(
            forTypeIdentifier: UTType.pdf.identifier
        ) { [weak self] sourceURL, error in

            guard let self else { return }

            if let error {
                DispatchQueue.main.async {
                    self.showError(error)
                }
                return
            }

            guard let sourceURL else {
                DispatchQueue.main.async {
                    self.showError(ShareError.noPDF)
                }
                return
            }

            do {
                try self.saveSharedPDF(
                    from: sourceURL,
                    originalName: provider.suggestedName
                )

                DispatchQueue.main.async {
                    self.extensionContext?.completeRequest(
                        returningItems: [],
                        completionHandler: nil
                    )
                }
            } catch {
                DispatchQueue.main.async {
                    self.showError(error)
                }
            }
        }
    }

    private func saveSharedPDF(
        from sourceURL: URL,
        originalName: String?
    ) throws {

        guard let document = PDFDocument(url: sourceURL),
              document.pageCount > 0,
              !document.isLocked else {
            throw ShareError.invalidPDF
        }

        guard let containerURL = FileManager.default
            .containerURL(
                forSecurityApplicationGroupIdentifier: appGroupID
            ) else {
            throw ShareError.sharedContainerUnavailable
        }

        let inboxFolder = containerURL
            .appendingPathComponent(
                "IncomingPDFs",
                isDirectory: true
            )

        try FileManager.default.createDirectory(
            at: inboxFolder,
            withIntermediateDirectories: true
        )

        let proposedName = originalName ?? sourceURL.lastPathComponent

        let baseName = URL(fileURLWithPath: proposedName)
            .deletingPathExtension()
            .lastPathComponent

        let safeName = baseName.isEmpty ? "Shared Document" : baseName

        var destinationURL = inboxFolder
            .appendingPathComponent("\(safeName).pdf")

        var counter = 1

        while FileManager.default.fileExists(
            atPath: destinationURL.path
        ) {
            destinationURL = inboxFolder
                .appendingPathComponent(
                    "\(safeName) (\(counter)).pdf"
                )
            counter += 1
        }

        try FileManager.default.copyItem(
            at: sourceURL,
            to: destinationURL
        )
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Unable to Share PDF",
            message: error.localizedDescription,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default
            ) { [weak self] _ in
                self?.extensionContext?.cancelRequest(
                    withError: error
                )
            }
        )

        present(alert, animated: true)
    }

    override func configurationItems() -> [Any]! {
        return []
    }
}
