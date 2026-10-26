//
//  SwiftDataSavedInternshipRepository.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 17/10/2026.
//

import Foundation
import SwiftData

final class SwiftDataSavedInternshipRepository:
    SavedInternshipRepository {
    private let context: ModelContext

    init(container: ModelContainer) {
        context = ModelContext(container)
        context.autosaveEnabled = false
    }

    func load() throws -> [SavedInternship] {
        do {
            let descriptor = FetchDescriptor<StoredSavedInternship>(
                sortBy: [
                    SortDescriptor(
                        \StoredSavedInternship.savedDate,
                        order: .reverse
                    )
                ]
            )

            return try context.fetch(descriptor).map {
                try $0.toSavedInternship()
            }
        } catch {
            throw SavedInternshipRepositoryError.loadFailed
        }
    }

    func add(_ internship: SavedInternship) throws {
        try saveChanges {
            guard try findInternship(id: internship.id) == nil else {
                throw SavedInternshipRepositoryError.saveFailed
            }

            context.insert(
                StoredSavedInternship(internship: internship)
            )
        }
    }

    func update(_ internship: SavedInternship) throws {
        try saveChanges {
            guard let record = try findInternship(
                id: internship.id
            ) else {
                throw SavedInternshipRepositoryError.notFound
            }

            record.jobID = internship.jobID
            record.title = internship.title
            record.company = internship.company
            record.location = internship.location
            record.applicationURL = internship.applicationURL
            record.companyWebsiteURL = internship.companyWebsiteURL
            record.applicationDeadline = internship.applicationDeadline
            record.savedDate = internship.savedDate
            record.applicationStatusRawValue =
                internship.applicationStatus.rawValue
        }
    }

    func delete(_ internship: SavedInternship) throws {
        try saveChanges {
            guard let record = try findInternship(
                id: internship.id
            ) else {
                throw SavedInternshipRepositoryError.notFound
            }

            context.delete(record)
        }
    }

    private func findInternship(
        id: UUID
    ) throws -> StoredSavedInternship? {
        let internshipID = id

        var descriptor = FetchDescriptor<StoredSavedInternship>(
            predicate: #Predicate { record in
                record.id == internshipID
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

            if let repositoryError =
                error as? SavedInternshipRepositoryError {
                throw repositoryError
            }

            throw SavedInternshipRepositoryError.saveFailed
        }
    }
}
