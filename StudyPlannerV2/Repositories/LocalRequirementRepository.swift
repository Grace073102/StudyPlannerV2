//
//  LocalRequirementRepository.swift
//  StudyPlannerV2
//
//  Created by Djy on 15/10/2026.
//

import Foundation

final class LocalRequirementRepository: RequirementRepository {

    private(set) var requirements: [PlacementRequirement] = []

    init(requirements: [PlacementRequirement] = []) {
        self.requirements = requirements
    }

    func load() -> [PlacementRequirement] {
        requirements
    }

    func add(_ requirement: PlacementRequirement) {
        requirements.append(requirement)
    }

    func update(_ requirement: PlacementRequirement) {
        guard let index = requirements.firstIndex(
            where: { $0.id == requirement.id }
        ) else {
            return
        }

        requirements[index] = requirement
    }

    func delete(_ requirement: PlacementRequirement) {
        requirements.removeAll {
            $0.id == requirement.id
        }
    }
}

