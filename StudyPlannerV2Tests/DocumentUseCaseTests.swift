//
//  DocumentUseCaseTests.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 22/10/2026.
//

import Foundation
import Testing
import PDFKit
import UIKit
@testable import StudyPlannerV2

@MainActor
struct DocumentUseCaseTests {

    private let useCase = DocumentUseCase()
    private let fileManager = FileManager.default

    private func makeAssignmentID() -> String {
        "document-test-\(UUID().uuidString)"
    }

    private func makeTemporaryFolder() throws -> URL {
        let folder = fileManager.temporaryDirectory
            .appendingPathComponent(
                "CampusFlowPDFTests-\(UUID().uuidString)",
                isDirectory: true
            )

        try fileManager.createDirectory(
            at: folder,
            withIntermediateDirectories: true
        )

        return folder
    }

    private func makePDF(
        in folder: URL,
        filename: String = "test.pdf"
    ) throws -> URL {

        let url = folder.appendingPathComponent(filename)

        let renderer = UIGraphicsPDFRenderer(
            bounds: CGRect(x: 0, y: 0, width: 595, height: 842)
        )

        try renderer.writePDF(to: url) { context in
            context.beginPage()

            ("CampusFlow Test PDF" as NSString).draw(
                at: CGPoint(x: 40, y: 40),
                withAttributes: [
                    .font: UIFont.systemFont(ofSize: 18)
                ]
            )
        }

        return url
    }

    private func cleanup(
        assignmentIDs: [String],
        temporaryFolder: URL
    ) {
        for assignmentID in assignmentIDs {
            let folder = useCase.attachmentFolder(for: assignmentID)
            try? fileManager.removeItem(at: folder)
        }

        try? fileManager.removeItem(at: temporaryFolder)
    }

    @Test
    func importValidPDF() throws {
        let assignmentID = makeAssignmentID()
        let folder = try makeTemporaryFolder()

        defer {
            cleanup(
                assignmentIDs: [assignmentID],
                temporaryFolder: folder
            )
        }

        let source = try makePDF(
            in: folder,
            filename: "assignment.pdf"
        )

        let imported = try useCase.importPDF(
            from: source,
            assignmentID: assignmentID
        )

        #expect(fileManager.fileExists(atPath: imported.path))
        #expect(PDFDocument(url: imported)?.pageCount == 1)
    }

    @Test
    func emptyPDFIsRejected() throws {
        let assignmentID = makeAssignmentID()
        let folder = try makeTemporaryFolder()

        defer {
            cleanup(
                assignmentIDs: [assignmentID],
                temporaryFolder: folder
            )
        }

        let emptyPDF = folder.appendingPathComponent("empty.pdf")
        try Data().write(to: emptyPDF)

        #expect(throws: DocumentUseCase.DocumentError.invalidPDF) {
            try useCase.importPDF(
                from: emptyPDF,
                assignmentID: assignmentID
            )
        }

        #expect(
            try useCase.loadDocuments(for: assignmentID).isEmpty
        )
    }

    @Test
    func duplicateFilenameIsRenamed() throws {
        let assignmentID = makeAssignmentID()
        let folder = try makeTemporaryFolder()

        defer {
            cleanup(
                assignmentIDs: [assignmentID],
                temporaryFolder: folder
            )
        }

        let source = try makePDF(
            in: folder,
            filename: "notes.pdf"
        )

        let first = try useCase.importPDF(
            from: source,
            assignmentID: assignmentID
        )

        let second = try useCase.importPDF(
            from: source,
            assignmentID: assignmentID
        )

        #expect(first.lastPathComponent == "notes.pdf")
        #expect(second.lastPathComponent == "notes (1).pdf")

        #expect(
            try useCase.loadDocuments(for: assignmentID).count == 2
        )
    }

    @Test
    func deleteExistingPDF() throws {
        let assignmentID = makeAssignmentID()
        let folder = try makeTemporaryFolder()

        defer {
            cleanup(
                assignmentIDs: [assignmentID],
                temporaryFolder: folder
            )
        }

        let source = try makePDF(
            in: folder,
            filename: "delete.pdf"
        )

        let imported = try useCase.importPDF(
            from: source,
            assignmentID: assignmentID
        )

        try useCase.deletePDF(
            imported,
            assignmentID: assignmentID
        )

        #expect(!fileManager.fileExists(atPath: imported.path))

        #expect(
            try useCase.loadDocuments(for: assignmentID).isEmpty
        )
    }

    @Test
    func cannotDeletePDFOfAnotherAssignment() throws {
        let firstID = makeAssignmentID()
        let secondID = makeAssignmentID()
        let folder = try makeTemporaryFolder()

        defer {
            cleanup(
                assignmentIDs: [firstID, secondID],
                temporaryFolder: folder
            )
        }

        let source = try makePDF(
            in: folder,
            filename: "protected.pdf"
        )

        let imported = try useCase.importPDF(
            from: source,
            assignmentID: firstID
        )

        #expect(
            throws: DocumentUseCase.DocumentError.invalidFileLocation
        ) {
            try useCase.deletePDF(
                imported,
                assignmentID: secondID
            )
        }

        #expect(fileManager.fileExists(atPath: imported.path))
    }
}
