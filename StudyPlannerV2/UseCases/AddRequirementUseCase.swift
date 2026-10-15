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
        case invalidExpiryDate

        var errorDescription: String? {
            switch self {
            case .missingName:
                return "Enter a requirement name before saving."
            case .invalidDueDate:
                return "The due date cannot be in the past. Choose today or a future date."
            case .invalidExpiryDate:
                return "The expiry date cannot be earlier than the due date."
            }
        }
    }

    func execute(
        placementID: UUID,
        name: String,
        category: PlacementRequirement.Category,
        dueDate: Date?,
        expiryDate: Date?
    ) throws -> PlacementRequirement {

        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedName.isEmpty else {
            throw AddRequirementError.missingName
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let dueDate {
            let selectedDueDate = calendar.startOfDay(for: dueDate)

            guard selectedDueDate >= today else {
                throw AddRequirementError.invalidDueDate
            }
        }

        if let dueDate, let expiryDate {
            let selectedDueDate = calendar.startOfDay(for: dueDate)
            let selectedExpiryDate = calendar.startOfDay(for: expiryDate)

            guard selectedExpiryDate >= selectedDueDate else {
                throw AddRequirementError.invalidExpiryDate
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

        repository.add(requirement)

        return requirement
    }
}
