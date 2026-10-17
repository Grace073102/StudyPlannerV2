//
//  PlacementRequirement.swift
//  StudyPlannerV2
//
//  Created by Djy on 15/10/2026.
//

import Foundation

struct PlacementRequirement: Identifiable, Equatable {

    enum Category: String, CaseIterable, Codable {
        case applicationsAndRegistration = "Applications & Registration"
        case checksAndClearances = "Checks & Clearances"
        case trainingAndCertificates = "Training & Certificates"
        case placementPreparation = "Placement Preparation"
        case placementProgress = "Placement Progress"
    }

    let id: UUID
    let placementID: UUID

    var name: String
    var category: Category
    var dueDate: Date?
    var expiryDate: Date?
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        placementID: UUID,
        name: String,
        category: Category,
        dueDate: Date? = nil,
        expiryDate: Date? = nil,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.placementID = placementID
        self.name = name
        self.category = category
        self.dueDate = dueDate
        self.expiryDate = expiryDate
        self.isCompleted = isCompleted
    }
}
