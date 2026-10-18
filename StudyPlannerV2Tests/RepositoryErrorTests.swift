//
//  RepositoryErrorTests.swift
//  StudyPlannerV2
//
//  Created by Pichaya Viwatassawin on 18/10/2026.
//


import Foundation
import Testing
@testable import StudyPlannerV2

/// Tests that save failures from the repository are passed up by the use cases, not ignored.
@MainActor
struct RepositoryErrorTests {

    private func makeAssignment() -> Assignment {
        Assignment(
            title: "Capstone",
            course: "40005 Advanced iOS",
            dueDate: .now,
            priority: .high,
            description: nil,
            tasks: []
        )
    }

    @Test func addTaskPassesUpSaveFailure() {
        let assignment = makeAssignment()
        let repository = MockAssignmentRepository(assignments: [assignment])
        repository.shouldFailOnSave = true
        let useCase = AddTaskUseCase(repository: repository)

        #expect(throws: MockSaveError.self) {
            try useCase.execute(
                title: "Revise notes",
                plannedDate: nil,
                estimatedMinutes: 30,
                assignmentID: assignment.id
            )
        }

        #expect(repository.assignments.first?.tasks.isEmpty == true)
    }

    @Test func updateAssignmentPassesUpSaveFailure() {
        let assignment = makeAssignment()
        let repository = MockAssignmentRepository(assignments: [assignment])
        repository.shouldFailOnSave = true
        let useCase = UpdateAssignmentUseCase(repository: repository)

        #expect(throws: MockSaveError.self) {
            try useCase.execute(
                assignmentID: assignment.id,
                title: "New title",
                course: "40005 Advanced iOS",
                dueDate: assignment.dueDate,
                priority: .high,
                description: ""
            )
        }

        #expect(repository.assignments.first?.title == "Capstone")
    }
}