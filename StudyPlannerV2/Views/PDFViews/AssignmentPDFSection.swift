//
//  AssignmentPDFSection.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 20/10/2026.
//


import SwiftUI
import UniformTypeIdentifiers
import PDFKit

struct AssignmentPDFSection: View {

    let assignmentID: String

    @Environment(\.scenePhase) private var scenePhase

    @State private var showPDFPicker = false
    @State private var attachedPDFs: [URL] = []
    @State private var errorMessage = ""
    @State private var showError = false

    private let appGroupID = "group.com.campusflow.shared"

    private var attachmentFolder: URL {
        let documents = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]

        return documents
            .appendingPathComponent(
                "AssignmentPDFs",
                isDirectory: true
            )
            .appendingPathComponent(
                assignmentID,
                isDirectory: true
            )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("PDF Attachments")
                .font(.headline)

            Text("Attach PDFs related to this assignment.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            AssignmentPDFContainerView(attachedPDFs: attachedPDFs, onDelete: deletePDF)

            Button {
                showPDFPicker = true
            } label: {
                Label(
                    "Attach PDF",
                    systemImage: "plus.circle.fill"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(Theme.card))
        )
        .fileImporter(
            isPresented: $showPDFPicker,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in

            switch result {
            case .success(let urls):
                if let url = urls.first {
                    importPDF(from: url)
                }

            case .failure(let error):
                showImportError(error)
            }
        }
        .alert(
            "PDF Operation Failed",
            isPresented: $showError
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            refreshPDFs()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                refreshPDFs()
            }
        }
    }

    private func refreshPDFs() {
        importSharedPDFs()
        loadPDFs()
    }

    private func importPDF(from sourceURL: URL) {

        let hasAccess = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if hasAccess {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }
        do {
            try copyPDFToAssignment(from: sourceURL)
            loadPDFs()
        } catch {
            showImportError(error)
        }
    }

    private func importSharedPDFs() {

        let fileManager = FileManager.default

        guard let sharedContainer = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else {
            showImportError(PDFImportError.sharedContainerUnavailable)
            return
        }

        let incomingFolder = sharedContainer
            .appendingPathComponent(
                "IncomingPDFs",
                isDirectory: true
            )
            .appendingPathComponent(
                assignmentID,
                isDirectory: true
            )

        guard fileManager.fileExists(
            atPath: incomingFolder.path
        ) else {
            return
        }

        do {
            let incomingFiles = try fileManager.contentsOfDirectory(
                at: incomingFolder,
                includingPropertiesForKeys: nil
            )

            var failedImports: [String] = []

            for fileURL in incomingFiles {
                guard fileURL.pathExtension.lowercased() == "pdf" else {
                    continue
                }
                do {
                    // Copy into the assignment folder first.
                    try copyPDFToAssignment(from: fileURL)

                    // Delete the queued copy only after success.
                    try fileManager.removeItem(at: fileURL)

                } catch {
                    failedImports.append(
                        "\(fileURL.lastPathComponent): \(error.localizedDescription)"
                    )
                }
            }
            if !failedImports.isEmpty {
                throw PDFImportError.sharedImportFailed(
                    failedImports.joined(separator: "\n")
                )
            }

        } catch {
            showImportError(error)
        }
    }

    private func copyPDFToAssignment(
        from sourceURL: URL
    ) throws {

        let fileManager = FileManager.default

        guard sourceURL.pathExtension.lowercased() == "pdf" else {
            throw PDFImportError.invalidFileType
        }

        guard fileManager.isReadableFile(
            atPath: sourceURL.path
        ) else {
            throw PDFImportError.fileNotReadable
        }

        guard let document = PDFDocument(url: sourceURL),
              document.pageCount > 0,
              !document.isLocked else {
            throw PDFImportError.invalidPDF
        }

        try fileManager.createDirectory(
            at: attachmentFolder,
            withIntermediateDirectories: true
        )

        let originalName = sourceURL.lastPathComponent

        let baseName = sourceURL
            .deletingPathExtension()
            .lastPathComponent

        var destinationURL = attachmentFolder
            .appendingPathComponent(originalName)

        var counter = 1

        while fileManager.fileExists(
            atPath: destinationURL.path
        ) {
            destinationURL = attachmentFolder
                .appendingPathComponent(
                    "\(baseName) (\(counter)).pdf"
                )
            counter += 1
        }
        try fileManager.copyItem(
            at: sourceURL,
            to: destinationURL
        )
    }

    private func loadPDFs() {

        let fileManager = FileManager.default

        guard fileManager.fileExists(
            atPath: attachmentFolder.path
        ) else {
            attachedPDFs = []
            return
        }
        do {
            attachedPDFs = try fileManager.contentsOfDirectory(
                at: attachmentFolder,
                includingPropertiesForKeys: nil
            )
            .filter {
                $0.pathExtension.lowercased() == "pdf"
            }
            .sorted {
                $0.lastPathComponent.localizedStandardCompare(
                    $1.lastPathComponent
                ) == .orderedAscending
            }
        } catch {
            showImportError(error)
        }
    }


    private func deletePDF(_ pdf: URL) {
        do {
            guard pdf.deletingLastPathComponent()
                    .standardizedFileURL ==
                    attachmentFolder.standardizedFileURL else {
                throw CocoaError(.fileReadNoPermission)
            }
            try FileManager.default.removeItem(at: pdf)
            loadPDFs()
        } catch {
            showImportError(error)
        }
    }

    private func showImportError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }

    private enum PDFImportError: LocalizedError {

        case invalidFileType
        case fileNotReadable
        case invalidPDF
        case sharedContainerUnavailable
        case sharedImportFailed(String)

        var errorDescription: String? {
            switch self {

            case .invalidFileType:
                return "Only PDF files can be attached."

            case .fileNotReadable:
                return "This PDF cannot be accessed. Please check its permissions."

            case .invalidPDF:
                return "This PDF is corrupted, locked, or contains no readable pages."

            case .sharedContainerUnavailable:
                return "CampusFlow shared storage is unavailable. Please check the App Group configuration."

            case .sharedImportFailed(let details):
                return "Some shared PDFs could not be imported:\n\(details)"
            }
        }
    }
}
