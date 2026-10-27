//
//  ManagePlacementsUseCaseTests.swift
//  StudyPlannerV2
//
//  Created by emily zhang on 18/10/2026.
//

import Foundation
import Testing
@testable import StudyPlannerV2

/// Tests placement business rules using an in-memory mock repository.

@MainActor
struct ManagePlacementsUseCaseTests {
    
    // MARK: - Helpers
    /// Creates a date for testing.
    private func date(
        _ year: Int,
        _ month: Int,
        _ day: Int
    ) -> Date {
        Calendar.current.date(
            from: DateComponents(
                year: year,
                month: month,
                day: day
            )
        )!
    }
    
    /// Creates a valid placement for testing.
    private func makePlacement(
        name: String = "Teaching Placement",
        start: Date? = nil,
        end: Date? = nil,
        subjectID: UUID? = nil
    ) -> Placement {
        Placement(
            name: name,
            startDate: start ?? date(2026, 11, 2),
            endDate: end ?? date(2026, 11, 27),
            subjectID: subjectID
        )
    }
    
    // MARK: - Add
    /// A student adds a placement with valid dates annd it is stored.
    @Test func addWithValidDetailsSavesIt() throws {
        let repository = MockPlacementRepository()
        let useCase = ManagePlacementsUseCase(repository: repository)
        let placement = makePlacement()
        
        // Execute and expect the placement to be added
        try useCase.add(placement)
        #expect(repository.placements.count == 1)
        #expect(repository.placements.first?.name == "Teaching Placement")

    }
    
    /// A student links a university subject to a placement, and the subject ID is saved.
    @Test func addWithLinkedSubjectSavesSubjectID() throws {
        let repository = MockPlacementRepository()
        let useCase = ManagePlacementsUseCase(repository: repository)
        let subjectID = UUID()
        
        // Execute and expect the placement to be saved.
        try useCase.add(makePlacement(subjectID: subjectID))
        
        // Retrieve the saved placement and verify its subject ID
        let saved = try #require(repository.placements.first)
        #expect(saved.subjectID == subjectID)
    }
    
    /// A student enters extra spaces around the placement name and the spaces are removed when saving.
    @Test func addWithExtraSpacesTrimsText() throws {
        let repository = MockPlacementRepository()
        let useCase = ManagePlacementsUseCase(repository: repository)
        
        // Execute and expect whitespace to be trimmed
        try useCase.add(
            makePlacement(name: "  Teaching Placement  ")
        )
        
        // Retrieve and expect the placement to be saved
        let saved = try #require(repository.placements.first)
        
        // Expect the name to be trimmed
        #expect(saved.name == "Teaching Placement")
    }
    
    /// A student enters only spaces for the placement name, so the placement is not saved.
    @Test func addWithBlankNameThrowsError() {
        let repository = MockPlacementRepository()
        let useCase = ManagePlacementsUseCase(repository: repository)
        
        // Expect an emptyName error while executing
        #expect(
            throws: ManagePlacementsUseCase.PlacementError.emptyName
        ) {
            try useCase.add(makePlacement(name: "   "))
        }
        
