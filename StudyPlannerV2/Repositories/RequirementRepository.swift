//
//  RequirementRepository.swift
//  StudyPlannerV2
//
//  Created by Djy on 15/10/2026.
//

import Foundation

protocol RequirementRepository {

    var requirements: [PlacementRequirement] { get }

    func load() throws -> [PlacementRequirement]
    func add(_ requirement: PlacementRequirement) throws
    func update(_ requirement: PlacementRequirement) throws
    func delete(_ requirement: PlacementRequirement) throws
}
