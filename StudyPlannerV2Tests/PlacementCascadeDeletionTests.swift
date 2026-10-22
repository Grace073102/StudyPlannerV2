//
//  PlacementCascadeDeletionTests.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 19/10/2026.
//

import Foundation
import SwiftData
import Testing
@testable import StudyPlannerV2

@MainActor
struct PlacementCascadeDeletionTests {

    @Test
    func deletingPlacementDeletesOnlyItsRequirements() throws {
        let schema = Schema([
            StoredPlacement.self,
            StoredPlacementRequirement.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        let container = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )

        let context = ModelContext(container)
        context.autosaveEnabled = false

        let placement = makePlacement(name: "Hospital placement")
        let otherPlacement = makePlacement(name: "School placement")

        context.insert(placement)
        context.insert(otherPlacement)

        let requirement = StoredPlacementRequirement(
            placementID: placement.id,
            name: "Police check",
            category: .checksAndClearances
        )

        let otherRequirement = StoredPlacementRequirement(
            placementID: otherPlacement.id,
            name: "Training",
            category: .trainingAndCertificates
        )

        context.insert(requirement)
        context.insert(otherRequirement)

        requirement.placement = placement
        otherRequirement.placement = otherPlacement

        try context.save()

        let deletedPlacementID = placement.id
        let deletedRequirementID = requirement.id
        let remainingPlacementID = otherPlacement.id
        let remainingRequirementID = otherRequirement.id

        let repository = SwiftDataPlacementRepository(
            container: container
        )

        try repository.delete(placement)

        // Read through a fresh context to verify saved database state.
        let verificationContext = ModelContext(container)

        let placements = try verificationContext.fetch(
            FetchDescriptor<StoredPlacement>()
        )

        let requirements = try verificationContext.fetch(
            FetchDescriptor<StoredPlacementRequirement>()
        )

        #expect(!placements.contains {
            $0.id == deletedPlacementID
        })
        #expect(!requirements.contains {
            $0.id == deletedRequirementID
        })

        #expect(placements.map(\.id) == [remainingPlacementID])
        #expect(requirements.map(\.id) == [remainingRequirementID])
        #expect(requirements.first?.placement?.id == remainingPlacementID)
    }

    private func makePlacement(name: String) -> Placement {
        Placement(
            name: name,
            startDate: .now,
            endDate: .now
        )
    }
    @Test
    func deletionPreservesRequirementLinkedToAnotherPlacement() throws {
        let schema = Schema([
            StoredPlacement.self,
            StoredPlacementRequirement.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        let container = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )

        let context = ModelContext(container)
        context.autosaveEnabled = false

        let deletedPlacement = makePlacement(name: "Old placement")
        let actualPlacement = makePlacement(name: "Actual placement")

        context.insert(deletedPlacement)
        context.insert(actualPlacement)

        // The legacy ID is outdated; the relationship is correct.
        let requirement = StoredPlacementRequirement(
            placementID: deletedPlacement.id,
            name: "Police check",
            category: .checksAndClearances
        )

        context.insert(requirement)
        requirement.placement = actualPlacement
        try context.save()

        let requirementID = requirement.id
        let actualPlacementID = actualPlacement.id

        let repository = SwiftDataPlacementRepository(
            container: container
        )

        try repository.delete(deletedPlacement)

        let verificationContext = ModelContext(container)
        let remainingRequirements = try verificationContext.fetch(
            FetchDescriptor<StoredPlacementRequirement>()
        )

        #expect(remainingRequirements.map(\.id) == [requirementID])
        #expect(
            remainingRequirements.first?.placement?.id == actualPlacementID
        )
    }
    @Test
    func legacyRequirementIsLinkedBeforeCascadeDeletion() throws {
        let schema = Schema([StoredPlacement.self, StoredPlacementRequirement.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = ModelContext(container)
        context.autosaveEnabled = false
        let placement = makePlacement(name: "Legacy placement")
        let requirement = StoredPlacementRequirement(
            placementID: placement.id,
            name: "Police check",
            category: .checksAndClearances
        )
        context.insert(placement)
        context.insert(requirement)
        try context.save()
        let repository = SwiftDataPlacementRepository(container: container)
        try repository.delete(placement)
        let verificationContext = ModelContext(container)
        let requirements = try verificationContext.fetch(FetchDescriptor<StoredPlacementRequirement>())
        #expect(requirements.isEmpty)
    }
}
