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

    init(assignmentViewModel: AssignmentViewModel) {
        self.assignmentViewModel = assignmentViewModel
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
    ) {
        let cleanedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedTitle.isEmpty else {
            return
        }

        guard let existingAssignment = assignmentViewModel.assignments.first(
            where: { $0.id == assignmentID }
        ) else {
            return
        }

        let assignment = existingAssignment.copy()
        let newTask = AcademicTask(
            title: cleanedTitle,
            isCompleted: false,
            plannedDate: plannedDate,
            estimatedMinutes: estimatedMinutes
        )

        assignment.tasks.append(newTask)
        assignmentViewModel.update(assignment)
    }

    func editTask(
        taskID: String,
        newTitle: String,
        plannedDate: Date? = nil,
        estimatedMinutes: Int? = nil
    ) {
        let cleanedTitle = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedTitle.isEmpty else {
            return
        }

        for assignment in assignmentViewModel.assignments {
            guard let taskIndex = assignment.tasks.firstIndex(
                where: { $0.id == taskID }
            ) else {
                continue
            }

            let updatedAssignment = assignment.copy()
            updatedAssignment.tasks[taskIndex].title = cleanedTitle
            updatedAssignment.tasks[taskIndex].plannedDate = plannedDate
            updatedAssignment.tasks[taskIndex].estimatedMinutes = estimatedMinutes

            assignmentViewModel.update(updatedAssignment)
            return
        }
    }

    func deleteTask(taskID: String) {
        for assignment in assignmentViewModel.assignments {
            guard let taskIndex = assignment.tasks.firstIndex(
                where: { $0.id == taskID }
            ) else {
                continue
            }

            let updatedAssignment = assignment.copy()
            updatedAssignment.tasks.remove(at: taskIndex)

            assignmentViewModel.update(updatedAssignment)
            return
        }
    }

    func toggleTask(taskID: String) {
        for assignment in assignmentViewModel.assignments {
            guard let taskIndex = assignment.tasks.firstIndex(
                where: { $0.id == taskID }
            ) else {
                continue
            }

            let updatedAssignment = assignment.copy()
            updatedAssignment.tasks[taskIndex].isCompleted.toggle()

            assignmentViewModel.update(updatedAssignment)
            return
        }
    }
}
