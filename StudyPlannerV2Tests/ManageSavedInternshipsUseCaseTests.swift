//
//  ManageSavedInternshipsUseCaseTests.swift
//  StudyPlannerV2
//
//  Created by emily zhang on 19/10/2026.
//

import Foundation
import Testing
@testable import StudyPlannerV2
 
/// Tests saved internship business rules using an in-memory mock repository.

@MainActor
struct ManageSavedInternshipsUseCaseTests {
 
    // MARK: - Helper
    /// Creates a valid saved internship for testing.
    private func makeInternship(
        jobID: String = "job-1001",
        title: String = "Software Engineering Intern",
        company: String = "Acme Pty Ltd",
        savedDate: Date = Date(),
        status: ApplicationStatus = .saved
    ) -> SavedInternship {
        SavedInternship(
            jobID: jobID,
            title: title,
            company: company,
            savedDate: savedDate,
            applicationStatus: status
        )
    }
    
    // MARK: - Save
    /// A student saves an internship with valid details and it is added to their saved internships.
    @Test func saveWithValidDetailsSavesIt() throws {
        let repository = MockSavedInternshipRepository()
        let useCase = ManageSavedInternshipsUseCase(repository: repository)
        let internship = makeInternship()
        
        // Execute and expect the internship to be saved
        try useCase.save(internship)
        
        // Expect the internship to be added and to have the correct job ID
        #expect(repository.internships.count == 1)
        #expect(repository.internships.first?.jobID == "job-1001")
    }
    
    /// A student saves an internship with extra spaces in its details and the spaces are removed when saving.
    @Test func saveWithExtraSpacesTrimsText() throws {
        let repository = MockSavedInternshipRepository()
        let useCase = ManageSavedInternshipsUseCase(repository: repository)
        
        // Execute and expect whitespace to be trimmed from the internship details
        try useCase.save(
            makeInternship(
                jobID: " job-1001 ",
                title: " Intern ",
                company: " Acme "
            )
        )
        
        // Retrieve and expect the saved internship to be available
        let saved = try #require(repository.internships.first)
        
        // Expect the internship details to be trimmed
        #expect(saved.jobID == "job-1001")
        #expect(saved.title == "Intern")
        #expect(saved.company == "Acme")
    }
    
    /// A student saves an internship with a company website URL.
    @Test func saveWithCompanyWebsiteKeepsIt() throws {
        let repository = MockSavedInternshipRepository()
        let useCase = ManageSavedInternshipsUseCase(repository: repository)
        let website = URL(string: "https://example.com")
        
        // Execute and verify the company website URL is retained
        try useCase.save(
            SavedInternship(jobID: "job-1", title: "Intern", company: "Acme", companyWebsiteURL: website)
        )
        #expect(repository.internships.first?.companyWebsiteURL == website)
    }
    
    // MARK: - Required Fields
    /// An internship has no job ID so it cannot be saved.
    @Test func saveWithEmptyJobIDThrowsError() {
        let repository = MockSavedInternshipRepository()
        let useCase = ManageSavedInternshipsUseCase(repository: repository)
        
        // Expect a missingJobID error while executing
        #expect(
            throws: ManageSavedInternshipsUseCase.SavedInternshipError.missingJobID
        ) {
            try useCase.save(makeInternship(jobID: ""))
        }
        
