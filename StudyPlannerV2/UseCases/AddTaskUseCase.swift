//
//  AddTaskUseCase.swift
//  StudyPlannerV2
//
//  Created by Pichaya Viwatassawin on 17/10/2026.
//

import Foundation

/// Adds subtask to an existing assignment
/// ViewModel calls this type and never touches the repository directly
///
/// Business rules:
/// 1. A subtask must have a title (blank/space only is rejected).
/// 2. Title is trimmed before it is saved.
/// 3. Estimated study time (if given) must be more than 0 minutes.
/// 4. The assignment must exist.
struct AddTaskUseCase {

    let repository: AssignmentRepository

    enum AddTaskError: LocalizedError, Equatable {
        case missingTitle
        case invalidEstimatedTime
        case assignmentNotFound

        var errorDescription: String? {
            switch self {
            case .missingTitle:
                return "Enter a subtask title before adding it."
            case .invalidEstimatedTime:
                return "Estimated study time must be more than 0 minutes."
            case .assignmentNotFound:
                return "This assignment could not be found. It may have been deleted."
            }
        }
    }

    @discardableResult
    func execute(
        title: String,
        plannedDate: Date?,
        estimatedMinutes: Int?,
        assignmentID: String
    ) throws -> AcademicTask {
        let cleanedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedTitle.isEmpty else {
            throw AddTaskError.missingTitle
        }

        if let estimatedMinutes, estimatedMinutes <= 0 {
            throw AddTaskError.invalidEstimatedTime
        }

        guard let existingAssignment = repository.assignments.first(
            where: { $0.id == assignmentID }
        ) else {
            throw AddTaskError.assignmentNotFound
        }
        
        let assignment = existingAssignment.copy()

        let task = AcademicTask(
            title: cleanedTitle,
            isCompleted: false,
            plannedDate: plannedDate,
            estimatedMinutes: estimatedMinutes
        )

        assignment.tasks.append(task)
        try repository.update(assignment)

        return task
    }
}
