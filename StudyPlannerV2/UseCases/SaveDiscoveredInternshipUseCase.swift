//
//  SaveDiscoveredInternshipUseCase.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 24/10/2026.
//

import Foundation

@MainActor
struct SaveDiscoveredInternshipUseCase {
    let savedInternships: ManageSavedInternshipsUseCase

    func save(_ listing: DiscoveredInternship) throws {
        let internship = SavedInternship(
            jobID: listing.savedJobID,
            title: listing.title,
            company: listing.company?.name ?? "",
            location: listing.location,
            applicationURL: listing.applicationURL,
            applicationDeadline: nil,
            applicationStatus: .saved
        )

        try savedInternships.save(internship)
    }
}
