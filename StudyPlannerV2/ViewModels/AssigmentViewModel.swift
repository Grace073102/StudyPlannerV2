//
//  AssigmentViewModel.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 14/10/2026.
//

import Foundation
import Combine

final class AssignmentViewModel: ObservableObject {

    @Published var assignments: [Assignment] = []
    @Published var repositoryErrorMessage: String?

    let repository: AssignmentRepository
    private let addAssignmentUseCase: AddAssignmentUseCase

    init(repository: AssignmentRepository) {
        self.repository = repository
        self.addAssignmentUseCase = AddAssignmentUseCase(repository: repository)
        load()
    }

    func load() {
        assignments = repository.assignments
        repositoryErrorMessage = repository.errorMessage
    }

    func add(
        title: String,
        course: String,
        dueDate: Date,
        priority: Assignment.Priority,
        description: String
    ) throws {
        _ = try addAssignmentUseCase.execute(
            title: title,
            course: course,
            dueDate: dueDate,
            priority: priority,
            description: description
        )

        assignments = repository.assignments
        repositoryErrorMessage = repository.errorMessage
    }

    func update(_ assignment: Assignment) {
        repository.update(assignment)
        assignments = repository.assignments
        repositoryErrorMessage = repository.errorMessage
    }

    func delete(_ assignment: Assignment) {
        repository.delete(assignment)
        assignments = repository.assignments
        repositoryErrorMessage = repository.errorMessage
    }

    var totalTaskCount: Int {
        assignments.flatMap { $0.tasks }.count
    }

    var completedTaskCount: Int {
        assignments.flatMap { $0.tasks }.filter { $0.isCompleted }.count
    }

    var overallProgress: Double {
        guard totalTaskCount > 0 else {
            return 0
        }

        return Double(completedTaskCount) / Double(totalTaskCount)
    }
}
