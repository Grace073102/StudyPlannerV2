//
//  StoredMigration.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 16/10/2026.
//

import Foundation
import SwiftData

@Model
final class StoredMigration {
    @Attribute(.unique) var id: String
    var completedAt: Date

    init(id: String) {
        self.id = id
        completedAt = Date()
    }
}
