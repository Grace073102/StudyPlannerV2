//
//  EditTaskUseCase.swift
//  StudyPlannerV2
//
//  Created by Pichaya Viwatassawin on 17/10/2026.
//


import Foundation
/// Edits the title, planned date, and estimated time of an existing subtask.
///
/// Business rules:
/// 1. A subtask must have a title (blank/space only is rejected).
/// 2. Title is trimmed before it is saved
/// 3. Estimated study time (if given) must be more than 0 mminutes
/// 4. Only an existing subtask can be edited.
struct EditTaskUseCase {

    let repository: AssignmentRepository

    enum EditTaskError: LocalizedError, Equatable {
        case missingTitle
        case invalidEstimatedTime
        case taskNotFound

        var errorDescription: String? {
            switch self {
            case .missingTitle:
                return "Enter a subtask title before saving."
            case .invalidEstimatedTime:
                return "Estimated study time must be more than 0 minutes."
            case .taskNotFound:
                return "This subtask could not be found. It may have been deleted."
            }
        }
    }

    func execute(
        taskID: String,
        title: String,
        plannedDate: Date?,
        estimatedMinutes: Int?
    ) throws {
        let cleanedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedTitle.isEmpty else {
            throw EditTaskError.missingTitle
        }

        if let estimatedMinutes, estimatedMinutes <= 0 {
            throw EditTaskError.invalidEstimatedTime
        }

        for assignment in repository.assignments {
            let updatedAssignment = assignment.copy()
            
            guard let taskIndex = updatedAssignment.tasks.firstIndex(
                where: { $0.id == taskID }
            ) else {
                continue
            }

            updatedAssignment.tasks[taskIndex].title = cleanedTitle
            updatedAssignment.tasks[taskIndex].plannedDate = plannedDate
            updatedAssignment.tasks[taskIndex].estimatedMinutes = estimatedMinutes

            try repository.update(updatedAssignment)
            return
        }

        throw EditTaskError.taskNotFound
    }
}
