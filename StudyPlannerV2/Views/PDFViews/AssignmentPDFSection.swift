//
//  AssignmentPDFSection.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 20/10/2026.
//

import SwiftUI
import UniformTypeIdentifiers

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

            AssignmentPDFContainerView(attachedPDFs: attachedPDFs)

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
        .alert("PDF Import Failed", isPresented: $showError) {
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

            while FileManager.default.fileExists(atPath: destinationURL.path) {
                destinationURL = attachmentFolder
                    .appendingPathComponent("\(baseName) (\(counter)).\(fileExtension)")
                counter += 1
            }

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
}
