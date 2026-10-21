//
//  MockRequirementRepository.swift
//  StudyPlannerV2Tests
//
//  Created by Djy on 20/10/2026.
//

import Foundation
@testable import StudyPlannerV2

enum MockRequirementRepositoryError: Error {
    case simulatedFailure
}

final class MockRequirementRepository: RequirementRepository {

    private(set) var requirements: [PlacementRequirement]

    var shouldFailOnLoad = false
    var shouldFailOnAdd = false
    var shouldFailOnUpdate = false
    var shouldFailOnDelete = false

    private(set) var loadCallCount = 0
    private(set) var addCallCount = 0
    private(set) var updateCallCount = 0
    private(set) var deleteCallCount = 0

    init(requirements: [PlacementRequirement] = []) {
        self.requirements = requirements
    }

    func load() throws -> [PlacementRequirement] {
        loadCallCount += 1

        if shouldFailOnLoad {
            throw MockRequirementRepositoryError.simulatedFailure
        }

        return requirements
    }

    func add(_ requirement: PlacementRequirement) throws {
        addCallCount += 1

        if shouldFailOnAdd {
            throw MockRequirementRepositoryError.simulatedFailure
        }

        requirements.append(requirement.copy())
    }

    func update(_ requirement: PlacementRequirement) throws {
        updateCallCount += 1

        if shouldFailOnUpdate {
            throw MockRequirementRepositoryError.simulatedFailure
        }

        guard let index = requirements.firstIndex(where: {
            $0.id == requirement.id
        }) else {
            throw RequirementValidationError.notFound
        }

        requirements[index] = requirement.copy()
    }

    func delete(_ requirement: PlacementRequirement) throws {
        deleteCallCount += 1

        if shouldFailOnDelete {
            throw MockRequirementRepositoryError.simulatedFailure
        }

        guard let index = requirements.firstIndex(where: {
            $0.id == requirement.id
        }) else {
            throw RequirementValidationError.notFound
        }

        requirements.remove(at: index)
    }
}
