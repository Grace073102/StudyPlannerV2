//
//  EditTaskUseCaseTests.swift
//  StudyPlannerV2
//
//  Created by Pichaya Viwatassawin on 17/10/2026.
//


import Foundation
import Testing
@testable import StudyPlannerV2

@MainActor
struct EditTaskUseCaseTests {

    private func makeAssignmentWithTask() -> (Assignment, AcademicTask) {
        let task = AcademicTask(
            title: "Old title",
            isCompleted: false,
            plannedDate: nil,
            estimatedMinutes: 30
        )

        let assignment = Assignment(
            title: "Capstone",
            course: "40005 Advanced iOS",
            dueDate: .now,
            priority: .high,
            description: nil,
            tasks: [task]
        )

        return (assignment, task)
    }

    @Test func editsTaskDetails() throws {
        let (assignment, task) = makeAssignmentWithTask()
        let repository = MockAssignmentRepository(assignments: [assignment])
        let useCase = EditTaskUseCase(repository: repository)

        try useCase.execute(
            taskID: task.id,
            title: "  New title  ",
            plannedDate: nil,
            estimatedMinutes: 90
        )

        let updatedTask = repository.assignments.first?.tasks.first
        #expect(updatedTask?.title == "New title")
        #expect(updatedTask?.estimatedMinutes == 90)
    }

    @Test func emptyTitleThrowsMissingTitle() {
        let (assignment, task) = makeAssignmentWithTask()
        let repository = MockAssignmentRepository(assignments: [assignment])
        let useCase = EditTaskUseCase(repository: repository)

        #expect(throws: EditTaskUseCase.EditTaskError.missingTitle) {
            try useCase.execute(
                taskID: task.id,
                title: "   ",
                plannedDate: nil,
                estimatedMinutes: 30
            )
        }

        #expect(repository.updateCallCount == 0)
    }

    @Test func zeroMinutesThrowsInvalidEstimatedTime() {
        let (assignment, task) = makeAssignmentWithTask()
        let repository = MockAssignmentRepository(assignments: [assignment])
        let useCase = EditTaskUseCase(repository: repository)

        #expect(throws: EditTaskUseCase.EditTaskError.invalidEstimatedTime) {
            try useCase.execute(
                taskID: task.id,
                title: "New title",
                plannedDate: nil,
                estimatedMinutes: 0
            )
        }

        #expect(repository.updateCallCount == 0)
    }

    @Test func unknownTaskThrowsTaskNotFound() {
        let (assignment, _) = makeAssignmentWithTask()
        let repository = MockAssignmentRepository(assignments: [assignment])
        let useCase = EditTaskUseCase(repository: repository)

        #expect(throws: EditTaskUseCase.EditTaskError.taskNotFound) {
            try useCase.execute(
                taskID: "does-not-exist",
                title: "New title",
                plannedDate: nil,
                estimatedMinutes: 30
            )
        }

        #expect(repository.updateCallCount == 0)
    }
}
