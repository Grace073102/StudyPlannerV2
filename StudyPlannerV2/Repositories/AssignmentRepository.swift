//
//  AssignmentRepository.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 14/10/2026.
//

import Foundation

protocol AssignmentRepository {
    var assignments: [Assignment] { get }
    func load() -> [Assignment]
    func add(_ assignment: Assignment)
    func update(_ assignment: Assignment)
    func delete(_ assignment: Assignment)
}

extension AssignmentRepository {
    var errorMessage: String? {
        nil
    }
}
