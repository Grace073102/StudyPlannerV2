//
//  RequirementRepository.swift
//  StudyPlannerV2
//
//  Created by Djy on 15/10/2026.
//

import Foundation
import Combine

protocol RequirementRepository {

    var requirements: [PlacementRequirement] { get }
    var errorMessage: String? { get }
    var changes: AnyPublisher<Void, Never> { get }

    func load() throws -> [PlacementRequirement]
    func add(_ requirement: PlacementRequirement) throws
    func update(_ requirement: PlacementRequirement) throws
    func delete(_ requirement: PlacementRequirement) throws
}

extension RequirementRepository {

    var changes: AnyPublisher<Void, Never> {
        Empty().eraseToAnyPublisher()
    }

    var errorMessage: String? {
        nil
    }
}
