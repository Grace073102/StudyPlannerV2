//
//  AssignmentStorageMapping.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 16/10/2026.
//

import Foundation

enum AssignmentStorageError: LocalizedError {
    case invalidPriority(String)

    var errorDescription: String? {
        switch self {
        case .invalidPriority(let value):
            return "The saved assignment has an unknown priority: \(value)."
        }
    }
}

extension StoredAssignment {
    func toAssignment() throws -> Assignment {
        guard let priority = Assignment.Priority(rawValue: priorityRawValue) else {
            throw AssignmentStorageError.invalidPriority(priorityRawValue)
        }

        return Assignment(
            id: id,
            title: title,
            course: course,
            dueDate: dueDate,
            priority: priority,
            description: assignmentDescription,
            tasks: tasks
                .sorted { $0.position < $1.position }
                .map { $0.toAcademicTask() }
        )
    }
}

extension StoredAcademicTask {
    func toAcademicTask() -> AcademicTask {
        AcademicTask(
            id: id,
            title: title,
            isCompleted: isCompleted,
            plannedDate: plannedDate,
            estimatedMinutes: estimatedMinutes
        )
    }
}
