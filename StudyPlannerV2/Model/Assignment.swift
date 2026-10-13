//
//  Assignment.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 14/10/2026.
//

import Foundation

struct Assignment: Identifiable, Codable {

    var id: String = UUID().uuidString

    var title: String
    var course: String
    var dueDate: Date
    var priority: Priority
    var description: String?
    var tasks: [AcademicTask]

    var isCompleted: Bool {
        !tasks.isEmpty && tasks.allSatisfy { $0.isCompleted }
    }

    enum Priority: String, CaseIterable, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
    }
}
