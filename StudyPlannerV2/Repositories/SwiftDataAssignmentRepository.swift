//
//  SwiftDataAssignmentRepository.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 16/10/2026.
//

import Foundation
import SwiftData

final class SwiftDataAssignmentRepository: AssignmentRepository {
    private(set) var assignments: [Assignment] = []
    private(set) var errorMessage: String?

    private let context: ModelContext

    init(container: ModelContainer) {
        context = ModelContext(container)
        context.autosaveEnabled = false
        assignments = load()
    }

    func load() -> [Assignment] {
        do {
            let descriptor = FetchDescriptor<StoredAssignment>(
                sortBy: [SortDescriptor(\StoredAssignment.dueDate)]
            )

            let records = try context.fetch(descriptor)
            let loadedAssignments = try records.map {
                try $0.toAssignment()
            }

            assignments = loadedAssignments
            errorMessage = nil
        } catch {
            errorMessage = "Your saved assignments could not be loaded."
        }

        return assignments
    }

    func add(_ assignment: Assignment) {
        performSave {
            guard try findAssignment(id: assignment.id) == nil else {
                throw RepositoryError.duplicateAssignment
            }

            let record = StoredAssignment(assignment: assignment)
            context.insert(record)
            replaceTasks(on: record, with: assignment.tasks)
        }
    }

    func update(_ assignment: Assignment) {
        performSave {
            guard let record = try findAssignment(id: assignment.id) else {
                throw RepositoryError.assignmentNotFound
            }

            record.title = assignment.title
            record.course = assignment.course
            record.dueDate = assignment.dueDate
            record.priorityRawValue = assignment.priority.rawValue
            record.assignmentDescription = assignment.description

            replaceTasks(on: record, with: assignment.tasks)
        }
    }

    func delete(_ assignment: Assignment) {
        performSave {
            guard let record = try findAssignment(id: assignment.id) else {
                throw RepositoryError.assignmentNotFound
            }

            context.delete(record)
        }
    }

    private func findAssignment(id: String) throws -> StoredAssignment? {
        let assignmentID = id

        var descriptor = FetchDescriptor<StoredAssignment>(
            predicate: #Predicate { record in
                record.id == assignmentID
            }
        )

        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    private func replaceTasks(
        on record: StoredAssignment,
        with tasks: [AcademicTask]
    ) {
        let existingTasks = record.tasks
        let incomingIDs = Set(tasks.map(\.id))

        for existingTask in existingTasks {
            if !incomingIDs.contains(existingTask.id) {
                context.delete(existingTask)
            }
        }

        var updatedTasks: [StoredAcademicTask] = []

        for (position, task) in tasks.enumerated() {
            let storedTask: StoredAcademicTask

            if let existingTask = existingTasks.first(
                where: { $0.id == task.id }
            ) {
                storedTask = existingTask
                storedTask.title = task.title
                storedTask.isCompleted = task.isCompleted
                storedTask.plannedDate = task.plannedDate
                storedTask.estimatedMinutes = task.estimatedMinutes
                storedTask.position = position
            } else {
                storedTask = StoredAcademicTask(
                    task: task,
                    position: position
                )
                context.insert(storedTask)
            }

            storedTask.assignment = record
            updatedTasks.append(storedTask)
        }

        record.tasks = updatedTasks
    }

    private func performSave(_ operation: () throws -> Void) {
        do {
            try operation()
            try context.save()
        } catch {
            context.rollback()
            errorMessage = "Your changes could not be saved. \(error.localizedDescription)"
            return
        }

        assignments = load()
    }

    private enum RepositoryError: LocalizedError {
        case duplicateAssignment
        case assignmentNotFound

        var errorDescription: String? {
            switch self {
            case .duplicateAssignment:
                return "An assignment with this ID already exists."
            case .assignmentNotFound:
                return "The assignment could not be found."
            }
        }
    }
    
    func migrateLegacyAssignmentsIfNeeded() throws {
        let migrationID = "json-assignments-v1"

        var descriptor = FetchDescriptor<StoredMigration>(
            predicate: #Predicate { migration in
                migration.id == migrationID
            }
        )
        descriptor.fetchLimit = 1

        guard try context.fetch(descriptor).isEmpty else {
            return
        }

        let documentsURL = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )

        let savedFileURL = documentsURL.appendingPathComponent(
            "SampleAssignments.json"
        )

        let sourceURL: URL?

        if FileManager.default.fileExists(atPath: savedFileURL.path) {
            sourceURL = savedFileURL
        } else {
            sourceURL = Bundle.main.url(
                forResource: "SampleAssignments",
                withExtension: "json"
            )
        }

        let legacyAssignments: [Assignment]

        if let sourceURL {
            let data = try Data(contentsOf: sourceURL)
            legacyAssignments = try JSONDecoder().decode(
                [LegacyAssignment].self,
                from: data
            ).map { $0.makeAssignment() }
        } else {
            legacyAssignments = []
        }

        do {
            for assignment in legacyAssignments {
                guard try findAssignment(id: assignment.id) == nil else {
                    continue
                }

                let record = StoredAssignment(assignment: assignment)
                context.insert(record)
                replaceTasks(on: record, with: assignment.tasks)
            }

            context.insert(StoredMigration(id: migrationID))
            try context.save()
        } catch {
            context.rollback()
            throw error
        }

        assignments = load()
    }
}

private struct LegacyAssignment: Decodable {
    let id: String
    let title: String
    let course: String
    let dueDate: Date
    let priority: Assignment.Priority
    let description: String?
    let tasks: [LegacyAcademicTask]

    func makeAssignment() -> Assignment {
        Assignment(
            id: id,
            title: title,
            course: course,
            dueDate: dueDate,
            priority: priority,
            description: description,
            tasks: tasks.map {
                AcademicTask(
                    id: $0.id,
                    title: $0.title,
                    isCompleted: $0.isCompleted,
                    plannedDate: $0.plannedDate,
                    estimatedMinutes: $0.estimatedMinutes
                )
            }
        )
    }
}

private struct LegacyAcademicTask: Decodable {
    let id: String
    let title: String
    let isCompleted: Bool
    let plannedDate: Date?
    let estimatedMinutes: Int?
}
