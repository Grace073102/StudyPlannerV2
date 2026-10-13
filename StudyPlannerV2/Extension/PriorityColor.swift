//
//  PriorityColor.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 14/10/2026.
//

import SwiftUI

extension Assignment.Priority {

    var color: Color {
        switch self {
        case .high:
            return .red

        case .medium:
            return .orange

        case .low:
            return .green
        }
    }
}
