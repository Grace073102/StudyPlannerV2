//
//  InternshipAPILiveTests.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 24/10/2026.
//

import Foundation
import Testing
@testable import StudyPlannerV2

@MainActor
struct InternshipAPILiveTests {

    @Test
    //(.disabled("Manual API check; uses a personal key and request allowance"))
    func fetchAustralianInternships() async throws {
        let repository = try RemoteInternshipRepository(
            apiKey: Env.cleanJobDataAPIKey()
        )

        let page = try await repository.search(
            InternshipSearch(title: "intern")
        )

        print("Internships received: \(page.data.count)")
        print("Another page available: \(page.pagination.nextPage != nil)")
       

        for internship in page.data.prefix(5) {
            print(
                "\(internship.title)"
                + " — \(internship.companyDisplayName)"
                + " — location: \(internship.location ?? "not provided")"
                + " — type: \(internship.employmentType ?? "not provided")"
            )
            print("Job ID: \(internship.id)")
            print("API link: \(internship.applicationURLText ?? "missing")")
            print("App link: \(internship.applicationURL?.absoluteString ?? "invalid")")
        }

        // An empty page is valid; returned listings need usable IDs/titles.
        for internship in page.data {
            #expect(!internship.id.isEmpty)
            #expect(
                !internship.title.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty
            )
        }
    }
}
