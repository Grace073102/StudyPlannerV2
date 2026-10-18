//
//  StoredPlacementRequirement.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 17/10/2026.
//

import Foundation
import SwiftData

typealias PlacementRequirement = StoredPlacementRequirement

@Model
final class StoredPlacementRequirement {
    @Attribute(.unique) var id: UUID
    var placementID: UUID
    var name: String
    var categoryRawValue: String
    var dueDate: Date?
    var expiryDate: Date?
    var isCompleted: Bool
    var placement: StoredPlacement?

    enum Category: String, CaseIterable, Codable {
        case applicationsAndRegistration = "Applications & Registration"
        case checksAndClearances = "Checks & Clearances"
        case trainingAndCertificates = "Training & Certificates"
        case placementPreparation = "Placement Preparation"
        case placementProgress = "Placement Progress"
    }

    var category: Category {
        get { Category(rawValue: categoryRawValue) ?? .placementPreparation }
        set { categoryRawValue = newValue.rawValue }
    }

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
        categoryRawValue = category.rawValue
        self.dueDate = dueDate
        self.expiryDate = expiryDate
        self.isCompleted = isCompleted
    }

    func copy() -> PlacementRequirement {
        let result = PlacementRequirement(
            id: id,
            placementID: placementID,
            name: name,
            category: category,
            dueDate: dueDate,
            expiryDate: expiryDate,
            isCompleted: isCompleted
        )
        result.categoryRawValue = categoryRawValue
        return result
    }

    init(requirement: PlacementRequirement) {
        id = requirement.id
        placementID = requirement.placementID
        name = requirement.name
        categoryRawValue = requirement.category.rawValue
        dueDate = requirement.dueDate
        expiryDate = requirement.expiryDate
        isCompleted = requirement.isCompleted
    }

    func toRequirement() throws -> PlacementRequirement {
        guard let category = PlacementRequirement.Category(
            rawValue: categoryRawValue
        ) else {
            throw RequirementStorageError.invalidCategory
        }

        return PlacementRequirement(
            id: id,
            placementID: placementID,
            name: name,
            category: category,
            dueDate: dueDate,
            expiryDate: expiryDate,
            isCompleted: isCompleted
        )
    }
}

enum RequirementStorageError: LocalizedError {
    case invalidCategory

    var errorDescription: String? {
        switch self {
        case .invalidCategory:
            return "The saved requirement has an unknown category."
        }
    }
}
