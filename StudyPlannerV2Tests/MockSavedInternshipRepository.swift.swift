//
//  MockSavedInternshipRepository.swift.swift
//  StudyPlannerV2
//
//  Created by emily zhang on 18/10/2026.
//

import Foundation
@testable import StudyPlannerV2

/// In-memory saved internship data for unit tests. Changes stay in memory, so tests never affect each other.
@MainActor
final class MockSavedInternshipRepository: SavedInternshipRepository {

    private(set) var internships: [SavedInternship]

    /// Set to true to make load() fail.
    var shouldFailOnLoad = false
    /// Set to true to make add, update and delete fail.
    var shouldFailOnSave = false

    init(internships: [SavedInternship] = []) {
        self.internships = internships
    }

    func load() throws -> [SavedInternship] {
        if shouldFailOnLoad {
            throw SavedInternshipRepositoryError.loadFailed
        }
        return internships
    }

    func add(_ internship: SavedInternship) throws {
        if shouldFailOnSave {
            throw SavedInternshipRepositoryError.saveFailed
        }
        internships.append(internship)
    }

    func update(_ internship: SavedInternship) throws {
        if shouldFailOnSave {
            throw SavedInternshipRepositoryError.saveFailed
        }
        guard let index = internships.firstIndex(where: { $0.id == internship.id }) else {
            throw SavedInternshipRepositoryError.notFound
        }
        internships[index] = internship
    }

    func delete(_ internship: SavedInternship) throws {
        if shouldFailOnSave {
            throw SavedInternshipRepositoryError.saveFailed
        }
        guard let index = internships.firstIndex(where: { $0.id == internship.id }) else {
            throw SavedInternshipRepositoryError.notFound
        }
        internships.remove(at: index)
    }
}
