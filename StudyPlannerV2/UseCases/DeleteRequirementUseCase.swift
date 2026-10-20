
//
//  DeleteRequirementUseCase.swift
//  StudyPlannerV2
//
//  Created by Djy on 15/10/2026.
//

import Foundation

/// Deletes an existing placement requirement.
/// The ViewModel calls this use case when a requirement is deleted.
///
/// Business rules:
/// 1. Only an existing requirement can be deleted.
/// 2. The deletion is saved through the repository.
struct DeleteRequirementUseCase {

    let repository: RequirementRepository

    func execute(id: UUID) throws {

        // Find the requirement
        guard let requirement = try repository.load().first(
            where: { $0.id == id }
        ) else {
            throw RequirementValidationError.notFound
        }

        // Delete the requirement
        try repository.delete(requirement)
    }
}
