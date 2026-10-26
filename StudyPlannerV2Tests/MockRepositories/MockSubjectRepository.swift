//
//  MockSubjectRepository.swift
//  StudyPlannerV2
//
//  Created by emily zhang on 26/10/2026.
//

import Foundation
@testable import StudyPlannerV2

/// An in-memory `SubjectRepository` for unit tests.

@MainActor
final class MockSubjectRepository: SubjectRepository {

    private var stored: [Subject] = []
    
    /// The message from the last failed operation, or nil if it succeeded.
    var errorMessage: String?
    var shouldFailOnLoad = false
    var subjects: [Subject] {
        stored.map { copyOf($0) }
    }
    
    /// Creates a repository that starts with copies of the given subjects.
    init(subjects: [Subject] = []) {
        stored = subjects.map {
            Subject(id: $0.id, name: $0.name, code: $0.code)
        }
    }
    
    /// Returns copies of all stored subjects.
    func load() -> [Subject] {
        if shouldFailOnLoad {
            errorMessage = "Failed to load subjects."
            return []
        }
        errorMessage = nil
        return subjects
    }
    
    /// Stores a copy of the subject.
    func add(_ subject: Subject) {
        stored.append(copyOf(subject))
    }

    /// Replaces the stored subject that has the same ID.
    func update(_ subject: Subject) {
        guard let index = stored.firstIndex(where: {
            $0.id == subject.id
        }) else {
            return
        }
        stored[index] = copyOf(subject)
    }

    /// Removes the stored subject that has the same ID.
    func delete(_ subject: Subject) {
        stored.removeAll { $0.id == subject.id }
    }

    /// Makes a new `Subject` with the same values.
    private func copyOf(_ subject: Subject) -> Subject {
        Subject(
            id: subject.id,
            name: subject.name,
            code: subject.code
        )
    }
}
