//
//  Subject.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 17/10/2026.
//

import Foundation

struct Subject: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var code: String?

    init(
        id: UUID = UUID(),
        name: String,
        code: String? = nil
    ) {
        self.id = id
        self.name = name
        self.code = code
    }
}
