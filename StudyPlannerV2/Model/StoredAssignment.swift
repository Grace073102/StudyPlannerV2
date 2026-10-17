//
//  StoredAssignment.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 16/10/2026.
//

import Foundation
import SwiftData

typealias Assignment = StoredAssignment

@Model
final class StoredAssignment {
    @Attribute(.unique) var id: String
    var title: String
    var course: String
    var dueDate: Date
    var priorityRawValue: String
    var assignmentDescription: String?

    @Relationship(deleteRule: .cascade, inverse: \StoredAcademicTask.assignment)
    var tasks: [StoredAcademicTask] = []

    var priority: Priority {
        get { Priority(rawValue: priorityRawValue) ?? .medium }
        set { priorityRawValue = newValue.rawValue }
    }

    var description: String? {
        get { assignmentDescription }
        set { assignmentDescription = newValue }
    }

    var isCompleted: Bool {
        !tasks.isEmpty && tasks.allSatisfy { $0.isCompleted }
    }

    enum Priority: String, CaseIterable, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
    }

    init(
        id: String = UUID().uuidString,
        title: String,
        course: String,
        dueDate: Date,
        priority: Priority,
        description: String? = nil,
        tasks: [AcademicTask]
    ) {
        self.id = id
        self.title = title
        self.course = course
        self.dueDate = dueDate
        priorityRawValue = priority.rawValue
        assignmentDescription = description
        self.tasks = tasks
        for (position, task) in tasks.enumerated() {
            task.position = position
            task.assignment = self
        }
    }

    func copy() -> Assignment {
        let result = Assignment(
            id: id,
            title: title,
            course: course,
            dueDate: dueDate,
            priority: priority,
            description: description,
            tasks: tasks.sorted { $0.position < $1.position }.map { $0.copy() }
        )
        result.priorityRawValue = priorityRawValue
        return result
    }

    func toAssignment() throws -> Assignment {
        guard Priority(rawValue: priorityRawValue) != nil else {
            throw AssignmentStorageError.invalidPriority(priorityRawValue)
        }
        return copy()
    }

    init(assignment: Assignment) {
        id = assignment.id
        title = assignment.title
        course = assignment.course
        dueDate = assignment.dueDate
        priorityRawValue = assignment.priority.rawValue
        assignmentDescription = assignment.description
    }
}

enum AssignmentStorageError: LocalizedError {
    case invalidPriority(String)

    var errorDescription: String? {
        switch self {
        case .invalidPriority(let value):
            return "The saved assignment has an unknown priority: \(value)."
        }
    }
}
