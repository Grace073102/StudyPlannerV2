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
            guard let taskIndex = assignment.tasks.firstIndex(
                where: { $0.id == taskID }
            ) else {
                continue
            }

            var updatedAssignment = assignment
            updatedAssignment.tasks[taskIndex].isCompleted.toggle()
            repository.update(updatedAssignment)
            return
        }

        throw ToggleTaskError.taskNotFound
    }
}