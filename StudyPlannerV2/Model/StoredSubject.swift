//
//  StoredSubject.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 17/10/2026.
//

import Foundation
import SwiftData

@Model
final class StoredSubject {
    @Attribute(.unique) var id: UUID
    var name: String
    var code: String?

    init(subject: Subject) {
        id = subject.id
        name = subject.name
        code = subject.code
    }

    func toSubject() -> Subject {
        Subject(
            id: id,
            name: name,
            code: code
        )
    }
}
