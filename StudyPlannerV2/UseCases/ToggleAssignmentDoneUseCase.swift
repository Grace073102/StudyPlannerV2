//
//  ToggleAssignmentDoneUseCase.swift
//  StudyPlannerV2
//
//  Created by Pichaya Viwatassawin on 29/10/2026.
//


import Foundation

/// Marks an assignment as done or not done
///
/// Business rules:
/// 1. Only an existing assignment can be marked
struct ToggleAssignmentDoneUseCase {

    let repository: AssignmentRepository

    enum ToggleAssignmentDoneError: LocalizedError, Equatable {
        case assignmentNotFound

        var errorDescription: String? {
            "This assignment could not be found. It may have been deleted."
        }
    }

    func execute(assignmentID: String) throws {
        guard let existingAssignment = repository.assignments.first(
            where: { $0.id == assignmentID }
        ) else {
            throw ToggleAssignmentDoneError.assignmentNotFound
        }

        let updatedAssignment = existingAssignment.copy()
        updatedAssignment.isMarkedDone.toggle()
        try repository.update(updatedAssignment)
    }
}