        // Expect no internships to be saved
        #expect(repository.internships.isEmpty)
    }
    
    /// An internship has no title so it cannot be saved.
    @Test func saveWithEmptyTitleThrowsError() {
        let repository = MockSavedInternshipRepository()
        let useCase = ManageSavedInternshipsUseCase(repository: repository)
        
        // Expect a missingTitle error while executing
        #expect(
            throws: ManageSavedInternshipsUseCase.SavedInternshipError.missingTitle
        ) {
            try useCase.save(makeInternship(title: ""))
        }
        
        // Expect no internships to be saved
        #expect(repository.internships.isEmpty)
    }
    
    /// An internship has no company name, so it cannot be saved.
    @Test func saveWithEmptyCompanyThrowsError() {
        let repository = MockSavedInternshipRepository()
        let useCase = ManageSavedInternshipsUseCase(repository: repository)
        
        // Expect a missingCompany error while executing
        #expect(
            throws: ManageSavedInternshipsUseCase.SavedInternshipError.missingCompany
        ) {
            try useCase.save(makeInternship(company: ""))
        }
        
        // Expect no internships to be saved
        #expect(repository.internships.isEmpty)
    }
    
    // MARK: - Duplicate Jobs
    /// A student tries to save the same internship twice so the second save is rejected.
    @Test func saveSameJobIDTwiceThrowsAlreadySaved() throws {
        let repository = MockSavedInternshipRepository()
        let useCase = ManageSavedInternshipsUseCase(repository: repository)

        // Execute and expect the first internship to be saved
        try useCase.save(makeInternship(jobID: "job-1001"))
 
        // Expect an alreadySaved error while executing
        #expect(
            throws: ManageSavedInternshipsUseCase.SavedInternshipError.alreadySaved
        ) {
            try useCase.save(makeInternship(jobID: "job-1001"))
        }
        
        // Expect only the first internship to remain saved
        #expect(repository.internships.count == 1)
    }
    
    // MARK: - Update Application Status
    /// A student changes an internship's application status from saved to applied and the change is stored.
    @Test func updateApplicationStatusWithExistingIDChangesStatus() throws {
        let existing = makeInternship(status: .saved)
        let repository = MockSavedInternshipRepository(
            internships: [existing]
        )
        let useCase = ManageSavedInternshipsUseCase(repository: repository)
        
        // Execute and expect the application status to be updated
        try useCase.updateApplicationStatus(
            id: existing.id,
            to: .applied
        )
        
        // Expect the internship status to be applied
        #expect(
            repository.internships.first?.applicationStatus == .applied
        )
    }
    
    /// A student tries to update an internship that does not exist so an internshipNotFound error is returned.
    @Test func updateApplicationStatusWithUnknownIDThrowsError() {
        let repository = MockSavedInternshipRepository()
        let useCase = ManageSavedInternshipsUseCase(repository: repository)
        
        // Expect an internshipNotFound error while executing
        #expect(
            throws: ManageSavedInternshipsUseCase.SavedInternshipError.internshipNotFound
        ) {
            try useCase.updateApplicationStatus(
                id: UUID(),
                to: .applied
            )
        }
    }
    
    /// Updating an internship's application status fails so the original status remains unchanged.
    @Test func updateApplicationStatusWhenSaveFailsKeepsOriginalStatus() {
        let existing = makeInternship(status: .saved)
        let repository = MockSavedInternshipRepository(
            internships: [existing]
        )
        repository.shouldFailOnSave = true
        let useCase = ManageSavedInternshipsUseCase(repository: repository)
        
        // Expect a saveFailed error while executing
        #expect(
            throws: SavedInternshipRepositoryError.saveFailed
        ) {
            try useCase.updateApplicationStatus(
                id: existing.id,
                to: .applied
            )
        }
        // Expect the original application status to remain unchanged
        #expect(
            repository.internships.first?.applicationStatus == .saved
        )
    }
    
    // MARK: - Delete
    /// A student removes a saved internship and it is deleted from their saved internships.
    @Test func deleteWithExistingIDRemovesInternship() throws {
        let existing = makeInternship()
        let repository = MockSavedInternshipRepository(
            internships: [existing]
        )
        let useCase = ManageSavedInternshipsUseCase(repository: repository)
        
        // Execute and expect the saved internship to be deleted
        try useCase.delete(id: existing.id)
        
        // Expect no internships to be saved
        #expect(repository.internships.isEmpty)
    }
    
    // MARK: - Fetch and Sorting
    /// A student views their saved internships and the most recently saved internship appears first.
    @Test func fetchAllSortsByMostRecentlySaved() throws {
        let older = makeInternship(
            jobID: "job-1",
            savedDate: Date(timeIntervalSince1970: 1_000_000)
        )
        let newer = makeInternship(
            jobID: "job-2",
            savedDate: Date(timeIntervalSince1970: 2_000_000)
        )
 
        // Store the older internship first
        let repository = MockSavedInternshipRepository(
            internships: [older, newer]
        )
        let useCase = ManageSavedInternshipsUseCase(repository: repository)
        
        // Execute and expect internships to be sorted by saved date
        let internships = try useCase.fetchAll()
 
        // Expect the newest internship to appear first
        #expect(internships.count == 2)
        #expect(internships[0].jobID == "job-2")
        #expect(internships[1].jobID == "job-1")
    }
    
    // MARK: - Repository Errors
    /// Saving an internship fails because of a repository error so the error is returned and nothing is saved.
    @Test func saveWhenRepositoryFailsPropagatesError() {
        let repository = MockSavedInternshipRepository()
        
        // Simulate a save failure
        repository.shouldFailOnSave = true
        let useCase = ManageSavedInternshipsUseCase(repository: repository)
        
        // Expect a saveFailed error while executing
        #expect(
            throws: SavedInternshipRepositoryError.saveFailed
        ) {
            try useCase.save(makeInternship())
        }
        
        // Expect no internships to be saved
        #expect(repository.internships.isEmpty)
    }
}
