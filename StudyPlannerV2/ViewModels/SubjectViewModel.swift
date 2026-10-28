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

    private let manageSubjects: ManageSubjectsUseCase
    private let fetchSubjects: FetchSubjectsUseCase

    init(repository: SubjectRepository, assignmentRepository: AssignmentRepository? = nil) {
        self.manageSubjects = ManageSubjectsUseCase(
            repository: repository,
            assignmentRepository: assignmentRepository
        )
        self.fetchSubjects = FetchSubjectsUseCase(repository: repository)
        loadSubjects()
    }

    func loadSubjects() {
        do {
            subjects = try fetchSubjects.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
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
    
    // Returns true if the subject was updated, so the view knows whether to close the form.
    @discardableResult
    func updateSubject(id: UUID, name: String, code: String) -> Bool {
        do {
            try manageSubjects.update(id: id, name: name, code: code)
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
    
    func addSubjectIfNeeded(name: String) {
        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        for subject in subjects {
            if subject.name.lowercased() == cleanedName.lowercased() {
                return
            }
        }
        
        addSubject(name: cleanedName, code: "")
    }
}
