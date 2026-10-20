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

    @State private var showPDFPicker = false
    @State private var attachedPDFs: [URL] = []
    @State private var errorMessage = ""
    @State private var showError = false

    private var attachmentFolder: URL {
        let documents = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]

        return documents
            .appendingPathComponent("AssignmentPDFs", isDirectory: true)
            .appendingPathComponent(assignmentID, isDirectory: true)
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
                Label("Attach PDF", systemImage: "plus.circle.fill")
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
        .alert("PDF Operation Failed", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            loadPDFs()
        }
    }

    
    private func importPDF(from sourceURL: URL) {
        let hasAccess = sourceURL.startAccessingSecurityScopedResource()

        defer {
            if hasAccess {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }

        do {
            // Check file extension
            guard sourceURL.pathExtension.lowercased() == "pdf" else {
                throw PDFImportError.invalidFileType
            }

            // Check that the file is readable
            guard FileManager.default.isReadableFile(atPath: sourceURL.path) else {
                throw PDFImportError.fileNotReadable
            }

            // Validate the PDF contents
            guard let document = PDFDocument(url: sourceURL),
                  document.pageCount > 0 else {
                throw PDFImportError.invalidPDF
            }

            let fileManager = FileManager.default

            try fileManager.createDirectory(
                at: attachmentFolder,
                withIntermediateDirectories: true
            )

            let originalName = sourceURL.lastPathComponent
            let fileExtension = sourceURL.pathExtension
            let baseName = sourceURL.deletingPathExtension().lastPathComponent

            var destinationURL = attachmentFolder
                .appendingPathComponent(originalName)

            var counter = 1

            while fileManager.fileExists(atPath: destinationURL.path) {
                destinationURL = attachmentFolder
                    .appendingPathComponent(
                        "\(baseName) (\(counter)).\(fileExtension)"
                    )
                counter += 1
            }

            // Copy to the assignment's local folder
            try fileManager.copyItem(
                at: sourceURL,
                to: destinationURL
            )

            loadPDFs()

        } catch {
            showImportError(error)
        }
    }


    private func loadPDFs() {
        do {
            attachedPDFs = try FileManager.default.contentsOfDirectory(
                at: attachmentFolder,
                includingPropertiesForKeys: nil
            )
            .filter { $0.pathExtension.lowercased() == "pdf" }
            .sorted {
                $0.lastPathComponent < $1.lastPathComponent
            }
        } catch {
            if (error as NSError).code == NSFileReadNoSuchFileError {
                attachedPDFs = []
            } else {
                showImportError(error)
            }
        }
    }

    private func showImportError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
    
    private func deletePDF(_ pdf: URL) {
        do {
            guard pdf.deletingLastPathComponent() == attachmentFolder else {
                throw CocoaError(.fileReadNoPermission)
            }

            try FileManager.default.removeItem(at: pdf)
            loadPDFs()
        } catch {
            showImportError(error)
        }
    }
    
    private enum PDFImportError: LocalizedError {
        case invalidFileType
        case fileNotReadable
        case invalidPDF

        var errorDescription: String? {
            switch self {
            case .invalidFileType:
                return "Only PDF files can be attached to an assignment."

            case .fileNotReadable:
                return "This file cannot be accessed. Please check its permissions and try again."

            case .invalidPDF:
                return "This PDF is invalid, corrupted, or contains no readable pages. Please select another PDF."
            }
        }
    }

}
