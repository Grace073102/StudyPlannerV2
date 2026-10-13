//
//  AcademicTask.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 14/10/2026.
//

import Foundation

struct AcademicTask: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var isCompleted: Bool

    var plannedDate: Date?
    var estimatedMinutes: Int?
}

