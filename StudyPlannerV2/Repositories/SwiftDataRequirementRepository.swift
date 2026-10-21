//
//  SwiftDataRequirementRepository.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 17/10/2026.
//

import Foundation
import SwiftData
import Combine



final class SwiftDataRequirementRepository: RequirementRepository {
    private(set) var requirements: [PlacementRequirement] = []
    private(set) var errorMessage: String?

    private let context: ModelContext
    private let changesSubject = PassthroughSubject<Void, Never>()

    var changes: AnyPublisher<Void, Never> {
        changesSubject.eraseToAnyPublisher()
    }

    func reloadAfterPlacementDeletion() {
        requirements = load()
        changesSubject.send()
    }

    init(container: ModelContainer) {
        context = ModelContext(container)
        context.autosaveEnabled = false
        requirements = load()
    }

    func load() -> [PlacementRequirement] {
        do {
            let descriptor = FetchDescriptor<StoredPlacementRequirement>(
                sortBy: [
                    SortDescriptor(\StoredPlacementRequirement.name)
                ]
            )

            let records = try context.fetch(descriptor)
            let loadedRequirements = try records.map {
                try $0.toRequirement()
            }

            requirements = loadedRequirements
            errorMessage = nil
        } catch {
            errorMessage = "Your saved requirements could not be loaded."
        }

        return requirements
    }

    func add(_ requirement: PlacementRequirement) {
        performSave {
            guard try findRequirement(id: requirement.id) == nil else {
                throw RepositoryError.duplicateRequirement
            }

            let placement = try findPlacement(id: requirement.placementID)
            let record = StoredPlacementRequirement(requirement: requirement)
            context.insert(record)
            record.placement = placement
        }
    }

    func update(_ requirement: PlacementRequirement) {
        performSave {
            guard let record = try findRequirement(id: requirement.id) else {
                throw RepositoryError.requirementNotFound
            }

            let placement = try findPlacement(id: requirement.placementID)
            record.placementID = requirement.placementID
            record.placement = placement
            record.name = requirement.name
            record.categoryRawValue = requirement.category.rawValue
            record.dueDate = requirement.dueDate
            record.expiryDate = requirement.expiryDate
            record.isCompleted = requirement.isCompleted
        }
    }

    func delete(_ requirement: PlacementRequirement) {
        performSave {
            guard let record = try findRequirement(id: requirement.id) else {
                throw RepositoryError.requirementNotFound
            }

            context.delete(record)
        }
    }

    private func findPlacement(id: UUID) throws -> StoredPlacement {
        let placementID = id
        var descriptor = FetchDescriptor<StoredPlacement>(
            predicate: #Predicate { $0.id == placementID }
        )
        descriptor.fetchLimit = 1
        guard let placement = try context.fetch(descriptor).first else {
            throw RepositoryError.placementNotFound
        }
        return placement
    }

    private func findRequirement(
        id: UUID
    ) throws -> StoredPlacementRequirement? {
        let requirementID = id

        var descriptor = FetchDescriptor<StoredPlacementRequirement>(
            predicate: #Predicate { record in
                record.id == requirementID
            }
        )

        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    private func performSave(_ operation: () throws -> Void) {
        do {
            try operation()
            try context.save()
        } catch {
            context.rollback()
            errorMessage = "Your changes could not be saved. \(error.localizedDescription)"
            return
        }

        requirements = load()
    }

    private enum RepositoryError: LocalizedError {
        case duplicateRequirement
        case requirementNotFound
        case placementNotFound

        var errorDescription: String? {
            switch self {
            case .duplicateRequirement:
                return "A requirement with this ID already exists."
            case .requirementNotFound:
                return "The requirement could not be found."
            case .placementNotFound:
                return "The placement could not be found. Save the placement before adding requirements."
            }
        }
    }
}
