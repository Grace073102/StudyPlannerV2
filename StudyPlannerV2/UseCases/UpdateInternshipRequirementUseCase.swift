//
//  UpdateInternshipRequirementUseCase.swift
//  StudyPlannerV2
//
//  Created by Djy on 28/10/2026.
//

import Foundation

/// Updates an existing internship requirement.
/// The ViewModel calls this use case to validate and save changes.
///
/// Business rules:
/// 1. A requirement must have a name (blank/space is rejected).
/// 2. An unchanged overdue due date is allowed when editing.
/// 3. Only an existing requirement can be updated.
struct UpdateInternshipRequirementUseCase {

    let repository: InternshipRequirementRepository

    func execute(
        id: UUID,
        name: String,
        category: InternshipRequirement.Category,
        dueDate: Date?,
        expiryDate: Date?,
        today: Date = Date()
    ) throws {

        // Validate requirement name
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw RequirementValidationError.emptyName
        }

        // Find existing requirement
        guard let existingRequirement = try repository.load().first(where: { $0.id == id }) else {
            throw RequirementValidationError.notFound
        }

        // Validate due date only when the calendar day changes
        if let dueDate {
            let calendar = Calendar.current

            let isSameDay = existingRequirement.dueDate.map {
                calendar.isDate($0, inSameDayAs: dueDate)
            } ?? false

            if !isSameDay {
                let currentDay = calendar.startOfDay(for: today)
                let selectedDueDate = calendar.startOfDay(for: dueDate)

                guard selectedDueDate >= currentDay else {
                    throw RequirementValidationError.invalidDueDate
                }
            }
        }

        // Update existing requirement
        let updatedRequirement = existingRequirement.copy()

        updatedRequirement.name = trimmedName
        updatedRequirement.category = category
        updatedRequirement.dueDate = dueDate
        updatedRequirement.expiryDate = expiryDate

        try repository.update(updatedRequirement)
    }
}
