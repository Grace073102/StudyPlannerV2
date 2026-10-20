//
//  ShareViewController.swift
//  CampusFlowShareExtension
//
//  Created by Grace Chi Yen Chong on 20/10/2026.
//

import UIKit
import SwiftUI
import UniformTypeIdentifiers
import PDFKit

final class ShareViewController: UIViewController {

    private let appGroupID = "group.com.campusflow.shared"

    private var pdfProvider: NSItemProvider?
    private var pdfName = "Shared Document.pdf"
    private var assignments: [SharedAssignment] = []

    private var hostingController: UIHostingController<ShareAssignmentPickerView>?

    private enum ShareError: LocalizedError {
        case noPDF
        case invalidPDF
        case sharedContainerUnavailable
        case assignmentNotFound
        case transferFailed

        var errorDescription: String? {
            switch self {
            case .noPDF:
                return "No PDF was found. Please share a PDF document."

            case .invalidPDF:
                return "This PDF is invalid, corrupted, or password-protected."

            case .sharedContainerUnavailable:
                return "CampusFlow shared storage is unavailable."

            case .assignmentNotFound:
                return "The selected assignment is no longer available."

            case .transferFailed:
                return "The PDF could not be transferred. Please try again."
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        do {
            assignments = try SharedAssignmentStore.load()

            guard let provider = findPDFProvider() else {
                showError(ShareError.noPDF)
                return
            }

            pdfProvider = provider

            if let suggestedName = provider.suggestedName,
               !suggestedName.isEmpty {
                pdfName = suggestedName.lowercased().hasSuffix(".pdf")
                    ? suggestedName
                    : suggestedName + ".pdf"
            }

            showAssignmentPicker()

        } catch {
            showError(error)
        }
    }

    private func findPDFProvider() -> NSItemProvider? {
        let items = extensionContext?.inputItems
            .compactMap { $0 as? NSExtensionItem } ?? []

        return items
            .flatMap { $0.attachments ?? [] }
            .first {
                $0.hasItemConformingToTypeIdentifier(
                    UTType.pdf.identifier
                )
            }
    }

    private func showAssignmentPicker() {
        let picker = ShareAssignmentPickerView(
            pdfName: pdfName,
            assignments: assignments,
            onImport: { [weak self] assignment in
                self?.importPDF(to: assignment)
            },
            onCancel: { [weak self] in
                self?.cancelSharing()
            }
        )

        let hosting = UIHostingController(rootView: picker)
        hostingController = hosting

        addChild(hosting)

        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hosting.view)

        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        hosting.didMove(toParent: self)
    }

    private func importPDF(to assignment: SharedAssignment) {
        guard assignments.contains(where: { $0.id == assignment.id }) else {
            showError(ShareError.assignmentNotFound)
            return
        }

        guard let provider = pdfProvider else {
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
                    self.showError(ShareError.transferFailed)
                }
                return
            }

            do {
                try self.savePDF(
                    from: sourceURL,
                    to: assignment
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

    private func savePDF(
        from sourceURL: URL,
        to assignment: SharedAssignment
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
            .appendingPathComponent("IncomingPDFs", isDirectory: true)
            .appendingPathComponent(assignment.id, isDirectory: true)

        try FileManager.default.createDirectory(
            at: inboxFolder,
            withIntermediateDirectories: true
        )

        let originalName = pdfName
        let baseName = URL(fileURLWithPath: originalName)
            .deletingPathExtension()
            .lastPathComponent

        let safeName = baseName.isEmpty ? "Shared Document" : baseName

        var destinationURL = inboxFolder
            .appendingPathComponent("\(safeName).pdf")

        var counter = 1

        while FileManager.default.fileExists(atPath: destinationURL.path) {
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

    private func cancelSharing() {
        extensionContext?.cancelRequest(
            withError: NSError(
                domain: NSCocoaErrorDomain,
                code: NSUserCancelledError
            )
        )
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Unable to Import PDF",
            message: error.localizedDescription,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "OK", style: .default)
        )

        present(alert, animated: true)
    }
}
