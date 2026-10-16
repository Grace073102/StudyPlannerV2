//
//  RequirementRepository.swift
//  StudyPlannerV2
//
//  Created by Djy on 15/10/2026.
//

import Foundation

protocol RequirementRepository {
    
    var requirements: [PlacementRequirement] { get }

    func load() -> [PlacementRequirement]
    func add(_ requirement: PlacementRequirement)
    func update(_ requirement: PlacementRequirement)
    func delete(_ requirement: PlacementRequirement)
}

extension RequirementRepository {
    var errorMessage: String? {
        nil
    }
}
