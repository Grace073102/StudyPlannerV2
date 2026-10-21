//
//  PlacementViewModel.swift
//  StudyPlannerV2
//
//  Created by emily zhang on 19/10/2026.
//

import Foundation
import Combine

/// Manages placement information displayed in the app.
/// Uses ManagePlacementsUseCase to perform placement operations.
@MainActor
final class PlacementViewModel: ObservableObject {

    /// Placements and their current statuses.
    @Published private(set) var placements: [ManagePlacementsUseCase.PlacementSummary] = []

    /// Message for the last operation that failed (load, add, update or delete).
    /// Clear it with clearError() when a form opens or closes.
    @Published var errorMessage: String?

    private let useCase: ManagePlacementsUseCase

    /// Creates the ViewModel with a placement repository.
    init(repository: PlacementRepository) {
        self.useCase = ManagePlacementsUseCase(repository: repository)
        loadPlacements()
    }

    /// Loads placements and their current statuses.
    func loadPlacements() {
        do {
            placements = try useCase.fetchAll()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Adds a placement and refreshes the list. Returns true if it was saved.
    @discardableResult
    func addPlacement(_ placement: Placement) -> Bool {
        do {
            try useCase.add(placement)
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
        loadPlacements()
        return true
    }

    /// Updates a placement and refreshes the list. Returns true if it was updated.
    @discardableResult
    func updatePlacement(_ placement: Placement) -> Bool {
        do {
            try useCase.update(placement)
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
        loadPlacements()
        return true
    }

    /// Deletes a placement and refreshes the list. Returns true if it was deleted.
    @discardableResult
    func deletePlacement(id: UUID) -> Bool {
        do {
            try useCase.delete(id: id)
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
        loadPlacements()
        return true
    }

    /// Clears the error message, for example when a form opens or is dismissed.
    func clearError() {
        errorMessage = nil
    }
}
