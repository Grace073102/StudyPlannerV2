//
//  AddRequirementUseCase.swift
//  StudyPlannerV2
//
//  Created by Djy on 15/10/2026.
//

import Foundation

struct AddRequirementUseCase {

    let repository: RequirementRepository

    enum AddRequirementError: LocalizedError {
        case missingName
        case invalidDueDate

        var errorDescription: String? {
            switch self {
            case .missingName:
                return "Enter a requirement name before saving."
            case .invalidDueDate:
                return "The due date cannot be in the past. Choose today or a future date."
            }
        }
    }

    func execute(
        placementID: UUID,
        name: String,
        category: PlacementRequirement.Category,
        dueDate: Date?,
        expiryDate: Date?,
        today: Date = Date()
    ) throws -> PlacementRequirement {

        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedName.isEmpty else {
            throw AddRequirementError.missingName
        }

        let calendar = Calendar.current
        let currentDay = calendar.startOfDay(for: today)

        if let dueDate {
            let selectedDueDate = calendar.startOfDay(for: dueDate)

            guard selectedDueDate >= currentDay else {
                throw AddRequirementError.invalidDueDate
            }
        }

        let requirement = PlacementRequirement(
            placementID: placementID,
            name: cleanedName,
            category: category,
            dueDate: dueDate,
            expiryDate: expiryDate,
            isCompleted: false
        )

        try repository.add(requirement)

        return requirement
    }
}
