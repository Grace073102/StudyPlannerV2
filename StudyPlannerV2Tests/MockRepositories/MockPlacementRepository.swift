//
//  MockPlacementRepository.swift
//  StudyPlannerV2
//
//  Created by emily zhang on 18/10/2026.
//

import Foundation
@testable import StudyPlannerV2

/// In-memory placement data for unit tests. Like the real repository, it stores and returns copies, so changing an object a test got back never changes what is stored unless the change is saved.
@MainActor
final class MockPlacementRepository: PlacementRepository {

    private var stored: [Placement] = []

    /// Set to true to make load() fail.
    var shouldFailOnLoad = false
    /// Set to true to make add, update and delete fail.
    var shouldFailOnSave = false

    /// What is currently stored (copies), so tests can check it.
    var placements: [Placement] {
        var result: [Placement] = []
        for placement in stored {
            result.append(copyOf(placement))
        }
        return result
    }

    init(placements: [Placement] = []) {
        for placement in placements {
            stored.append(copyOf(placement))
        }
    }

    func load() throws -> [Placement] {
        if shouldFailOnLoad {
            throw PlacementRepositoryError.loadFailed
        }
        return placements
    }

    func add(_ placement: Placement) throws {
        if shouldFailOnSave {
            throw PlacementRepositoryError.saveFailed
        }
        for existing in stored {
            if existing.id == placement.id {
                throw PlacementRepositoryError.saveFailed
            }
        }
        stored.append(copyOf(placement))
    }

    func update(_ placement: Placement) throws {
        if shouldFailOnSave {
            throw PlacementRepositoryError.saveFailed
        }
        guard let index = stored.firstIndex(where: { $0.id == placement.id }) else {
            throw PlacementRepositoryError.notFound
        }
        stored[index] = copyOf(placement)
    }

    func delete(_ placement: Placement) throws {
        if shouldFailOnSave {
            throw PlacementRepositoryError.saveFailed
        }
        guard let index = stored.firstIndex(where: { $0.id == placement.id }) else {
            throw PlacementRepositoryError.notFound
        }
        stored.remove(at: index)
    }

    /// Makes a new Placement with the same values.
    private func copyOf(_ placement: Placement) -> Placement {
        return Placement(
            id: placement.id,
            name: placement.name,
            startDate: placement.startDate,
            endDate: placement.endDate,
            description: placement.description ?? "",
            subjectID: placement.subjectID
        )
    }
}
