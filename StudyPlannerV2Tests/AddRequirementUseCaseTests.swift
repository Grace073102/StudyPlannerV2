//
//  AddRequirementUseCaseTests.swift
//  StudyPlannerV2Tests
//
//  Created by Djy on 20/10/2026.
//

import Foundation
import Testing
@testable import StudyPlannerV2

@MainActor
struct AddRequirementUseCaseTests {

    private let calendar = Calendar.current

    private var today: Date {
        calendar.date(from: DateComponents(
            year: 2026, month: 10, day: 20
        ))!
    }

    private var yesterday: Date {
        calendar.date(byAdding: .day, value: -1, to: today)!
    }

    private var nextWeek: Date {
        calendar.date(byAdding: .day, value: 7, to: today)!
    }

    @Test func addsValidRequirement() throws {
        let repository = MockRequirementRepository()
        let useCase = AddRequirementUseCase(repository: repository)
        let placementID = UUID()

        let result = try useCase.execute(
            placementID: placementID,
            name: "  Police Check  ",
            category: .checksAndClearances,
            dueDate: nextWeek,
            expiryDate: nil,
            today: today
        )

        #expect(repository.requirements.count == 1)
        #expect(result.name == "Police Check")
        #expect(result.placementID == placementID)
        #expect(repository.addCallCount == 1)
    }

    @Test func acceptsTodayAsDueDate() throws {
        let repository = MockRequirementRepository()
        let useCase = AddRequirementUseCase(repository: repository)

        _ = try useCase.execute(
            placementID: UUID(),
            name: "Orientation",
            category: .placementPreparation,
            dueDate: today,
            expiryDate: nil,
            today: today
        )

        #expect(repository.requirements.count == 1)
    }

    @Test func acceptsNoDueDate() throws {
        let repository = MockRequirementRepository()
        let useCase = AddRequirementUseCase(repository: repository)

        _ = try useCase.execute(
            placementID: UUID(),
            name: "Orientation",
            category: .placementPreparation,
            dueDate: nil,
            expiryDate: nil,
            today: today
        )

        #expect(repository.requirements.first?.dueDate == nil)
    }

    @Test func rejectsEmptyName() {
        let repository = MockRequirementRepository()
        let useCase = AddRequirementUseCase(repository: repository)

        #expect(throws: AddRequirementUseCase.AddRequirementError.missingName) {
            try useCase.execute(
                placementID: UUID(),
                name: "   ",
                category: .placementPreparation,
                dueDate: nextWeek,
                expiryDate: nil,
                today: today
            )
        }

        #expect(repository.addCallCount == 0)
    }

    @Test func rejectsPastDueDate() {
        let repository = MockRequirementRepository()
        let useCase = AddRequirementUseCase(repository: repository)

        #expect(throws: AddRequirementUseCase.AddRequirementError.invalidDueDate) {
            try useCase.execute(
                placementID: UUID(),
                name: "Police Check",
                category: .checksAndClearances,
                dueDate: yesterday,
                expiryDate: nil,
                today: today
            )
        }

        #expect(repository.addCallCount == 0)
    }

    @Test func propagatesSaveFailure() {
        let repository = MockRequirementRepository()
        repository.shouldFailOnAdd = true
        let useCase = AddRequirementUseCase(repository: repository)

        #expect(throws: MockRequirementRepositoryError.self) {
            try useCase.execute(
                placementID: UUID(),
                name: "Police Check",
                category: .checksAndClearances,
                dueDate: nextWeek,
                expiryDate: nil,
                today: today
            )
        }

        #expect(repository.requirements.isEmpty)
    }
}

