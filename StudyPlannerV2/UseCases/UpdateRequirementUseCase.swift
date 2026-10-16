//
//  UpdateRequirementUseCase.swift
//  StudyPlannerV2
//
//  Created by Djy on 15/10/2026.
//

import Foundation

struct UpdateRequirementUseCase {

    let repository: RequirementRepository

    func execute(
        id: UUID,
        name: String,
        category: PlacementRequirement.Category,
        dueDate: Date?,
        expiryDate: Date?
    ) throws {

        // Validate requirement name
        let trimmedName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedName.isEmpty else {
            throw RequirementValidationError.emptyName
        }

        // Validate due date
        if let dueDate {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let selectedDueDate = calendar.startOfDay(for: dueDate)

            guard selectedDueDate >= today else {
                throw RequirementValidationError.invalidDueDate
            }
        }

        // Find existing requirement
        guard let existingRequirement = repository.load().first(
            where: { $0.id == id }
        ) else {
            throw RequirementValidationError.notFound
        }

        // Update existing requirement
        var updatedRequirement = existingRequirement

        updatedRequirement.name = trimmedName
        updatedRequirement.category = category
        updatedRequirement.dueDate = dueDate
        updatedRequirement.expiryDate = expiryDate

        repository.update(updatedRequirement)
    }
}
