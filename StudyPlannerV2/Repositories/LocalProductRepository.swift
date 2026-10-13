//
//  LocalProductRepository.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 14/10/2026.
//

import Foundation

class LocalAssignmentRepository: AssignmentRepository {

    private(set) var assignments: [Assignment] = []

    init() {
        assignments = load()
    }

    func load() -> [Assignment] {
        let localAssignments = [

            Assignment(
                title: "Database Assignment",
                course: "Database Systems",
                dueDate: Date().addingTimeInterval(86400 * 3),
                priority: .high,
                tasks: [
                    AcademicTask(
                        title: "Complete Tutorial 2",
                        isCompleted: false
                    ),
                    AcademicTask(
                        title: "Revise Chapter 1",
                        isCompleted: false
                    )
                ]
            ),

            Assignment(
                title: "UI/UX Project",
                course: "UI/UX Design",
                dueDate: Date().addingTimeInterval(86400 * 7),
                priority: .medium,
                tasks: [
                    AcademicTask(
                        title: "Complete Wireframe",
                        isCompleted: false
                    )
                ]
            )
        ]

        return localAssignments
    }

    func add(_ assignment: Assignment) {
        assignments.append(assignment)
    }

    func update(_ assignment: Assignment) {
        guard let index = assignments.firstIndex(where: { $0.id == assignment.id }) else { return }

        assignments[index] = assignment
    }

    func delete(_ assignment: Assignment) {
        guard let index = assignments.firstIndex(where: { $0.id == assignment.id }) else { return }

        assignments.remove(at: index)
    }
}
