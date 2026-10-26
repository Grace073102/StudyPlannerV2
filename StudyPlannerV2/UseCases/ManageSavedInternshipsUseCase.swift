//
//  ManageSavedInternshipsUseCase.swift
//  StudyPlannerV2
//
//  Created by emily zhang on 18/10/2026.
//

import Foundation

/// Applies all business rules for internships the student saved from the Job API.
/// The ViewModel calls this type and never touches the repository directly.
///
/// Business rules
/// 1. A saved internship must have a job ID, a title and a company (blank is rejected).
/// 2. Job ID, title and company are trimmed before they are saved.
/// 3. The same job cannot be saved twice; uniqueness is checked by `jobID`.
/// 4. Only an existing saved internship can have its status changed or be deleted.
/// 5. Saved internships are listed with the most recently saved first.
struct ManageSavedInternshipsUseCase {

    enum SavedInternshipError: LocalizedError, Equatable {
        case missingJobID
        case missingTitle
        case missingCompany
        case alreadySaved
        case internshipNotFound

        var errorDescription: String? {
            switch self {
            case .missingJobID:       "This opportunity has no valid job ID."
            case .missingTitle:       "The internship title is missing."
            case .missingCompany:     "The company name is missing."
            case .alreadySaved:       "You have already saved this internship."
            case .internshipNotFound: "This saved internship could not be found."
            }
        }
    }

    let repository: SavedInternshipRepository

    // MARK: - Business logic

    /// Returns all saved internships, most recently saved first.
    /// - Throws: `SavedInternshipRepositoryError.loadFailed`.
    func fetchAll() throws -> [SavedInternship] {
        try repository.load().sorted { $0.savedDate > $1.savedDate }
    }

    /// Saves an internship after trimming it and checking it is not already saved.
    /// - Throws: `SavedInternshipError.missingJobID`, `.missingTitle`, `.missingCompany`,`.alreadySaved`, or `SavedInternshipRepositoryError.saveFailed`.
    func save(_ internship: SavedInternship) throws {
        let cleaned = try validated(internship)

        guard try !repository.load().contains(where: { $0.jobID == cleaned.jobID }) else {
            throw SavedInternshipError.alreadySaved
        }

        try repository.add(cleaned)
    }

    /// Changes the application status (saved, applied, interviewing, offered, rejected).
    /// - Throws: `SavedInternshipError.internshipNotFound` or `SavedInternshipRepositoryError.saveFailed`.
    func updateApplicationStatus(id: UUID, to status: ApplicationStatus) throws {
        guard let internship = try repository.load().first(where: { $0.id == id }) else {
            throw SavedInternshipError.internshipNotFound
        }

        internship.applicationStatus = status
        try repository.update(internship)
    }

    /// Deletes a saved internship.
    /// - Throws: `SavedInternshipError.internshipNotFound`or `SavedInternshipRepositoryError.saveFailed`.
    func delete(id: UUID) throws {
        guard let internship = try repository.load().first(where: { $0.id == id }) else {
            throw SavedInternshipError.internshipNotFound
        }

        try repository.delete(internship)
    }

    // MARK: - Rules

    /// Checks the rules and returns a trimmed copy. SavedInternship is a class, so a new object is built instead of changing the one passed in.
    private func validated(_ internship: SavedInternship) throws -> SavedInternship {
        // Trim text
        let jobID = internship.jobID.trimmingCharacters(in: .whitespacesAndNewlines)
        let title = internship.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let company = internship.company.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Rule 1: Job ID, title and company can’t be blank
        guard !jobID.isEmpty else { throw SavedInternshipError.missingJobID }
        guard !title.isEmpty else { throw SavedInternshipError.missingTitle }
        guard !company.isEmpty else { throw SavedInternshipError.missingCompany }
        
        // Build cleaned copy
        return SavedInternship(
            id: internship.id,
            jobID: jobID,
            title: title,
            company: company,
            location: internship.location,
            applicationURL: internship.applicationURL,
            companyWebsiteURL: internship.companyWebsiteURL,
            applicationDeadline: internship.applicationDeadline,
            savedDate: internship.savedDate,
            applicationStatus: internship.applicationStatus
        )
    }
}
