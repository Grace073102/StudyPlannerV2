//
//  UpdateAssignmentUseCase.swift
//  StudyPlannerV2
//
//  Created by Pichaya Viwatassawin on 17/10/2026.
//


import Foundation

struct UpdateAssignmentUseCase {

    let repository: AssignmentRepository

    enum UpdateAssignmentError: LocalizedError, Equatable {
        case missingTitle
        case missingCourse
        case dueDateInPast
        case assignmentNotFound

        var errorDescription: String? {
            switch self {
            case .missingTitle:
                return "Enter an assignment title before saving."
            case .missingCourse:
                return "Enter the course for this assignment before saving."
            case .dueDateInPast:
                return "The due date cannot be in the past. Choose today or a future date."
            case .assignmentNotFound:
                return "This assignment could not be found. It may have been deleted."
            }
        }
    }

    @discardableResult
    func execute(
        assignmentID: String,
        title: String,
        course: String,
        dueDate: Date,
        priority: Assignment.Priority,
        description: String,
        today: Date = .now
    ) throws -> Assignment {
        let cleanedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedCourse = course.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedTitle.isEmpty else {
            throw UpdateAssignmentError.missingTitle
        }

        guard !cleanedCourse.isEmpty else {
            throw UpdateAssignmentError.missingCourse
        }

        guard let existingAssignment = repository.assignments.first(
            where: { $0.id == assignmentID }
        ) else {
            throw UpdateAssignmentError.assignmentNotFound
        }

        let assignment = existingAssignment.copy()
        let calendar = Calendar.current
        let dueDateChanged = !calendar.isDate(dueDate, inSameDayAs: assignment.dueDate)
        let startOfToday = calendar.startOfDay(for: today)

        if dueDateChanged && calendar.startOfDay(for: dueDate) < startOfToday {
            throw UpdateAssignmentError.dueDateInPast
        }

        assignment.title = cleanedTitle
        assignment.course = cleanedCourse
        assignment.dueDate = dueDate
        assignment.priority = priority
        assignment.description = cleanedDescription.isEmpty ? nil : cleanedDescription

        try repository.update(assignment)
        return assignment
    }
}