        // Expect no placements to be saved
        #expect(repository.placements.isEmpty)
    }
    
    // MARK: - Date Validation
    /// A student creates a placement that starts and ends on the same day, and it is saved.
    @Test func add_withSameStartAndEndDate_savesIt() throws {
        let repository = MockPlacementRepository()
        let useCase = ManagePlacementsUseCase(repository: repository)
        
        // Define the same start and end date
        let day = date(2026, 11, 2)
        
        // Execute and expect the placement to be saved with the same start and end date
        try useCase.add(
            makePlacement(start: day, end: day)
        )
        
        // Expect the placement to be added
        #expect(repository.placements.count == 1)
    }
    
    /// A student enters an end date before the start date so placement is rejected.
    @Test func addWithSameStartAndEndDateSavesIt() {
        let repository = MockPlacementRepository()
        let useCase = ManagePlacementsUseCase(repository: repository)
        
        // Define the start and end date
        let placement = makePlacement(
            start: date(2026, 11, 2),
            end: date(2026, 11, 1)
        )
        
        // Expect an invalidDates error while executing
        #expect(
            throws: ManagePlacementsUseCase.PlacementError.invalidDates
        ) {
            try useCase.add(placement)
        }
        
        // Expect no placements to be saved
        #expect(repository.placements.isEmpty)
    }
    
    // MARK: - Update
    /// A student updates an existing placement, and the changes are saved.
    @Test func updateWithValidDetailsSavesChanges() throws {
        let existing = makePlacement()
        let repository = MockPlacementRepository(
            placements: [existing]
        )
        let useCase = ManagePlacementsUseCase(repository: repository)
        
        // Create a placement with updated name
        let updated = Placement(
            id: existing.id,
            name: "Updated Teaching Placement",
            startDate: existing.startDate,
            endDate: existing.endDate,
            subjectID: existing.subjectID
        )
        
        // Execute and expect the existing placement to be updated
        try useCase.update(updated)
        
        // Expect the repository to contain one placement
        #expect(repository.placements.count == 1)
        
        // Expect the placement to have the updated name
        #expect(
            repository.placements.first?.name ==
            "Updated Teaching Placement"
        )
    }
    
    /// A student updates a placement with invalide dates so the original placement remains unchanged.
    @Test func updateWithInvalidDatesKeepsOriginal() {
        let existing = makePlacement(name: "Original")
        let repository = MockPlacementRepository(
            placements: [existing]
        )
        let useCase = ManagePlacementsUseCase(repository: repository)
        
        // Create a placement with invalid dates
        let invalid = Placement(
            id: existing.id,
            name: "Changed",
            startDate: date(2026, 11, 10),
            endDate: date(2026, 11, 1),
            subjectID: existing.subjectID
        )
        
        // Expect an invalidDates error while executing
        #expect(
            throws: ManagePlacementsUseCase.PlacementError.invalidDates
        ) {
            try useCase.update(invalid)
        }
        
        // Expect the existing placement to remain unchanged
        #expect(repository.placements.first?.name == "Original")
    }
    
    /// A student tries to update a placement that does not exist.
    @Test func updateWithUnknownIDThrowsError() {
        let repository = MockPlacementRepository()
        let useCase = ManagePlacementsUseCase(repository: repository)
        
        // Expect a placementNotFound error while executing
        #expect(
            throws: ManagePlacementsUseCase.PlacementError.placementNotFound
        ) {
            try useCase.update(makePlacement())
        }
    }
 
    // MARK: - Delete
    /// A student deletes an existing placement and it is removed from the saved placements.
    @Test func deleteWithExistingIDRemovesPlacement() throws {
        let existing = makePlacement()
        let repository = MockPlacementRepository(
            placements: [existing]
        )
        let useCase = ManagePlacementsUseCase(repository: repository)
        
        // Execute and expect the existing placement to be deleted
        try useCase.delete(id: existing.id)
        
        // Expect no placements to be saved
        #expect(repository.placements.isEmpty)
    }
 
    // MARK: - Fetch and Sorting
    /// A student views their placements and they are listed in order of earliest start date first.
    @Test func fetchAllSortsByStartDate() throws {
        let later = makePlacement(
            name: "Later",
            start: date(2027, 2, 1),
            end: date(2027, 2, 28)
        )
        let earlier = makePlacement(
            name: "Earlier",
            start: date(2026, 8, 3),
            end: date(2026, 8, 28)
        )
 
        // Save the later placement first
        let repository = MockPlacementRepository(
            placements: [later, earlier]
        )
        let useCase = ManagePlacementsUseCase(repository: repository)
        
        // Execute and expect placements to be sorted by start date
        let results = try useCase.fetchAll()
 
        // Expect the placements to be returned in the correct order
        #expect(results.count == 2)
        #expect(results[0].placement.name == "Earlier")
        #expect(results[1].placement.name == "Later")
    }
 
    // MARK: - Placement Status
    /// A student views a placement before its start date and its status is upcoming.
    @Test func fetchAllBeforeStartDateIsUpcoming() throws {
        let placement = makePlacement(
            start: date(2027, 3, 10),
            end: date(2027, 3, 14)
        )
        let repository = MockPlacementRepository(
            placements: [placement]
        )
        let useCase = ManagePlacementsUseCase(repository: repository)
 
        // Execute and expect the placement to be upcoming one day before it starts
        let results = try useCase.fetchAll(
            on: date(2027, 3, 9)
        )
        
        // Expect the placement to be returned with an upcoming status
        #expect(results.count == 1)
        #expect(results[0].status == .upcoming)
    }
    
    /// A student views a placement during its scheduled dates and its status is in progress.
    @Test func fetchAllDuringPlacementIsInProgress() throws {
        
        // Create a placement with a defined start and end date
        let placement = makePlacement(
            start: date(2027, 3, 10),
            end: date(2027, 3, 14)
        )
        let repository = MockPlacementRepository(
            placements: [placement]
        )
        let useCase = ManagePlacementsUseCase(repository: repository)
 
        // Execute and expect the placement to be in progress between its start and end dates
        let results = try useCase.fetchAll(
            on: date(2027, 3, 12)
        )
        
        // Expect the placement to be returned with an in-progress status
        #expect(results.count == 1)
        #expect(results[0].status == .inProgress)
    }
    
    ///A student views a placement after its end date and its status is completed.
    @Test func fetchAllAfterEndDateIsCompleted() throws {
        
        // Create a placement with a defined start and end date
        let placement = makePlacement(
            start: date(2027, 3, 10),
            end: date(2027, 3, 14)
        )
        let repository = MockPlacementRepository(
            placements: [placement]
        )
        let useCase = ManagePlacementsUseCase(repository: repository)
        
        // Execute and expect the placement to be completed one day after it ends
        let results = try useCase.fetchAll(
            on: date(2027, 3, 15)
        )
        // Expect the placement to be returned with a completed status
        #expect(results.count == 1)
        #expect(results[0].status == .completed)
    }
 
    // MARK: - Repository Errors
    /// Saving a placement fails because of a repository error so the error is returned and nothing is saved.
    @Test func addWhenRepositoryFailsPropagatesError() {
        let repository = MockPlacementRepository()
        
        // Simulate a save failure
        repository.shouldFailOnSave = true
        let useCase = ManagePlacementsUseCase(repository: repository)
        
        // Expect a saveFailed error while executing
        #expect(
            throws: PlacementRepositoryError.saveFailed
        ) {
            try useCase.add(makePlacement())
        }
        
        // Expect no placements to be saved
        #expect(repository.placements.isEmpty)
    }
}
