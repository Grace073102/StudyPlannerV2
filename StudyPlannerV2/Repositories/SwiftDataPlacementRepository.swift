//
//  SwiftDataPlacementRepository.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 17/10/2026.
//

import Foundation
import SwiftData

final class SwiftDataPlacementRepository: PlacementRepository {
    private let context: ModelContext
    private let cancelRequirementNotifications: (UUID) -> Void
    private let onRequirementsChanged: () -> Void

    init(
        container: ModelContainer,
        cancelRequirementNotifications: @escaping (UUID) -> Void = {
            RequirementNotificationManager.shared.cancelNotifications(for: $0)
        },
        onRequirementsChanged: @escaping () -> Void = {}
    ) {
        context = ModelContext(container)
        context.autosaveEnabled = false
        self.cancelRequirementNotifications = cancelRequirementNotifications
        self.onRequirementsChanged = onRequirementsChanged
    }

    func linkExistingRequirements() throws {
        do {
            let placements = try context.fetch(FetchDescriptor<StoredPlacement>())
            let placementsByID = Dictionary(uniqueKeysWithValues: placements.map { ($0.id, $0) })
            let requirements = try context.fetch(FetchDescriptor<StoredPlacementRequirement>())
            for requirement in requirements {
                if let placement = placementsByID[requirement.placementID],
                   requirement.placement?.id != placement.id {
                    requirement.placement = placement
                }
            }
            if context.hasChanges {
                try context.save()
            }
        } catch {
            context.rollback()
            throw PlacementRepositoryError.saveFailed
        }
    }

    func load() throws -> [Placement] {
        do {
            let descriptor = FetchDescriptor<StoredPlacement>(
                sortBy: [SortDescriptor(\StoredPlacement.startDate)]
            )

            return try context.fetch(descriptor).map {
                $0.toPlacement()
            }
        } catch {
            throw PlacementRepositoryError.loadFailed
        }
    }

    func add(_ placement: Placement) throws {
        try saveChanges {
            guard try findPlacement(id: placement.id) == nil else {
                throw PlacementRepositoryError.saveFailed
            }

            context.insert(StoredPlacement(placement: placement))
        }
    }

    func update(_ placement: Placement) throws {
        try saveChanges {
            guard let record = try findPlacement(id: placement.id) else {
                throw PlacementRepositoryError.notFound
            }

            record.name = placement.name
            record.discipline = placement.discipline
            record.startDate = placement.startDate
            record.endDate = placement.endDate
            record.placementDescription = placement.description
            record.subjectID = placement.subjectID
        }
    }

    func delete(_ placement: Placement) throws {
        var requirementIDs: [UUID] = []
        try saveChanges {
            guard let record = try findPlacement(id: placement.id) else {
                throw PlacementRepositoryError.notFound
            }

            let placementID = placement.id
            let descriptor = FetchDescriptor<StoredPlacementRequirement>(
                predicate: #Predicate { $0.placementID == placementID }
            )
            let requirements = try context.fetch(descriptor)
            for requirement in requirements {
                requirement.placement = record
            }
            requirementIDs = Array(Set((record.requirements + requirements).map(\.id)))
            context.delete(record)
        }
        for requirementID in requirementIDs {
            cancelRequirementNotifications(requirementID)
        }
        onRequirementsChanged()
    }

    private func findPlacement(
        id: UUID
    ) throws -> StoredPlacement? {
        let placementID = id

        var descriptor = FetchDescriptor<StoredPlacement>(
            predicate: #Predicate { record in
                record.id == placementID
            }
        )

        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    private func saveChanges(
        _ operation: () throws -> Void
    ) throws {
        do {
            try operation()
            try context.save()
        } catch {
            context.rollback()

            if let repositoryError = error as? PlacementRepositoryError {
                throw repositoryError
            }

            throw PlacementRepositoryError.saveFailed
        }
    }
}
