//
//  AddInternshipRequirementUseCase.swift
//  StudyPlannerV2
//
//  Created by Djy on 28/10/2026.
//

import Foundation

/// Adds a new requirement to an internship.
/// The ViewModel calls this use case to validate and save requirement details.
///
/// Business rules:
/// 1. A requirement must have a name (blank/space is rejected).
/// 2. A due date cannot be in the past.
/// 3. The requirement is saved through the repository.
struct AddInternshipRequirementUseCase {

    let repository: InternshipRequirementRepository

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
        internshipID: UUID,
        name: String,
        category: InternshipRequirement.Category,
        dueDate: Date?,
        expiryDate: Date?,
        today: Date = Date()
    ) throws -> InternshipRequirement {

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

        let requirement = InternshipRequirement(
            internshipID: internshipID,
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
