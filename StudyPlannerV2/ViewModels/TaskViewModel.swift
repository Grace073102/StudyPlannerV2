//
//  TaskViewModel.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 14/10/2026.
//

import Foundation
import Combine

final class TaskViewModel: ObservableObject {

    let assignmentViewModel: AssignmentViewModel
    private let addTaskUseCase: AddTaskUseCase
    private let editTaskUseCase: EditTaskUseCase
    private let toggleTaskUseCase: ToggleTaskUseCase
    private let deleteTaskUseCase: DeleteTaskUseCase

    @Published var errorMessage: String?

    init(assignmentViewModel: AssignmentViewModel) {
        self.assignmentViewModel = assignmentViewModel
        let repository = assignmentViewModel.repository
        self.addTaskUseCase = AddTaskUseCase(repository: repository)
        self.editTaskUseCase = EditTaskUseCase(repository: repository)
        self.toggleTaskUseCase = ToggleTaskUseCase(repository: repository)
        self.deleteTaskUseCase = DeleteTaskUseCase(repository: repository)
    }

    var allTasks: [AcademicTask] {
        assignmentViewModel.assignments.flatMap { $0.tasks }
    }

    var todayTasks: [AcademicTask] {
        allTasks.filter { task in
            guard let plannedDate = task.plannedDate else {
                return false
            }

            return Calendar.current.isDateInToday(plannedDate)
        }
    }

    var upcomingTasks: [AcademicTask] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard let oneWeekLater = calendar.date(
            byAdding: .day,
            value: 7,
            to: today
        ) else {
            return []
        }

        return allTasks
            .filter { task in
                guard let plannedDate = task.plannedDate else {
                    return false
                }

                let taskDate = calendar.startOfDay(for: plannedDate)

                return !task.isCompleted &&
                    taskDate >= today &&
                    taskDate <= oneWeekLater
            }
            .sorted {
                ($0.plannedDate ?? Date.distantFuture) <
                    ($1.plannedDate ?? Date.distantFuture)
            }
    }

    var thisWeekTasks: [AcademicTask] {
        allTasks.filter { task in
            guard let plannedDate = task.plannedDate else {
                return false
            }

            return Calendar.current.isDate(
                plannedDate,
                equalTo: Date(),
                toGranularity: .weekOfYear
            )
        }
    }

    var completedTasks: [AcademicTask] {
        allTasks.filter {
            $0.isCompleted
        }
    }

    var todayStudyMinutes: Int {
        todayIncompleteTasks
            .compactMap { $0.estimatedMinutes }
            .reduce(0, +)
    }

    var todayIncompleteTasks: [AcademicTask] {
        todayTasks.filter {
            !$0.isCompleted
        }
    }

    func addTask(
            title: String,
            plannedDate: Date? = nil,
            estimatedMinutes: Int? = nil,
            to assignmentID: String
        ) throws {
            try addTaskUseCase.execute(
                title: title,
                plannedDate: plannedDate,
                estimatedMinutes: estimatedMinutes,
                assignmentID: assignmentID
            )

            assignmentViewModel.load()
    }

    func editTask(
        taskID: String,
        newTitle: String,
        plannedDate: Date? = nil,
        estimatedMinutes: Int? = nil
    ) throws {
        try editTaskUseCase.execute(
            taskID: taskID,
            title: newTitle,
            plannedDate: plannedDate,
            estimatedMinutes: estimatedMinutes
        )
        assignmentViewModel.load()
    }
    
    func deleteTask(taskID: String) {
        do {
            try deleteTaskUseCase.execute(taskID: taskID)
            assignmentViewModel.load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func toggleTask(taskID: String) {
        do {
            try toggleTaskUseCase.execute(taskID: taskID)
            assignmentViewModel.load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
