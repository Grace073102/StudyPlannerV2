//
//  DocumentViewModel.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 21/10/2026.
//

import Foundation
import Combine

@MainActor
final class DocumentViewModel: ObservableObject {

    @Published private(set) var attachedPDFs: [URL] = []
    @Published var errorMessage: String?
    @Published var isLoading = false

    let assignmentID: String

    private let documentUseCase: DocumentUseCase

    init(
        assignmentID: String,
        documentUseCase: DocumentUseCase? = nil
    ) {
        self.assignmentID = assignmentID
        self.documentUseCase = documentUseCase ?? DocumentUseCase()
    }

    func loadDocuments() {
        isLoading = true
        defer { isLoading = false }

        do {
            attachedPDFs = try documentUseCase.loadDocuments(for: assignmentID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func importPDF(from url: URL) {
        let hasAccess = url.startAccessingSecurityScopedResource()

        defer {
            if hasAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            try documentUseCase.importPDF(from: url, assignmentID: assignmentID)

            loadDocuments()

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func importSharedPDFs() {
        do {
            try documentUseCase.importSharedPDFs(
                assignmentID: assignmentID
            )

            loadDocuments()

        } catch {
            loadDocuments()
            errorMessage = error.localizedDescription
        }
    }

    func deletePDF(_ url: URL) {
        do {
            try documentUseCase.deletePDF(url, assignmentID: assignmentID)

            loadDocuments()

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refresh() {
        importSharedPDFs()
    }
}
