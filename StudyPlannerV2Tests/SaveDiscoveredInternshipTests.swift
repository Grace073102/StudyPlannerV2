//
//  SaveDiscoveredInternshipTests.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 24/10/2026.
//

import Foundation
import SwiftData
import Testing
@testable import StudyPlannerV2

@MainActor
struct SaveDiscoveredInternshipTests {

    @Test
    func savingDiscoveredInternshipStoresItsDetails() throws {
        let container = try makeContainer()
        let repository = SwiftDataSavedInternshipRepository(
            container: container
        )
        let useCase = SaveDiscoveredInternshipUseCase(
            savedInternships: ManageSavedInternshipsUseCase(
                repository: repository
            )
        )
        let listing = try makeListing()

        try useCase.save(listing)

        // A separate repository reads the saved database state.
        let reader = SwiftDataSavedInternshipRepository(
            container: container
        )
        let results = try reader.load()

        #expect(results.count == 1)

        let saved = try #require(results.first)
        #expect(saved.jobID == "cleanjobdata:test-123")
        #expect(saved.title == "Software Engineering Intern")
        #expect(saved.company == "Example Company")
        #expect(saved.location == "Sydney, Australia")
        #expect(
            saved.applicationURL?.absoluteString
                == "https://example.com/jobs/test-123"
        )
        #expect(saved.applicationStatus == .saved)
        #expect(saved.applicationDeadline == nil)
    }

    @Test
    func savingSameListingTwiceRejectsDuplicate() throws {
        let container = try makeContainer()
        let repository = SwiftDataSavedInternshipRepository(
            container: container
        )
        let useCase = SaveDiscoveredInternshipUseCase(
            savedInternships: ManageSavedInternshipsUseCase(
                repository: repository
            )
        )
        let listing = try makeListing()

        try useCase.save(listing)

        #expect(
            throws: ManageSavedInternshipsUseCase
                .SavedInternshipError.alreadySaved
        ) {
            try useCase.save(listing)
        }

        let reader = SwiftDataSavedInternshipRepository(
            container: container
        )
        let results = try reader.load()

        #expect(results.count == 1)
        #expect(results.first?.jobID == listing.savedJobID)
    }

    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([
            StoredSavedInternship.self
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        return try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }

    private func makeListing() throws -> DiscoveredInternship {
        let json = """
        {
            "id": "test-123",
            "title": "Software Engineering Intern",
            "company": {
                "name": "Example Company"
            },
            "location": "Sydney, Australia",
            "application_url": "https://example.com/jobs/test-123",
            "employment_type": "INTERN"
        }
        """

        return try JSONDecoder().decode(
            DiscoveredInternship.self,
            from: Data(json.utf8)
        )
    }
}
