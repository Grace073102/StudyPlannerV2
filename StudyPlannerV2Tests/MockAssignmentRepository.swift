//
//  MockAssignmentRepository.swift
//  StudyPlannerV2
//
//  Created by Pichaya Viwatassawin on 17/10/2026.
//


import Foundation
@testable import StudyPlannerV2

struct MockSaveError: Error, Equatable {}
@MainActor
final class MockAssignmentRepository: AssignmentRepository {

    private(set) var assignments: [Assignment]
    private(set) var updateCallCount = 0
    var shouldFailOnSave = false

    init(assignments: [Assignment] = []) {
        self.assignments = assignments
    }

    func load() -> [Assignment] {
        assignments
    }

    func add(_ assignment: Assignment) throws {
        if shouldFailOnSave { throw MockSaveError() }
        assignments.append(assignment)
    }

    func update(_ assignment: Assignment) throws {
        updateCallCount += 1
        if shouldFailOnSave { throw MockSaveError() }

        if let index = assignments.firstIndex(where: { $0.id == assignment.id }) {
            assignments[index] = assignment
        }
    }

    func delete(_ assignment: Assignment) throws {
        if shouldFailOnSave { throw MockSaveError() }
        assignments.removeAll { $0.id == assignment.id }
    }
}
