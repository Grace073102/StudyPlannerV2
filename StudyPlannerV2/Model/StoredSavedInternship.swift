//
//  StoredSavedInternship.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 17/10/2026.
//

import Foundation
import SwiftData

@Model
final class StoredSavedInternship {
    @Attribute(.unique) var id: UUID
    var jobID: String
    var title: String
    var company: String
    var location: String?
    var applicationURL: URL?
    var applicationDeadline: Date?
    var savedDate: Date
    var applicationStatusRawValue: String

    init(internship: SavedInternship) {
        id = internship.id
        jobID = internship.jobID
        title = internship.title
        company = internship.company
        location = internship.location
        applicationURL = internship.applicationURL
        applicationDeadline = internship.applicationDeadline
        savedDate = internship.savedDate
        applicationStatusRawValue = internship.applicationStatus.rawValue
    }

    func toSavedInternship() throws -> SavedInternship {
        guard let status = ApplicationStatus(
            rawValue: applicationStatusRawValue
        ) else {
            throw InternshipStorageError.invalidStatus
        }

        return SavedInternship(
            id: id,
            jobID: jobID,
            title: title,
            company: company,
            location: location,
            applicationURL: applicationURL,
            applicationDeadline: applicationDeadline,
            savedDate: savedDate,
            applicationStatus: status
        )
    }
}

enum InternshipStorageError: LocalizedError {
    case invalidStatus

    var errorDescription: String? {
        switch self {
        case .invalidStatus:
            return "The saved internship has an unknown application status."
        }
    }
}
