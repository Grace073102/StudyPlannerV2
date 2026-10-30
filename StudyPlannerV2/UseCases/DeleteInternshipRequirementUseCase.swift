//
//  DeleteInternshipRequirementUseCase.swift
//  StudyPlannerV2
//
//  Created by Djy on 28/10/2026.
//

import Foundation

/// Deletes an existing internship requirement and its PDF attachments.
///
/// Business rules:
/// 1. Only an existing requirement can be deleted.
/// 2. The requirement is deleted through the repository first.
/// 3. PDF attachments are cleaned up after successful deletion.
/// 4. A cleanup failure returns a warning because the requirement
///    has already been deleted.
struct DeleteInternshipRequirementUseCase {

    let repository: InternshipRequirementRepository

    var deleteAttachments: (String) throws -> Void = { attachmentID in
        try DocumentUseCase().deleteAllPDFs(
            assignmentID: attachmentID
        )
    }

    /// Returns a warning if the requirement was deleted
    /// but its PDF attachments could not be removed.
    @discardableResult
    func execute(id: UUID) throws -> String? {

        guard let requirement = try repository.load().first(where: { $0.id == id }) else {
            throw RequirementValidationError.notFound
        }

        try repository.delete(requirement)

        do {
            try deleteAttachments("internship-requirement-\(requirement.id.uuidString)")
            return nil
        } catch {
            return "The requirement was deleted, but its PDF attachments could not be removed. \(error.localizedDescription)"
        }
    }
}
