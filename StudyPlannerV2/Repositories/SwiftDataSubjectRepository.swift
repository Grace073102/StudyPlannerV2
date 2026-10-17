//
//  SwiftDataSubjectRepository.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 17/10/2026.
//

import Foundation
import SwiftData

final class SwiftDataSubjectRepository: SubjectRepository {
    private(set) var subjects: [Subject] = []
    private(set) var errorMessage: String?

    private let context: ModelContext

    init(container: ModelContainer) {
        context = ModelContext(container)
        context.autosaveEnabled = false
        subjects = load()
    }

    func load() -> [Subject] {
        do {
            let descriptor = FetchDescriptor<StoredSubject>(
                sortBy: [SortDescriptor(\StoredSubject.name)]
            )

            let records = try context.fetch(descriptor)
            subjects = records.map { $0.toSubject() }
            errorMessage = nil
        } catch {
            errorMessage = "Your saved subjects could not be loaded."
        }

        return subjects
    }

    func add(_ subject: Subject) {
        performSave {
            guard try findSubject(id: subject.id) == nil else {
                throw RepositoryError.duplicateSubject
            }

            context.insert(StoredSubject(subject: subject))
        }
    }

    func update(_ subject: Subject) {
        performSave {
            guard let record = try findSubject(id: subject.id) else {
                throw RepositoryError.subjectNotFound
            }

            record.name = subject.name
            record.code = subject.code
        }
    }

    func delete(_ subject: Subject) {
        performSave {
            guard let record = try findSubject(id: subject.id) else {
                throw RepositoryError.subjectNotFound
            }

            context.delete(record)
        }
    }

    private func findSubject(id: UUID) throws -> StoredSubject? {
        let subjectID = id

        var descriptor = FetchDescriptor<StoredSubject>(
            predicate: #Predicate { record in
                record.id == subjectID
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

        subjects = load()
    }

    private enum RepositoryError: LocalizedError {
        case duplicateSubject
        case subjectNotFound

        var errorDescription: String? {
            switch self {
            case .duplicateSubject:
                return "A subject with this ID already exists."
            case .subjectNotFound:
                return "The subject could not be found."
            }
        }
    }
}
