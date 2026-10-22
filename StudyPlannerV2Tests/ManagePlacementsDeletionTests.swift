//
//  ManagePlacementsDeletionTests.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 19/10/2026.
//

import Foundation
import Testing
@testable import StudyPlannerV2

@MainActor
struct ManagePlacementsDeletionTests {

    @Test
    func successfulDeletionCancelsRemindersAfterDeleting() throws {
        let placement = makePlacement()
        let repository = MockPlacementRepository(
            placements: [placement]
        )
        let requirementIDs = [UUID(), UUID()]
        var cancelledIDs: [UUID] = []

        let useCase = ManagePlacementsUseCase(
            repository: repository,
            loadRequirementIDs: { placementID in
                #expect(placementID == placement.id)

                // Requirements must be collected before deletion.
                #expect(repository.placements.count == 1)
                return requirementIDs
            },
            cancelRequirementNotifications: { requirementID in
                // Cancellation must happen after deletion.
                #expect(repository.placements.isEmpty)
                cancelledIDs.append(requirementID)
            }
        )

        try useCase.delete(id: placement.id)

        #expect(repository.placements.isEmpty)
        #expect(cancelledIDs == requirementIDs)
    }

    @Test
    func failedDeletionDoesNotCancelReminders() {
        let placement = makePlacement()
        let repository = MockPlacementRepository(
            placements: [placement]
        )
        repository.shouldFailOnSave = true

        var cancelledIDs: [UUID] = []

        let useCase = ManagePlacementsUseCase(
            repository: repository,
            loadRequirementIDs: { _ in [UUID()] },
            cancelRequirementNotifications: {
                cancelledIDs.append($0)
            }
        )

        #expect(throws: PlacementRepositoryError.saveFailed) {
            try useCase.delete(id: placement.id)
        }

        #expect(repository.placements.map(\.id) == [placement.id])
        #expect(cancelledIDs.isEmpty)
    }

    @Test
    func failedRequirementLoadPreventsDeletionAndCancellation() {
        let placement = makePlacement()
        let repository = MockPlacementRepository(
            placements: [placement]
        )

        var cancelledIDs: [UUID] = []

        let useCase = ManagePlacementsUseCase(
            repository: repository,
            loadRequirementIDs: { _ in
                throw PlacementRepositoryError.loadFailed
            },
            cancelRequirementNotifications: {
                cancelledIDs.append($0)
            }
        )

        #expect(throws: PlacementRepositoryError.loadFailed) {
            try useCase.delete(id: placement.id)
        }

        #expect(repository.placements.map(\.id) == [placement.id])
        #expect(cancelledIDs.isEmpty)
    }

    private func makePlacement() -> Placement {
        Placement(
            name: "Hospital placement",
            startDate: .now,
            endDate: .now
        )
    }
}
