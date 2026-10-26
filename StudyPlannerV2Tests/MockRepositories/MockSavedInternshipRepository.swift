//
//  MockSavedInternshipRepository.swift
//  StudyPlannerV2
//
//  Created by emily zhang on 18/10/2026.
//

import Foundation
@testable import StudyPlannerV2

/// In-memory saved internship data for unit tests. Like the real repository, it stores and returns copies, so changing an object a test got back never changes what is stored unless the change is saved.
@MainActor
final class MockSavedInternshipRepository: SavedInternshipRepository {

    private var stored: [SavedInternship] = []

    /// Set to true to make load() fail.
    var shouldFailOnLoad = false
    /// Set to true to make add, update and delete fail.
    var shouldFailOnSave = false

    /// What is currently stored (copies), so tests can check it.
    var internships: [SavedInternship] {
        var result: [SavedInternship] = []
        for internship in stored {
            result.append(copyOf(internship))
        }
        return result
    }

    init(internships: [SavedInternship] = []) {
        for internship in internships {
            stored.append(copyOf(internship))
        }
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
        for existing in stored {
            if existing.id == internship.id {
                throw SavedInternshipRepositoryError.saveFailed
            }
        }
        stored.append(copyOf(internship))
    }

    func update(_ internship: SavedInternship) throws {
        if shouldFailOnSave {
            throw SavedInternshipRepositoryError.saveFailed
        }
        guard let index = stored.firstIndex(where: { $0.id == internship.id }) else {
            throw SavedInternshipRepositoryError.notFound
        }
        stored[index] = copyOf(internship)
    }

    func delete(_ internship: SavedInternship) throws {
        if shouldFailOnSave {
            throw SavedInternshipRepositoryError.saveFailed
        }
        guard let index = stored.firstIndex(where: { $0.id == internship.id }) else {
            throw SavedInternshipRepositoryError.notFound
        }
        stored.remove(at: index)
    }

    /// Makes a new SavedInternship with the same values.
    private func copyOf(_ internship: SavedInternship) -> SavedInternship {
        return SavedInternship(
            id: internship.id,
            jobID: internship.jobID,
            title: internship.title,
            company: internship.company,
            location: internship.location,
            applicationURL: internship.applicationURL,
            companyWebsiteURL: internship.companyWebsiteURL,
            applicationDeadline: internship.applicationDeadline,
            savedDate: internship.savedDate,
            applicationStatus: internship.applicationStatus
        )
    }
}
