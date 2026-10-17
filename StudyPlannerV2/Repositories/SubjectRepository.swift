//
//  SubjectRepository.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 17/10/2026.
//

import Foundation

protocol SubjectRepository {
    var subjects: [Subject] { get }
    var errorMessage: String? { get }

    func load() -> [Subject]
    func add(_ subject: Subject)
    func update(_ subject: Subject)
    func delete(_ subject: Subject)
}
