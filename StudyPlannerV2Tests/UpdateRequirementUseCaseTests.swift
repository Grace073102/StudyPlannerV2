//
//  UpdateRequirementUseCaseTests.swift
//  StudyPlannerV2Tests
//
//  Created by Djy on 20/10/2026.
//

import Foundation
import Testing
@testable import StudyPlannerV2

@MainActor
struct UpdateRequirementUseCaseTests {

    private let calendar = Calendar.current

    private var today: Date {
        calendar.date(
            from: DateComponents(year: 2026, month: 10, day: 20)
        )!
    }

    private var threeDaysAgo: Date {
        calendar.date(byAdding: .day, value: -3, to: today)!
    }

    private var nextWeek: Date {
        calendar.date(byAdding: .day, value: 7, to: today)!
    }

    private func makeRequirement(
        dueDate: Date?
    ) -> PlacementRequirement {
        PlacementRequirement(
            placementID: UUID(),
            name: "Police Check",
            category: .checksAndClearances,
            dueDate: dueDate
        )
    }

    // Happy Path

    @Test func updatesRequirementDetails() throws {
        let requirement = makeRequirement(dueDate: nextWeek)
        let repository = MockRequirementRepository(
            requirements: [requirement]
        )
        let useCase = UpdateRequirementUseCase(repository: repository)

        try useCase.execute(
            id: requirement.id,
            name: "  Updated Police Check  ",
            category: .placementPreparation,
            dueDate: nextWeek,
            expiryDate: nil,
            today: today
        )

        let updated = try #require(repository.requirements.first)

        #expect(updated.name == "Updated Police Check")
        #expect(updated.category == .placementPreparation)
        #expect(updated.dueDate == nextWeek)
        #expect(repository.updateCallCount == 1)
    }

    // Boundary Conditions

    @Test func overdueRequirementCanStillBeEdited() throws {
        let requirement = makeRequirement(dueDate: threeDaysAgo)
        let repository = MockRequirementRepository(
            requirements: [requirement]
        )
        let useCase = UpdateRequirementUseCase(repository: repository)

        try useCase.execute(
            id: requirement.id,
            name: "Updated Name",
            category: .checksAndClearances,
            dueDate: threeDaysAgo,
            expiryDate: nil,
            today: today
        )

        #expect(repository.requirements.first?.name == "Updated Name")
        #expect(repository.requirements.first?.dueDate == threeDaysAgo)
        #expect(repository.updateCallCount == 1)
    }
    
    @Test func overdueRequirementCanBeEditedWithDifferentTimeOnSameDay() throws {
        let originalDueDate = calendar.date(
            byAdding: .hour,
            value: 9,
            to: threeDaysAgo
        )!

        let submittedDueDate = calendar.date(
            byAdding: .hour,
            value: 15,
            to: threeDaysAgo
        )!

        let requirement = makeRequirement(dueDate: originalDueDate)
        let repository = MockRequirementRepository(
            requirements: [requirement]
        )
        let useCase = UpdateRequirementUseCase(repository: repository)

        try useCase.execute(
            id: requirement.id,
            name: "Updated Police Check",
            category: .checksAndClearances,
            dueDate: submittedDueDate,
            expiryDate: nil,
            today: today
        )

        let updated = try #require(repository.requirements.first)

        #expect(updated.name == "Updated Police Check")
        #expect(updated.dueDate == submittedDueDate)
        #expect(repository.updateCallCount == 1)
    }

    @Test func dueDateCanBeChangedToToday() throws {
        let requirement = makeRequirement(dueDate: nextWeek)
        let repository = MockRequirementRepository(
            requirements: [requirement]
        )
        let useCase = UpdateRequirementUseCase(repository: repository)

        try useCase.execute(
            id: requirement.id,
            name: "Police Check",
            category: .checksAndClearances,
            dueDate: today,
            expiryDate: nil,
            today: today
        )

        #expect(repository.requirements.first?.dueDate == today)
    }

    @Test func dueDateCanBeRemoved() throws {
        let requirement = makeRequirement(dueDate: threeDaysAgo)
        let repository = MockRequirementRepository(
            requirements: [requirement]
        )
        let useCase = UpdateRequirementUseCase(repository: repository)

        try useCase.execute(
            id: requirement.id,
            name: "Police Check",
            category: .checksAndClearances,
            dueDate: nil,
            expiryDate: nil,
            today: today
        )

        #expect(repository.requirements.first?.dueDate == nil)
    }

    // Validation Errors

    @Test func emptyNameIsRejected() {
        let requirement = makeRequirement(dueDate: nextWeek)
        let repository = MockRequirementRepository(
            requirements: [requirement]
        )
        let useCase = UpdateRequirementUseCase(repository: repository)

        #expect(throws: RequirementValidationError.emptyName) {
            try useCase.execute(
                id: requirement.id,
                name: "   ",
                category: .checksAndClearances,
                dueDate: nextWeek,
                expiryDate: nil,
                today: today
            )
        }

        #expect(repository.updateCallCount == 0)
    }

    @Test func changingDueDateToPastIsRejected() {
        let requirement = makeRequirement(dueDate: nextWeek)
        let repository = MockRequirementRepository(
            requirements: [requirement]
        )
        let useCase = UpdateRequirementUseCase(repository: repository)

        #expect(throws: RequirementValidationError.invalidDueDate) {
            try useCase.execute(
                id: requirement.id,
                name: "Police Check",
                category: .checksAndClearances,
                dueDate: threeDaysAgo,
                expiryDate: nil,
                today: today
            )
        }

        #expect(repository.updateCallCount == 0)
    }

    @Test func unknownRequirementIsRejected() {
        let repository = MockRequirementRepository()
        let useCase = UpdateRequirementUseCase(repository: repository)

        #expect(throws: RequirementValidationError.notFound) {
            try useCase.execute(
                id: UUID(),
                name: "Police Check",
                category: .checksAndClearances,
                dueDate: nextWeek,
                expiryDate: nil,
                today: today
            )
        }

        #expect(repository.updateCallCount == 0)
    }

    // Repository Errors

    @Test func loadFailureIsPropagated() {
        let repository = MockRequirementRepository()
        repository.shouldFailOnLoad = true

        let useCase = UpdateRequirementUseCase(repository: repository)

        #expect(throws: MockRequirementRepositoryError.self) {
            try useCase.execute(
                id: UUID(),
                name: "Police Check",
                category: .checksAndClearances,
                dueDate: nextWeek,
                expiryDate: nil,
                today: today
            )
        }

        #expect(repository.updateCallCount == 0)
    }

    @Test func updateFailureIsPropagated() {
        let requirement = makeRequirement(dueDate: nextWeek)
        let repository = MockRequirementRepository(
            requirements: [requirement]
        )
        repository.shouldFailOnUpdate = true

        let useCase = UpdateRequirementUseCase(repository: repository)

        #expect(throws: MockRequirementRepositoryError.self) {
            try useCase.execute(
                id: requirement.id,
                name: "Changed Name",
                category: .checksAndClearances,
                dueDate: nextWeek,
                expiryDate: nil,
                today: today
            )
        }

        #expect(repository.requirements.first?.name == "Police Check")
        #expect(repository.updateCallCount == 1)
    }
}
