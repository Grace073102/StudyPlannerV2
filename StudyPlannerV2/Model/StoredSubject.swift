//
//  StoredSubject.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 17/10/2026.
//

import Foundation
import SwiftData

typealias Subject = StoredSubject

@Model
final class StoredSubject {
    @Attribute(.unique) var id: UUID
    var name: String
    var code: String?

    init(id: UUID = UUID(), name: String, code: String? = nil) {
        self.id = id
        self.name = name
        self.code = code
    }

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
