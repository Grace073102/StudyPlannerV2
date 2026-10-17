//
//  SavedInternship.swift
//  StudyPlannerV2
//
//  Created by emily zhang on 15/10/2026.
//

import Foundation
/// An internship the student saved from the Job API, kept as a snapshot so it still displays offline. `jobID` comes from the Job API.
struct SavedInternship: Identifiable, Hashable, Sendable, Codable {
    var id: UUID
    var jobID: String
    var title: String
    var company: String
    var location: String?
    var applicationURL: URL?
    var applicationDeadline: Date?
    var savedDate: Date
    var applicationStatus: ApplicationStatus
    
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
        self.applicationStatus = applicationStatus
    }
}
