//
//  ManageSubjectsUseCase.swift
//  StudyPlannerV2
//
//  Created by Pichaya Viwatassawin on 22/10/2026.
//

import Foundation

/// Adds and deletes the student's subjects.
/// ViewModel calls this type and never touches the repository directly.
///
/// Business rules:
/// 1. A subject must have a name (blank/space only is rejected).
/// 2. Name and code are trimmed before saving; an empty code is saved as nil.
/// 3. Two subjects can't have the same name or the same code.
/// 4. Only an existing subject can be deleted.
/// 5. Editing follows the same rules, ignoring the subject being edited when checking duplicates.
struct ManageSubjectsUseCase {
    let repository: SubjectRepository
    
    enum SubjectError: LocalizedError, Equatable {
        case missingName
        case duplicateName
        case duplicateCode
        case subjectNotFound
        case saveFailed
        
        var errorDescription: String? {
            switch self {
            case .missingName:
                return "Enter a subject name."
            case .duplicateName:
                return "You already have a subject with this name."
            case .duplicateCode:
                return "You already have a subject with this code."
            case .subjectNotFound:
                return "This subject could not be found."
            case .saveFailed:
                return "Your subject could not be saved. Please try again."
            }
        }
    }
    
    @discardableResult
    func add(name: String, code: String?) throws -> Subject {
        let(cleanedName, cleanedCode) = try validate(name: name, code: code, editingID: nil)
        
        let subject = Subject(name: cleanedName, code: cleanedCode)
        repository.add(subject)
        
        if repository.errorMessage != nil {
            throw SubjectError.saveFailed
        }
        
        return subject
    }
    
    func delete(id: UUID) throws {
        // Rule 4: must exist
        let found = try findSubject(id: id)
        repository.delete(found)
        
        if repository.errorMessage != nil {
            throw SubjectError.saveFailed
        }
    }
    
    
    func update(id: UUID, name: String, code: String?) throws {
        // Rule 4: must exist
        let found = try findSubject(id: id)

        let (cleanedName, cleanedCode) = try validate(name: name, code: code, editingID: id)

        // New copy with the same ID, instead of editing the stored one directly
        let updated = Subject(id: found.id, name: cleanedName, code: cleanedCode)
        repository.update(updated)

        if repository.errorMessage != nil {
            throw SubjectError.saveFailed
        }
    }

    // MARK: - Helpers

    /// Rules 1–3, shared by add and update.
    /// editingID skips that subject in the duplicate check (nil when adding).
    private func validate(name: String, code: String?, editingID: UUID?) throws -> (String, String?) {
        // Rule 2: trim whitespace and empty code = nil
        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCode = code?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let cleanedCode: String? = trimmedCode.isEmpty ? nil : trimmedCode

        // Rule 1: name required
        guard !cleanedName.isEmpty else {
            throw SubjectError.missingName
        }

        // Rule 3: no duplicate name or code
        for existing in repository.subjects where existing.id != editingID {
            if existing.name.lowercased() == cleanedName.lowercased() {
                throw SubjectError.duplicateName
            }
            if let cleanedCode, let existingCode = existing.code,
               existingCode.lowercased() == cleanedCode.lowercased() {
                throw SubjectError.duplicateCode
            }
        }

        return (cleanedName, cleanedCode)
    }

    /// Rule 4: finds the subject, or throws if it doesn't exist.
    private func findSubject(id: UUID) throws -> Subject {
        for subject in repository.subjects where subject.id == id {
            return subject
        }
        throw SubjectError.subjectNotFound
    }
    
}
