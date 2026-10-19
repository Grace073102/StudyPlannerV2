//
//  ManagePlacementsUseCase.swift
//  StudyPlannerV2
//
//  Created by emily zhang on 17/10/2026.
//

import Foundation

/// Applies all business rules for the student's placements and internships.
/// The ViewModel calls this type and never touches the repository directly.
///
/// Business rules
/// 1. A placement must have a name and a discipline (blank or spaces only is rejected).
/// 2. The end date cannot be before the start date; a same-day placement is allowed.
/// 3. Names and disciplines are trimmed before they are saved.
/// 4. A placement may optionally be linked to a subject; without one it is saved as is.
/// 5. Only an existing placement can be updated or deleted.
/// 6. A placement's status (upcoming, in progress, completed) is derived from its dates.
/// 7. Placements are listed with the earliest start date first.
/// 8. Requirement reminders are cancelled only after placement deletion saves successfully.

struct ManagePlacementsUseCase {

    enum PlacementError: LocalizedError, Equatable {
        case emptyName
        case emptyDiscipline
        case invalidDates
        case placementNotFound

        var errorDescription: String? {
            switch self {
            case .emptyName:         "Enter a placement name."
            case .emptyDiscipline:   "Enter a discipline."
            case .invalidDates:      "The end date cannot be before the start date."
            case .placementNotFound: "This placement could not be found."
            }
        }
    }

    /// A placement together with its status, ready for the UI to display.
    struct PlacementSummary: Identifiable {
        let placement: Placement
        let status: Placement.Status
        var id: UUID { placement.id }
    }

    let repository: PlacementRepository
    let loadRequirementIDs: (UUID) throws -> [UUID]
    let cancelRequirementNotifications: (UUID) -> Void
    
    // MARK: - Business Logic
    ///
    /// Returns all placements with their status on the given date, earliest start first.
    /// - Throws: `PlacementRepositoryError.loadFailed`.
    func fetchAll(on date: Date = Date(),
                  calendar: Calendar = .current) throws -> [PlacementSummary] {
        try repository.load()
            .sorted { $0.startDate < $1.startDate }
            .map { PlacementSummary(placement: $0,
                                    status: $0.status(on: date, calendar: calendar)) }
    }

    /// Creates a placement after validating and trimming it.
    /// - Throws: `PlacementError.emptyName`, `.emptyDiscipline`, `.invalidDates`,
    ///   or `PlacementRepositoryError.saveFailed`.
    func add(_ placement: Placement) throws {
        try repository.add(try validated(placement))
    }

    /// Updates an existing placement after validating and trimming it.
    /// - Throws: the same validation errors as `add`, `PlacementError.placementNotFound`, or `PlacementRepositoryError.saveFailed`.
    func update(_ placement: Placement) throws {
        let cleaned = try validated(placement)
        guard try repository.load().contains(where: { $0.id == cleaned.id }) else {
            throw PlacementError.placementNotFound
        }
        try repository.update(cleaned)
    }

    /// Deletes a placement and cancels its requirement reminders after saving.
    /// If loading or deleting fails, reminders remain unchanged.
    /// - Throws: `PlacementError.placementNotFound` or `PlacementRepositoryError.saveFailed`.
    func delete(id: UUID) throws {
        guard let placement = try repository.load().first(where: {
            $0.id == id
        }) else {
            throw PlacementError.placementNotFound
        }

        // Collect IDs before cascade deletion removes the requirements.
        let requirementIDs = try loadRequirementIDs(id)

        // If this throws, reminder cancellation is skipped.
        try repository.delete(placement)

        for requirementID in requirementIDs {
            cancelRequirementNotifications(requirementID)
        }
    }

    // MARK: - Rules

    /// Checks the rules and returns a trimmed copy. Placement is a class, so a new object is built instead of changing the one passed in.
    private func validated(_ placement: Placement) throws -> Placement {
        // Trim text
        let name = placement.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let discipline = placement.discipline.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Rule 1: name and discipline can’t be blank
        guard !name.isEmpty else { throw PlacementError.emptyName }
        guard !discipline.isEmpty else { throw PlacementError.emptyDiscipline }
        
        // Rule 2: the end date can’t be before the start date
        guard Calendar.current.startOfDay(for: placement.endDate)
                >= Calendar.current.startOfDay(for: placement.startDate)
        else { throw PlacementError.invalidDates }
        
        // Build cleaned copy
        return Placement(
            id: placement.id,
            name: name,
            discipline: discipline,
            startDate: placement.startDate,
            endDate: placement.endDate,
            description: placement.description ?? "",
            subjectID: placement.subjectID
        )
    }
}
