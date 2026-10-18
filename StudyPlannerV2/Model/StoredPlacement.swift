//
//  StoredPlacement.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 17/10/2026.
//

/// A placement or internship the student has secured and is preparing for or completing.
///
/// Created and managed by the student; CampusFlow does not verify it with the university.
import Foundation
import SwiftData

typealias Placement = StoredPlacement

@Model
final class StoredPlacement {
    @Attribute(.unique) var id: UUID
    var name: String
    var discipline: String
    var startDate: Date
    var endDate: Date
    var placementDescription: String?
    var subjectID: UUID?

    @Relationship(deleteRule: .cascade, inverse: \StoredPlacementRequirement.placement)
    var requirements: [StoredPlacementRequirement] = []

    var description: String? {
        get { placementDescription }
        set { placementDescription = newValue }
    }

    enum Status: String, Sendable {
        case upcoming, inProgress, completed
    }

    init(
        id: UUID = UUID(),
        name: String,
        discipline: String,
        startDate: Date,
        endDate: Date,
        description: String = "",
        subjectID: UUID? = nil
    ) {
        self.id = id
        self.name = name
        self.discipline = discipline
        self.startDate = startDate
        self.endDate = endDate
        placementDescription = description
        self.subjectID = subjectID
    }

    func status(on date: Date, calendar: Calendar = .current) -> Status {
        let day = calendar.startOfDay(for: date)
        if day < calendar.startOfDay(for: startDate) { return .upcoming }
        if day > calendar.startOfDay(for: endDate) { return .completed }
        return .inProgress
    }

    init(placement: Placement) {
        id = placement.id
        name = placement.name
        discipline = placement.discipline
        startDate = placement.startDate
        endDate = placement.endDate
        placementDescription = placement.description
        subjectID = placement.subjectID
    }

    func toPlacement() -> Placement {
        let placement = Placement(
            id: id,
            name: name,
            discipline: discipline,
            startDate: startDate,
            endDate: endDate,
            subjectID: subjectID
        )

        placement.description = placementDescription
        return placement
    }
}
