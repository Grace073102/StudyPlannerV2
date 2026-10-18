//
//  MockPlacementRepository.swift
//  StudyPlannerV2
//
//  Created by emily zhang on 18/10/2026.
//

import Foundation
@testable import StudyPlannerV2

/// In-memory placement data for unit tests. Changes stay in memory, so tests never affect each other.
@MainActor
final class MockPlacementRepository: PlacementRepository {

    private(set) var placements: [Placement]

    /// Set to true to make load() fail.
    var shouldFailOnLoad = false
    /// Set to true to make add, update and delete fail.
    var shouldFailOnSave = false

    init(placements: [Placement] = []) {
        self.placements = placements
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
        placements.append(placement)
    }

    func update(_ placement: Placement) throws {
        if shouldFailOnSave {
            throw PlacementRepositoryError.saveFailed
        }
        guard let index = placements.firstIndex(where: { $0.id == placement.id }) else {
            throw PlacementRepositoryError.notFound
        }
        placements[index] = placement
    }

    func delete(_ placement: Placement) throws {
        if shouldFailOnSave {
            throw PlacementRepositoryError.saveFailed
        }
        guard let index = placements.firstIndex(where: { $0.id == placement.id }) else {
            throw PlacementRepositoryError.notFound
        }
        placements.remove(at: index)
    }
}
