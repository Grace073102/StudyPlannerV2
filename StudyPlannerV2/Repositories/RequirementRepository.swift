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

    func load() -> [PlacementRequirement]
    func add(_ requirement: PlacementRequirement)
    func update(_ requirement: PlacementRequirement)
    func delete(_ requirement: PlacementRequirement)
}

extension RequirementRepository {
    var changes: AnyPublisher<Void, Never> {
        Empty().eraseToAnyPublisher()
    }

    var errorMessage: String? {
        nil
    }
}
