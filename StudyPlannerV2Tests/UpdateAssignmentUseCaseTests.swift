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

    private let today = Calendar.current.date(
        from: DateComponents(year: 2026, month: 10, day: 20)
    )!
    private var threeDaysAgo: Date {
        Calendar.current.date(byAdding: .day, value: -3, to: today)!
    }
    private var yesterday: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: today)!
    }
    private var nextWeek: Date {
        Calendar.current.date(byAdding: .day, value: 7, to: today)!
    }

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
            description: "   ",
            today: today
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
                description: "",
                today: today
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
                description: "",
                today: today
            )
        }

        #expect(repository.updateCallCount == 0)
    }
    
    // Boundary Test: changing the due date to today is allowed.
    @Test func changingDueDateToTodayIsValid() throws {
        let assignment = makeAssignment(dueDate: nextWeek)
        let repository = MockAssignmentRepository(assignments: [assignment])
        let useCase = UpdateAssignmentUseCase(repository: repository)

        try useCase.execute(
            assignmentID: assignment.id,
            title: "Old title",
            course: "40005 Advanced iOS",
            dueDate: today,
            priority: .low,
            description: "",
            today: today
        )

        #expect(repository.assignments.first?.dueDate == today)
    }

    // Boundary Test: changing the due date to yesterday is rejected.
    @Test func changingDueDateToYesterdayThrowsDueDateInPast() {
        let assignment = makeAssignment(dueDate: nextWeek)
        let repository = MockAssignmentRepository(assignments: [assignment])
        let useCase = UpdateAssignmentUseCase(repository: repository)

        #expect(throws: UpdateAssignmentUseCase.UpdateAssignmentError.dueDateInPast) {
            try useCase.execute(
                assignmentID: assignment.id,
                title: "Old title",
                course: "40005 Advanced iOS",
                dueDate: yesterday,
                priority: .low,
                description: "",
                today: today
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
            description: "",
            today: today
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
                description: "",
                today: today
            )
        }
    }
}
