//
//  StoredAcademicTask.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 16/10/2026.
//

import Foundation
import SwiftData

typealias AcademicTask = StoredAcademicTask

@Model
final class StoredAcademicTask {
    @Attribute(.unique) var id: String
    var title: String
    var isCompleted: Bool
    var plannedDate: Date?
    var estimatedMinutes: Int?
    var position: Int
    var assignment: StoredAssignment?

    init(
        id: String = UUID().uuidString,
        title: String,
        isCompleted: Bool,
        plannedDate: Date? = nil,
        estimatedMinutes: Int? = nil,
        position: Int = 0
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.plannedDate = plannedDate
        self.estimatedMinutes = estimatedMinutes
        self.position = position
    }

    func copy() -> AcademicTask {
        AcademicTask(
            id: id,
            title: title,
            isCompleted: isCompleted,
            plannedDate: plannedDate,
            estimatedMinutes: estimatedMinutes,
            position: position
        )
    }

    init(task: AcademicTask, position: Int) {
        id = task.id
        title = task.title
        isCompleted = task.isCompleted
        plannedDate = task.plannedDate
        estimatedMinutes = task.estimatedMinutes
        self.position = position
    }
}
