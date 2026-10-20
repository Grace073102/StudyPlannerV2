//
//  ToggleRequirementCompletionUseCase.swift
//  StudyPlannerV2
//
//  Created by Djy on 20/10/2026.
//

import Foundation

/// Toggles the completion status of a placement requirement.
/// The ViewModel calls this use case when a requirement is marked complete or incomplete.
///
/// Business rules:
/// 1. Only an existing requirement can be updated.
/// 2. The completion status is saved through the repository.
struct ToggleRequirementCompletionUseCase {

    let repository: RequirementRepository

    func execute(id: UUID) throws -> PlacementRequirement {

        guard let requirement = try repository.load()
            .first(where: { $0.id == id }) else {
            throw RequirementValidationError.notFound
        }

        let updatedRequirement = requirement.copy()
        updatedRequirement.isCompleted.toggle()

        try repository.update(updatedRequirement)

        return updatedRequirement
    }
}
