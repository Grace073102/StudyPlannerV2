//
//  StoredSavedInternship.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 17/10/2026.
//

/// An internship the student saved from the Job API, to consider or apply for.
/// Not the same as a Placement, this is a listing the student is tracking, while a Placement is one they have secured. A saved internship that reaches

import Foundation
import SwiftData

typealias SavedInternship = StoredSavedInternship

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

    var applicationStatus: ApplicationStatus {
        get { ApplicationStatus(rawValue: applicationStatusRawValue) ?? .saved }
        set { applicationStatusRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        jobID: String,
        title: String,
        company: String,
        location: String? = nil,
        applicationURL: URL? = nil,
        applicationDeadline: Date? = nil,
        savedDate: Date = Date(),
        applicationStatus: ApplicationStatus = .saved
    ) {
        self.id = id
        self.jobID = jobID
        self.title = title
        self.company = company
        self.location = location
        self.applicationURL = applicationURL
        self.applicationDeadline = applicationDeadline
        self.savedDate = savedDate
        applicationStatusRawValue = applicationStatus.rawValue
    }

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
