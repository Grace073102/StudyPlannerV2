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

    init(container: ModelContainer) {
        context = ModelContext(container)
        context.autosaveEnabled = false
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
        try saveChanges {
            guard let record = try findPlacement(id: placement.id) else {
                throw PlacementRepositoryError.notFound
            }

            context.delete(record)
        }
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
