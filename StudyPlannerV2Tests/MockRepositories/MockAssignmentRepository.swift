//
//  MockAssignmentRepository.swift
//  StudyPlannerV2
//
//  Created by Pichaya Viwatassawin on 17/10/2026.
//


import Foundation
@testable import StudyPlannerV2

struct MockSaveError: Error, Equatable {}
struct MockNotFoundError: Error, Equatable {}

@MainActor
final class MockAssignmentRepository: AssignmentRepository {

    private var stored: [Assignment] = []
    private(set) var updateCallCount = 0
    var shouldFailOnSave = false

    var assignments: [Assignment] {
        var result: [Assignment] = []
        for assignment in stored {
            result.append(assignment.copy())
        }
        return result
    }
    
    init(assignments: [Assignment] = []) {
        for assignment in assignments {
            stored.append(assignment.copy())
        }
    }

    func load() -> [Assignment] {
        assignments
    }

    func add(_ assignment: Assignment) throws {
        if shouldFailOnSave { throw MockSaveError() }
        stored.append(assignment.copy())
    }

    func update(_ assignment: Assignment) throws {
        updateCallCount += 1
        if shouldFailOnSave { throw MockSaveError() }

        guard let index = stored.firstIndex(where: { $0.id == assignment.id }) else {
            throw MockNotFoundError()
        }
        
        stored[index] = assignment.copy()
    }

    func delete(_ assignment: Assignment) throws {
        if shouldFailOnSave { throw MockSaveError() }
        
        guard let index = stored.firstIndex(where: { $0.id == assignment.id }) else {
            throw MockNotFoundError()
        }
        
        stored.remove(at: index)
    }
}
