//
//  ApplicationStatusDisplay.swift
//  StudyPlannerV2
//
//  Created by emily zhang on 21/10/2026.
//

import SwiftUI

extension ApplicationStatus {

    var icon: String {
        switch self {
        case .saved:        "bookmark.fill"
        case .applied:      "paperplane.fill"
        case .interviewing: "person.2.fill"
        case .offered:      "star.fill"
        case .rejected:     "xmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .saved:        .blue
        case .applied:      .orange
        case .interviewing: .purple
        case .offered:      .green
        case .rejected:     .red
        }
    }
}
