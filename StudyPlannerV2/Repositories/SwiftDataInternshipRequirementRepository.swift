//
//  SwiftDataInternshipRequirementRepository.swift
//  StudyPlannerV2
//
//  Created by Djy on 28/10/2026.
//

import Foundation
import SwiftData
import Combine

final class SwiftDataInternshipRequirementRepository:
    InternshipRequirementRepository {

    private(set) var requirements: [InternshipRequirement] = []
    private(set) var errorMessage: String?

    private let context: ModelContext
    private let changesSubject = PassthroughSubject<Void, Never>()

    var changes: AnyPublisher<Void, Never> {
        changesSubject.eraseToAnyPublisher()
    }

    init(container: ModelContainer) {
        context = ModelContext(container)
        context.autosaveEnabled = false
    }

    /// Refreshes checklist data after a saved internship is deleted.
    func reloadAfterInternshipDeletion() {
        do {
            _ = try load()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }

        changesSubject.send()
    }

    func load() throws -> [InternshipRequirement] {
        let descriptor = FetchDescriptor<StoredInternshipRequirement>(sortBy: [SortDescriptor(\StoredInternshipRequirement.name)])

        let records = try context.fetch(descriptor)

        let loadedRequirements = try records.map {
            try $0.toRequirement()
        }

        requirements = loadedRequirements
        errorMessage = nil

        return loadedRequirements
    }

    func add(_ requirement: InternshipRequirement) throws {
        try performSave {
            guard try findRequirement(id: requirement.id) == nil else {
                throw RepositoryError.duplicateRequirement
            }

            let internship = try findInternship(id: requirement.internshipID)
            let record = StoredInternshipRequirement(requirement: requirement)

            context.insert(record)
            record.internship = internship
        }
    }

    func update(_ requirement: InternshipRequirement) throws {
        try performSave {
            guard let record = try findRequirement(id: requirement.id) else {
                throw RepositoryError.requirementNotFound
            }

            let internship = try findInternship(id: requirement.internshipID)

            record.internshipID = requirement.internshipID
            record.internship = internship
            record.name = requirement.name
            record.categoryRawValue = requirement.category.rawValue
            record.dueDate = requirement.dueDate
            record.expiryDate = requirement.expiryDate
            record.isCompleted = requirement.isCompleted
        }
    }

    func delete(_ requirement: InternshipRequirement) throws {
        try performSave {
            guard let record = try findRequirement(id: requirement.id) else {
                throw RepositoryError.requirementNotFound
            }

            context.delete(record)
        }
    }

    private func findInternship(id: UUID) throws -> StoredSavedInternship {
        let internshipID = id
        var descriptor = FetchDescriptor<StoredSavedInternship>(predicate: #Predicate { record in
            record.id == internshipID
        }
        )

        descriptor.fetchLimit = 1

        guard let internship = try context.fetch(descriptor).first else {
            throw RepositoryError.internshipNotFound
        }

        return internship
    }

    private func findRequirement(id: UUID) throws -> StoredInternshipRequirement? {
        let requirementID = id
        var descriptor = FetchDescriptor<StoredInternshipRequirement>(predicate: #Predicate { record in
            record.id == requirementID
        }
        )

        descriptor.fetchLimit = 1

        return try context.fetch(descriptor).first
    }

    private func performSave(_ operation: () throws -> Void) throws {
        do {
            try operation()
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    private enum RepositoryError: LocalizedError {
        case duplicateRequirement
        case requirementNotFound
        case internshipNotFound

        var errorDescription: String? {
            switch self {
            case .duplicateRequirement:
                return "A requirement with this ID already exists."

            case .requirementNotFound:
                return "The internship requirement could not be found."

            case .internshipNotFound:
                return "The internship could not be found. Save the internship before adding requirements."
            }
        }
    }
}
