//
//  DeleteRequirementUseCaseTests.swift
//  StudyPlannerV2Tests
//
//  Created by Djy on 20/10/2026.
//

import Foundation
import Testing
@testable import StudyPlannerV2

@MainActor
struct DeleteRequirementUseCaseTests {

    private func makeRequirement() -> PlacementRequirement {
        PlacementRequirement(
            placementID: UUID(),
            name: "Police Check",
            category: .checksAndClearances
        )
    }

    @Test func deletesExistingRequirement() throws {
        let requirement = makeRequirement()
        let repository = MockRequirementRepository(
            requirements: [requirement]
        )
        let useCase = DeleteRequirementUseCase(repository: repository)

        try useCase.execute(id: requirement.id)

        #expect(repository.requirements.isEmpty)
        #expect(repository.deleteCallCount == 1)
    }

    @Test func rejectsUnknownRequirement() {
        let repository = MockRequirementRepository()
        let useCase = DeleteRequirementUseCase(repository: repository)

        #expect(throws: RequirementValidationError.notFound) {
            try useCase.execute(id: UUID())
        }

        #expect(repository.deleteCallCount == 0)
    }

    @Test func propagatesLoadFailure() {
        let repository = MockRequirementRepository()
        repository.shouldFailOnLoad = true
        let useCase = DeleteRequirementUseCase(repository: repository)

        #expect(throws: MockRequirementRepositoryError.self) {
            try useCase.execute(id: UUID())
        }

        #expect(repository.deleteCallCount == 0)
    }

    @Test func propagatesDeleteFailure() {
        let requirement = makeRequirement()
        let repository = MockRequirementRepository(
            requirements: [requirement]
        )
        repository.shouldFailOnDelete = true

        let useCase = DeleteRequirementUseCase(repository: repository)

        #expect(throws: MockRequirementRepositoryError.self) {
            try useCase.execute(id: requirement.id)
        }

        #expect(repository.requirements.count == 1)
        #expect(repository.deleteCallCount == 1)
    }
    
    @Test func deletingOneRequirementPreservesOthers() throws {
        let first = makeRequirement()
        let second = makeRequirement()

        let repository = MockRequirementRepository(
            requirements: [first, second]
        )
        let useCase = DeleteRequirementUseCase(repository: repository)

        try useCase.execute(id: first.id)

        #expect(repository.requirements.count == 1)
        #expect(repository.requirements.first?.id == second.id)
        #expect(repository.deleteCallCount == 1)
    }
}
