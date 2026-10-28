//
//  StoredInternshipRequirement.swift
//  StudyPlannerV2
//
//  Created by Djy on 28/10/2026.
//

import Foundation
import SwiftData

typealias InternshipRequirement = StoredInternshipRequirement

@Model
final class StoredInternshipRequirement {
    
    @Attribute(.unique)
    var id: UUID
    
    var internshipID: UUID = UUID()
    var name: String
    var categoryRawValue: String
    var dueDate: Date?
    var expiryDate: Date?
    var isCompleted: Bool
    
    var internship: StoredSavedInternship?
    
    enum Category: String, CaseIterable, Codable {
        case applicationDocuments = "Application Documents"
        case applicationsAndFollowUps = "Applications & Follow-ups"
        case interviewPreparation = "Interview Preparation"
        case offersAndOnboarding = "Offers & Onboarding"
        case trainingAndCertificates = "Training & Certificates"
    }
    
    var category: Category {
        get {
            Category(rawValue: categoryRawValue) ?? .applicationDocuments
        }
        set {
            categoryRawValue = newValue.rawValue
        }
    }
    
    init(
        id: UUID = UUID(),
        internshipID: UUID,
        name: String,
        category: Category,
        dueDate: Date? = nil,
        expiryDate: Date? = nil,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.internshipID = internshipID
        self.name = name
        self.categoryRawValue = category.rawValue
        self.dueDate = dueDate
        self.expiryDate = expiryDate
        self.isCompleted = isCompleted
    }
    
    init(requirement: InternshipRequirement) {
        id = requirement.id
        internshipID = requirement.internship?.id ?? requirement.internshipID
        name = requirement.name
        categoryRawValue = requirement.categoryRawValue
        dueDate = requirement.dueDate
        expiryDate = requirement.expiryDate
        isCompleted = requirement.isCompleted
    }
    
    func copy() -> InternshipRequirement {
        let result = InternshipRequirement(
            id: id,
            internshipID: internship?.id ?? internshipID,
            name: name,
            category: category,
            dueDate: dueDate,
            expiryDate: expiryDate,
            isCompleted: isCompleted
        )
        
        result.categoryRawValue = categoryRawValue
        
        return result
    }
    
    func toRequirement() throws -> InternshipRequirement {
        guard let category = Category(
            rawValue: categoryRawValue
        ) else {
            throw InternshipRequirementStorageError.invalidCategory
        }
        
        return InternshipRequirement(
            id: id,
            internshipID: internship?.id ?? internshipID,
            name: name,
            category: category,
            dueDate: dueDate,
            expiryDate: expiryDate,
            isCompleted: isCompleted
        )
    }
}

enum InternshipRequirementStorageError: LocalizedError {
    
    case invalidCategory
    
    var errorDescription: String? {
        switch self {
        case .invalidCategory:
            return "The saved internship requirement has an unknown category."
        }
    }
}
