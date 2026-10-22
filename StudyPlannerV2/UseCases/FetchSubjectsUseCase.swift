//
//  FetchSubjectsUseCase.swift
//  StudyPlannerV2
//
//  Created by emily zhang on 22/10/2026.
//

import Foundation

/// Provides the subjects a placement can be linked to.
struct FetchSubjectsUseCase {
    let repository: SubjectRepository
    
    /// Returns all subjects, sorted by name.
    func execute() throws -> [Subject] {
        let subjects = repository.load()
        if let errorMessage = repository.errorMessage {
            throw FetchSubjectsError.loadFailed(errorMessage)
        }
        return subjects.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}

enum FetchSubjectsError: LocalizedError {
    case loadFailed(String)
    var errorDescription: String? {
        switch self {
        case .loadFailed(let message):
            return message
        }
    }
}
