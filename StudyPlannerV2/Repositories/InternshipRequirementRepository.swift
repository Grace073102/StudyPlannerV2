//
//  InternshipRequirementRepository.swift
//  StudyPlannerV2
//
//  Created by Djy on 28/10/2026.
//

import Foundation
import Combine

protocol InternshipRequirementRepository {

    var requirements: [InternshipRequirement] { get }

    var errorMessage: String? { get }

    var changes: AnyPublisher<Void, Never> { get }

    func load() throws -> [InternshipRequirement]

    func add(_ requirement: InternshipRequirement) throws

    func update(_ requirement: InternshipRequirement) throws

    func delete(_ requirement: InternshipRequirement) throws
}

extension InternshipRequirementRepository {

    var changes: AnyPublisher<Void, Never> {
        Empty<Void, Never>().eraseToAnyPublisher()
    }

    var errorMessage: String? {
        nil
    }
}
