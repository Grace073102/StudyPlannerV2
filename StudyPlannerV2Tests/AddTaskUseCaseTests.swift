//
//  AddTaskUseCaseTests.swift
//  StudyPlannerV2
//
//  Created by Pichaya Viwatassawin on 17/10/2026.
//


import Foundation
import Testing
@testable import StudyPlannerV2

@MainActor
struct AddTaskUseCaseTests {

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

    @Test func addsTaskToAssignment() throws {
        let assignment = makeAssignment()
        let repository = MockAssignmentRepository(assignments: [assignment])
        let useCase = AddTaskUseCase(repository: repository)

        let task = try useCase.execute(
            title: "  Draft architecture diagram  ",
            plannedDate: nil,
            estimatedMinutes: 45,
            assignmentID: assignment.id
        )

        #expect(task.title == "Draft architecture diagram")
        #expect(repository.assignments.first?.tasks.count == 1)
        #expect(repository.assignments.first?.tasks.first?.estimatedMinutes == 45)
    }

    @Test func emptyTitleThrowsMissingTitle() {
        let assignment = makeAssignment()
        let repository = MockAssignmentRepository(assignments: [assignment])
        let useCase = AddTaskUseCase(repository: repository)

        #expect(throws: AddTaskUseCase.AddTaskError.missingTitle) {
            try useCase.execute(
                title: "   ",
                plannedDate: nil,
                estimatedMinutes: 30,
                assignmentID: assignment.id
            )
        }

        #expect(repository.updateCallCount == 0)
    }

    @Test func zeroMinutesThrowsInvalidEstimatedTime() {
        let assignment = makeAssignment()
        let repository = MockAssignmentRepository(assignments: [assignment])
        let useCase = AddTaskUseCase(repository: repository)

        #expect(throws: AddTaskUseCase.AddTaskError.invalidEstimatedTime) {
            try useCase.execute(
                title: "Revise notes",
                plannedDate: nil,
                estimatedMinutes: 0,
                assignmentID: assignment.id
            )
        }

        #expect(repository.updateCallCount == 0)
    }

    @Test func unknownAssignmentThrowsAssignmentNotFound() {
        let repository = MockAssignmentRepository(assignments: [])
        let useCase = AddTaskUseCase(repository: repository)

        #expect(throws: AddTaskUseCase.AddTaskError.assignmentNotFound) {
            try useCase.execute(
                title: "Revise notes",
                plannedDate: nil,
                estimatedMinutes: 30,
                assignmentID: "does-not-exist"
            )
        }
    }
}
