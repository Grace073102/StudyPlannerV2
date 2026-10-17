//
//  StoredPlacement.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 17/10/2026.
//

import Foundation
import SwiftData

@Model
final class StoredPlacement {
    @Attribute(.unique) var id: UUID
    var name: String
    var discipline: String
    var startDate: Date
    var endDate: Date
    var placementDescription: String?

    init(placement: Placement) {
        id = placement.id
        name = placement.name
        discipline = placement.discipline
        startDate = placement.startDate
        endDate = placement.endDate
        placementDescription = placement.description
    }

    func toPlacement() -> Placement {
        var placement = Placement(
            id: id,
            name: name,
            discipline: discipline,
            startDate: startDate,
            endDate: endDate
        )

        placement.description = placementDescription
        return placement
    }
}
