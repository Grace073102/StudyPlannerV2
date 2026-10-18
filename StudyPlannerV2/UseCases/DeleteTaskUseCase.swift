//
//  DeleteTaskUseCase.swift
//  StudyPlannerV2
//
//  Created by Pichaya Viwatassawin on 17/10/2026.
//


import Foundation
/// Removes a subtask from its assignment
///
/// Business rules:
/// 1. Only an exisitng subtask can be deleted.
struct DeleteTaskUseCase {

    let repository: AssignmentRepository

    enum DeleteTaskError: LocalizedError, Equatable {
        case taskNotFound

        var errorDescription: String? {
            "This subtask could not be found. It may have already been deleted."
        }
    }

    func execute(taskID: String) throws {
        for assignment in repository.assignments {
            let updatedAssignment = assignment.copy()
            
            guard let taskIndex = updatedAssignment.tasks.firstIndex(
                where: { $0.id == taskID }
            ) else {
                continue
            }

            updatedAssignment.tasks.remove(at: taskIndex)
            try repository.update(updatedAssignment)
            return
        }

        throw DeleteTaskError.taskNotFound
    }
}
