 //
//  PlacementRepository.swift
//  StudyPlannerV2
//
//  Created by emily zhang on 17/10/2026.
//

import Foundation

protocol PlacementRepository {
    func load() throws -> [Placement]
    func add(_ placement: Placement) throws
    func update(_ placement: Placement) throws
    func delete(_ placement: Placement) throws
}

enum PlacementRepositoryError: LocalizedError, Equatable {
    case notFound
    case loadFailed
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .notFound:   "That placement could not be found."
        case .loadFailed: "Your placements could not be loaded. Please restart the app and try again."
        case .saveFailed: "Your changes could not be saved. Please try again."
        }
    }
}
