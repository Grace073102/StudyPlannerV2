//
//  ToggleTaskUseCase.swift
//  StudyPlannerV2
//
//  Created by Pichaya Viwatassawin on 17/10/2026.
//


import Foundation

struct ToggleTaskUseCase {

    let repository: AssignmentRepository

    enum ToggleTaskError: LocalizedError, Equatable {
        case taskNotFound

        var errorDescription: String? {
            "This subtask could not be found. It may have been deleted."
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

            updatedAssignment.tasks[taskIndex].isCompleted.toggle()
            repository.update(updatedAssignment)
            return
        }

        throw ToggleTaskError.taskNotFound
    }
}
