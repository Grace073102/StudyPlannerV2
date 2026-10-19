//
//  ToggleRequirementCompletionUseCase.swift
//  StudyPlannerV2
//
//  Created by Djy on 20/10/2026.
//

import Foundation

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
