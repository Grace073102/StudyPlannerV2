//
//  AssignmentRepository.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 14/10/2026.
//

import Foundation

protocol AssignmentRepository {
    var assignments: [Assignment] { get }
    var errorMessage: String? { get }
    
    func load() -> [Assignment]
    func add(_ assignment: Assignment) throws
    func update(_ assignment: Assignment) throws
    func delete(_ assignment: Assignment) throws
}

extension AssignmentRepository {
    var errorMessage: String? {
        nil
    }
}
