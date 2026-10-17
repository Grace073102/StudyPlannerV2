//
//  SavedInternshipRepository.swift
//  StudyPlannerV2
//
//  Created by emily zhang on 17/10/2026.
//

import Foundation

protocol SavedInternshipRepository {
    func load() throws -> [SavedInternship]
    func add(_ internship: SavedInternship) throws
    func update(_ internship: SavedInternship) throws
    func delete(_ internship: SavedInternship) throws
}

enum SavedInternshipRepositoryError: LocalizedError, Equatable {
    case notFound
    case loadFailed
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .notFound:   "That saved internship could not be found."
        case .loadFailed: "Your saved internships could not be loaded. Please restart the app and try again."
        case .saveFailed: "Your changes could not be saved. Please try again."
        }
    }
}
