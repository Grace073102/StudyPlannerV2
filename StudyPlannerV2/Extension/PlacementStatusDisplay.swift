//
//  PlacementStatusDisplay.swift
//  StudyPlannerV2
//
//  Created by emily zhang on 21/10/2026.
//

import SwiftUI

extension Placement.Status {

    var displayName: String {
        switch self {
        case .upcoming:   "Upcoming"
        case .inProgress: "In Progress"
        case .completed:  "Completed"
        }
    }

    var icon: String {
        switch self {
        case .upcoming:   "clock"
        case .inProgress: "play.circle.fill"
        case .completed:  "checkmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .upcoming:   .blue
        case .inProgress: .orange
        case .completed:  .green
        }
    }
}
