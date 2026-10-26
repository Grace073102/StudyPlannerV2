//
//  InternshipDiscoveryViewModel.swift
//  StudyPlannerV2
//
//  Created by emily zhang on 24/10/2026.
//

import Foundation
import Combine

/// Manages internship search results, loading states, and saved internships.
/// Connects the internship discovery screen to the search repository and save use case.
/// It keeps track of search results, supports loading additional pages, and updates the saved state of each listing.
@MainActor
final class InternshipDiscoveryViewModel: ObservableObject {

    @Published private(set) var opportunities: [DiscoveredInternship] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingMore = false
    @Published private(set) var hasSearched = false
    @Published private(set) var nextCursor: String?
    @Published private(set) var savedJobIDs: Set<String> = []
    @Published private(set) var searchErrorMessage: String?
    
    // The view can use this message to present an alert
    @Published var saveErrorMessage: String?

    @Published var searchText = ""
    @Published var remoteOnly = false

    private let repository: (any InternshipDiscoveryRepository)?
    private let saveUseCase: SaveDiscoveredInternshipUseCase
    private let unavailableMessage: String

    /// The search query associated with the current results.
    /// This query is reused when requesting additional pages.
    private var activeSearch = InternshipSearch()
    
    /// A counter used to identify the most recent search request.
    /// Responses from older searches are ignored so they cannot replace results from a newer search.
    private var searchID = 0
    
    /// Creates a view model with a repository for searching internships, a use case for saving internships, and an optional message for when searching is unavailable.
    init(
        repository: (any InternshipDiscoveryRepository)?,
        saveUseCase: SaveDiscoveredInternshipUseCase,
        unavailableMessage: String = "Internship search isn't available right now."
    ) {
        self.repository = repository
        self.saveUseCase = saveUseCase
        self.unavailableMessage = unavailableMessage
    }

    // MARK: - Search
    /// Searches for internships using the current search text and filters.
    func search() async {
        guard let repository else {
            searchErrorMessage = unavailableMessage
            hasSearched = true
            return
        }

        searchID += 1
        let id = searchID
        let query = InternshipSearch(title: searchText, remoteOnly: remoteOnly)

        isLoading = true
        searchErrorMessage = nil

        // Only the newest search ends the loading state
        defer {
            if id == searchID {
                isLoading = false
            }
        }

        do {
            let page = try await repository.search(query)
            guard id == searchID else { return } 
            activeSearch = query
            opportunities = page.data
            nextCursor = page.pagination.nextPage
            hasSearched = true
        } catch {
            guard id == searchID else { return }
            // A cancelled search does not mark the search as completed when it fails due to cancellation
            if !Self.isCancellation(error) {
                searchErrorMessage = error.localizedDescription
                hasSearched = true
            }
        }
    }
    
    /// Loads the next page of results for the current search.
    func loadMore() async {
        guard let repository,
              let cursor = nextCursor,
              !isLoadingMore,
              !isLoading else { return }

        let id = searchID
        var query = activeSearch
        query.cursor = cursor

        isLoadingMore = true
        defer { isLoadingMore = false }
        
        // Listings with IDs that are already present are not added again
        // The request is skipped if another search or page load is in progress
        do {
            let page = try await repository.search(query)
            guard id == searchID else { return }
            let existing = Set(opportunities.map(\.id))
            opportunities.append(contentsOf: page.data.filter { !existing.contains($0.id) })
            nextCursor = page.pagination.nextPage
        } catch {
            guard id == searchID, !Self.isCancellation(error) else { return }
            searchErrorMessage = error.localizedDescription
        }
    }

    // MARK: - Save
    /// Checks whether an internship has already been saved.
    func isSaved(_ listing: DiscoveredInternship) -> Bool {
        savedJobIDs.contains(listing.savedJobID)
    }

    /// If the internship has already been saved, it is still marked as saved.
    func save(_ listing: DiscoveredInternship) {
        do {
            try saveUseCase.save(listing)
            savedJobIDs.insert(listing.savedJobID)
        } catch ManageSavedInternshipsUseCase.SavedInternshipError.alreadySaved {
            savedJobIDs.insert(listing.savedJobID)
        } catch {
            saveErrorMessage = error.localizedDescription
        }
    }
    
    /// Refreshes the saved internship IDs from the saved internship store.
    func refreshSavedState() {
        do {
            let saved = try saveUseCase.savedInternships.fetchAll()
            savedJobIDs = Set(saved.map(\.jobID))
        } catch {
            saveErrorMessage = error.localizedDescription
        }
    }

    // MARK: - Helpers
    /// Determines whether an error represents a cancelled request.
    private static func isCancellation(_ error: Error) -> Bool {
        error is CancellationError || (error as? URLError)?.code == .cancelled
    }
}
