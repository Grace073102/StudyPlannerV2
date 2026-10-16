//
//  TaskActionUseCaseTests.swift
//  StudyPlannerV2
//
//  Created by Pichaya Viwatassawin on 17/10/2026.
//


import Foundation
import Testing
@testable import StudyPlannerV2

@MainActor
struct TaskActionUseCaseTests {

    private func makeAssignmentWithTask() -> (Assignment, AcademicTask) {
        let task = AcademicTask(
            title: "Revise notes",
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

    @Test func toggleMarksTaskComplete() throws {
        let (assignment, task) = makeAssignmentWithTask()
        let repository = MockAssignmentRepository(assignments: [assignment])
        let useCase = ToggleTaskUseCase(repository: repository)

        try useCase.execute(taskID: task.id)

        #expect(repository.assignments.first?.tasks.first?.isCompleted == true)
    }

    @Test func deleteRemovesTask() throws {
        let (assignment, task) = makeAssignmentWithTask()
        let repository = MockAssignmentRepository(assignments: [assignment])
        let useCase = DeleteTaskUseCase(repository: repository)

        try useCase.execute(taskID: task.id)

        #expect(repository.assignments.first?.tasks.isEmpty == true)
    }
}
