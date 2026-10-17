//
//  StoredAcademicTask.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 16/10/2026.
//

import Foundation
import SwiftData

@Model
final class StoredAcademicTask {
    @Attribute(.unique) var id: String
    var title: String
    var isCompleted: Bool
    var plannedDate: Date?
    var estimatedMinutes: Int?
    var position: Int
    var assignment: StoredAssignment?

    init(task: AcademicTask, position: Int) {
        id = task.id
        title = task.title
        isCompleted = task.isCompleted
        plannedDate = task.plannedDate
        estimatedMinutes = task.estimatedMinutes
        self.position = position
    }
}
