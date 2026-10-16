//
//  UpdateAssignmentUseCaseTests.swift
//  StudyPlannerV2
//
//  Created by Pichaya Viwatassawin on 17/10/2026.
//


import Foundation
import Testing
@testable import StudyPlannerV2

@MainActor
struct UpdateAssignmentUseCaseTests {

    private let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: .now)!
    private let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: .now)!

    private func makeAssignment(dueDate: Date) -> Assignment {
        Assignment(
            title: "Old title",
            course: "40005 Advanced iOS",
            dueDate: dueDate,
            priority: .low,
            description: nil,
            tasks: []
        )
    }

    @Test func updatesAssignmentDetails() throws {
        let assignment = makeAssignment(dueDate: nextWeek)
        let repository = MockAssignmentRepository(assignments: [assignment])
        let useCase = UpdateAssignmentUseCase(repository: repository)

        try useCase.execute(
            assignmentID: assignment.id,
            title: "  Capstone report  ",
            course: "40005 Advanced iOS",
            dueDate: nextWeek,
            priority: .high,
            description: "   "
        )

        let updated = repository.assignments.first
        #expect(updated?.title == "Capstone report")
        #expect(updated?.priority == .high)
        #expect(updated?.description == nil)
    }

    @Test func emptyTitleThrowsMissingTitle() {
        let assignment = makeAssignment(dueDate: nextWeek)
        let repository = MockAssignmentRepository(assignments: [assignment])
        let useCase = UpdateAssignmentUseCase(repository: repository)

        #expect(throws: UpdateAssignmentUseCase.UpdateAssignmentError.missingTitle) {
            try useCase.execute(
                assignmentID: assignment.id,
                title: "   ",
                course: "40005 Advanced iOS",
                dueDate: nextWeek,
                priority: .low,
                description: ""
            )
        }

        #expect(repository.updateCallCount == 0)
    }

    @Test func changingDueDateToPastThrowsDueDateInPast() {
        let assignment = makeAssignment(dueDate: nextWeek)
        let repository = MockAssignmentRepository(assignments: [assignment])
        let useCase = UpdateAssignmentUseCase(repository: repository)

        #expect(throws: UpdateAssignmentUseCase.UpdateAssignmentError.dueDateInPast) {
            try useCase.execute(
                assignmentID: assignment.id,
                title: "Old title",
                course: "40005 Advanced iOS",
                dueDate: threeDaysAgo,
                priority: .low,
                description: ""
            )
        }

        #expect(repository.updateCallCount == 0)
    }

    @Test func overdueAssignmentCanStillBeEdited() throws {
        let assignment = makeAssignment(dueDate: threeDaysAgo)
        let repository = MockAssignmentRepository(assignments: [assignment])
        let useCase = UpdateAssignmentUseCase(repository: repository)

        try useCase.execute(
            assignmentID: assignment.id,
            title: "Fixed typo",
            course: "40005 Advanced iOS",
            dueDate: threeDaysAgo,
            priority: .low,
            description: ""
        )

        #expect(repository.assignments.first?.title == "Fixed typo")
    }

    @Test func unknownAssignmentThrowsAssignmentNotFound() {
        let repository = MockAssignmentRepository(assignments: [])
        let useCase = UpdateAssignmentUseCase(repository: repository)

        #expect(throws: UpdateAssignmentUseCase.UpdateAssignmentError.assignmentNotFound) {
            try useCase.execute(
                assignmentID: "does-not-exist",
                title: "Capstone",
                course: "40005 Advanced iOS",
                dueDate: nextWeek,
                priority: .low,
                description: ""
            )
        }
    }
}
