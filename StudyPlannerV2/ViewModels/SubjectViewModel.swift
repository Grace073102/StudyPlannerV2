//
//  SubjectViewModel.swift
//  StudyPlannerV2
//
//  Created by Pichaya Viwatassawin on 22/10/2026.
//

import Foundation
import Combine

/// Holds the student's subjects for the Subjects screen.
/// Uses ManageSubjectsUseCase for all changes.
final class SubjectViewModel: ObservableObject {

    @Published private(set) var subjects: [Subject] = []

    // Message for the last action that failed, shown in an alert.
    @Published var errorMessage: String?

    private let repository: SubjectRepository
    private let manageSubjects: ManageSubjectsUseCase

    init(repository: SubjectRepository) {
        self.repository = repository
        self.manageSubjects = ManageSubjectsUseCase(repository: repository)
        loadSubjects()
    }

    func loadSubjects() {
        subjects = repository.load()
    }

    // Returns true if the subject was added, so the view knows whether to close the form.
    @discardableResult
    func addSubject(name: String, code: String) -> Bool {
        do {
            try manageSubjects.add(name: name, code: code)
            loadSubjects()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deleteSubject(id: UUID) {
        do {
            try manageSubjects.delete(id: id)
            loadSubjects()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
