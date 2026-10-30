//
//  DocumentUseCase.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 21/10/2026.
//

import Foundation
import PDFKit
import CryptoKit

final class DocumentUseCase {

    private let appGroupID = "group.com.campusflow.shared"
    private let fileManager = FileManager.default

    enum DocumentError: LocalizedError {
        case invalidPDF
        case unreadableFile
        case sharedContainerUnavailable
        case invalidFileLocation

        var errorDescription: String? {
            switch self {
            case .invalidPDF:
                return "The PDF is invalid, corrupted, locked, or empty."
            case .unreadableFile:
                return "The PDF cannot be accessed."
            case .sharedContainerUnavailable:
                return "CampusFlow shared storage is unavailable."
            case .invalidFileLocation:
                return "The selected PDF is not stored in this assignment."
            }
        }
    }

    func attachmentFolder(for assignmentID: String) -> URL {
        let documents = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]

        return documents
            .appendingPathComponent("AssignmentPDFs", isDirectory: true)
            .appendingPathComponent(assignmentID, isDirectory: true)
    }

    func loadDocuments(for assignmentID: String) throws -> [URL] {
        let folder = attachmentFolder(for: assignmentID)

        guard fileManager.fileExists(atPath: folder.path) else {
            return []
        }
        return try fileManager.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: nil
        )
        .filter { $0.pathExtension.lowercased() == "pdf" }
        .sorted {
            $0.lastPathComponent.localizedStandardCompare(
                $1.lastPathComponent
            ) == .orderedAscending
        }
    }

    private func validatePDF(_ url: URL) throws {
        guard url.pathExtension.lowercased() == "pdf",
              fileManager.isReadableFile(atPath: url.path) else {
            throw DocumentError.unreadableFile
        }
        guard let document = PDFDocument(url: url),
              document.pageCount > 0,
              !document.isLocked else {
            throw DocumentError.invalidPDF
        }
    }

    @discardableResult
    func importPDF(
        from sourceURL: URL,
        assignmentID: String
    ) throws -> URL {
        try validatePDF(sourceURL)
        let folder = attachmentFolder(for: assignmentID)
        try fileManager.createDirectory(
            at: folder,
            withIntermediateDirectories: true
        )

        let baseName = sourceURL.deletingPathExtension().lastPathComponent
        var destination = folder.appendingPathComponent(sourceURL.lastPathComponent)

        var counter = 1

        while fileManager.fileExists(atPath: destination.path) {
            destination = folder.appendingPathComponent("\(baseName) (\(counter)).pdf")
            counter += 1
        }

        try fileManager.copyItem(at: sourceURL, to: destination)

        return destination
    }

    private func sha256(for url: URL) throws -> SHA256.Digest {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }

        var hasher = SHA256()

        while true {
            let data = try handle.read(
                upToCount: 1024 * 1024
            ) ?? Data()

            if data.isEmpty {
                break
            }

            hasher.update(data: data)
        }
        return hasher.finalize()
    }

    private func isAlreadyImported(
        _ sourceURL: URL,
        assignmentID: String
    ) throws -> Bool {
        let existingFiles = try loadDocuments(for: assignmentID)
        let sourceHash = try sha256(for: sourceURL)

        for existingFile in existingFiles {
            if try sha256(for: existingFile) == sourceHash {
                return true
            }
        }

        return false
    }

    func importSharedPDFs(assignmentID: String) throws {
        guard let container = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else {
            throw DocumentError.sharedContainerUnavailable
        }

        let incomingFolder = container
            .appendingPathComponent("IncomingPDFs", isDirectory: true)
            .appendingPathComponent(assignmentID, isDirectory: true)

        guard fileManager.fileExists(atPath: incomingFolder.path) else {
            return
        }

        let incomingFiles = try fileManager.contentsOfDirectory(
            at: incomingFolder,
            includingPropertiesForKeys: nil
        )

        var failures: [String] = []

        for file in incomingFiles where file.pathExtension.lowercased() == "pdf" {
            do {
                try validatePDF(file)

                if try !isAlreadyImported(
                    file,
                    assignmentID: assignmentID
                ) {
                    try importPDF(
                        from: file,
                        assignmentID: assignmentID
                    )
                }

                try fileManager.removeItem(at: file)

            } catch {
                failures.append("\(file.lastPathComponent): \(error.localizedDescription)")
            }
        }

        if !failures.isEmpty {
            throw NSError(
                domain: "CampusFlow.DocumentImport",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Some PDFs could not be imported:\n" +
                        failures.joined(separator: "\n")
                ]
            )
        }
    }

    func deletePDF(_ url: URL, assignmentID: String) throws {
        let folder = attachmentFolder(for: assignmentID)

        guard url.deletingLastPathComponent().standardizedFileURL ==
                folder.standardizedFileURL else {
            throw DocumentError.invalidFileLocation
        }

        try fileManager.removeItem(at: url)
    }
    
    /// Deletes all PDF attachments belonging to the specified item.
    /// If no attachment folder exists, no action is needed.
    func deleteAllPDFs(assignmentID: String) throws {
        let folder = attachmentFolder(for: assignmentID)

        guard fileManager.fileExists(atPath: folder.path) else {
            return
        }

        try fileManager.removeItem(at: folder)
    }
}
