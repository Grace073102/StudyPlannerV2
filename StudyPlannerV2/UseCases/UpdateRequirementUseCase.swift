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
        expiryDate: Date?,
        today: Date = Date()
    ) throws {

        // Validate requirement name
        let trimmedName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedName.isEmpty else {
            throw RequirementValidationError.emptyName
        }

        // Find existing requirement
        guard let existingRequirement = repository.load().first(
            where: { $0.id == id }
        ) else {
            throw RequirementValidationError.notFound
        }

        // Validate due date only when it changes
        if let dueDate,
           existingRequirement.dueDate != dueDate {

            let calendar = Calendar.current
            let currentDay = calendar.startOfDay(for: today)
            let selectedDueDate = calendar.startOfDay(for: dueDate)

            guard selectedDueDate >= currentDay else {
                throw RequirementValidationError.invalidDueDate
            }
        }

        // Update existing requirement
        let updatedRequirement = existingRequirement.copy()

        updatedRequirement.name = trimmedName
        updatedRequirement.category = category
        updatedRequirement.dueDate = dueDate
        updatedRequirement.expiryDate = expiryDate

        repository.update(updatedRequirement)
    }
}
