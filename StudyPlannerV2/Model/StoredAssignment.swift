//
//  StoredAssignment.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 16/10/2026.
//

import Foundation
import SwiftData

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

    init(assignment: Assignment) {
        id = assignment.id
        title = assignment.title
        course = assignment.course
        dueDate = assignment.dueDate
        priorityRawValue = assignment.priority.rawValue
        assignmentDescription = assignment.description
    }
}
