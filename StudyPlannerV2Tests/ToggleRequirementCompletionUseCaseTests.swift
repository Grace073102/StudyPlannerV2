//
//  ToggleRequirementCompletionUseCaseTests.swift
//  StudyPlannerV2Tests
//
//  Created by Djy on 20/10/2026.
//

import Foundation
import Testing
@testable import StudyPlannerV2

@MainActor
struct ToggleRequirementCompletionUseCaseTests {

    private func makeRequirement(
        isCompleted: Bool = false
    ) -> PlacementRequirement {
        PlacementRequirement(
            placementID: UUID(),
            name: "Police Check",
            category: .checksAndClearances,
            isCompleted: isCompleted
        )
    }

    @Test func marksIncompleteRequirementAsCompleted() throws {
        let requirement = makeRequirement()
        let repository = MockRequirementRepository(
            requirements: [requirement]
        )
        let useCase = ToggleRequirementCompletionUseCase(
            repository: repository
        )

        let updated = try useCase.execute(id: requirement.id)

        #expect(updated.isCompleted)
        #expect(repository.requirements.first?.isCompleted == true)
        #expect(repository.updateCallCount == 1)
    }

    @Test func marksCompletedRequirementAsIncomplete() throws {
        let requirement = makeRequirement(isCompleted: true)
        let repository = MockRequirementRepository(
            requirements: [requirement]
        )
        let useCase = ToggleRequirementCompletionUseCase(
            repository: repository
        )

        let updated = try useCase.execute(id: requirement.id)

        #expect(!updated.isCompleted)
        #expect(repository.requirements.first?.isCompleted == false)
    }

    @Test func togglingTwiceRestoresOriginalStatus() throws {
        let requirement = makeRequirement()
        let repository = MockRequirementRepository(
            requirements: [requirement]
        )
        let useCase = ToggleRequirementCompletionUseCase(
            repository: repository
        )

        _ = try useCase.execute(id: requirement.id)
        _ = try useCase.execute(id: requirement.id)

        #expect(repository.requirements.first?.isCompleted == false)
        #expect(repository.updateCallCount == 2)
    }

    @Test func rejectsUnknownRequirement() {
        let repository = MockRequirementRepository()
        let useCase = ToggleRequirementCompletionUseCase(
            repository: repository
        )

        #expect(throws: RequirementValidationError.notFound) {
            try useCase.execute(id: UUID())
        }

        #expect(repository.updateCallCount == 0)
    }

    @Test func propagatesLoadFailure() {
        let repository = MockRequirementRepository()
        repository.shouldFailOnLoad = true
        let useCase = ToggleRequirementCompletionUseCase(
            repository: repository
        )

        #expect(throws: MockRequirementRepositoryError.self) {
            try useCase.execute(id: UUID())
        }

        #expect(repository.updateCallCount == 0)
    }

    @Test func propagatesUpdateFailure() {
        let requirement = makeRequirement()
        let repository = MockRequirementRepository(
            requirements: [requirement]
        )
        repository.shouldFailOnUpdate = true

        let useCase = ToggleRequirementCompletionUseCase(
            repository: repository
        )

        #expect(throws: MockRequirementRepositoryError.self) {
            try useCase.execute(id: requirement.id)
        }

        #expect(repository.requirements.first?.isCompleted == false)
    }
    
    @Test func togglingCompletionPreservesOtherFields() throws {
        let dueDate = Calendar.current.date(
            from: DateComponents(year: 2026, month: 10, day: 27)
        )!

        let requirement = PlacementRequirement(
            placementID: UUID(),
            name: "Police Check",
            category: .checksAndClearances,
            dueDate: dueDate,
            isCompleted: false
        )

        let repository = MockRequirementRepository(
            requirements: [requirement]
        )
        let useCase = ToggleRequirementCompletionUseCase(
            repository: repository
        )

        let updated = try useCase.execute(id: requirement.id)

        #expect(updated.isCompleted)
        #expect(updated.id == requirement.id)
        #expect(updated.placementID == requirement.placementID)
        #expect(updated.name == requirement.name)
        #expect(updated.category == requirement.category)
        #expect(updated.dueDate == requirement.dueDate)
    }
}
