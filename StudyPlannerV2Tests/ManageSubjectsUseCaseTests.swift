//
//  ManageSubjectUseCaseTests.swift
//  StudyPlannerV2
//
//  Created by Pichaya Viwatassawin on 28/10/2026.
//

import Foundation
import Testing
@testable import StudyPlannerV2

/// Tests ManageSubjectsUseCase: name required, trimming, empty code saved as nil, no duplicate name or code (ignoring case), delete must exist, and save failure
@MainActor
struct ManageSubjectsUseCaseTests {
    
    // MARK: - Add
    
    @Test func addSubjectWithTrimmedNameAndCode() throws {
        let repository = MockSubjectRepository()
        let useCase = ManageSubjectsUseCase(repository: repository)
        
        let subject = try useCase.add(name: " Advanced iOS ", code: " 40005 ")
        
        #expect(subject.name == "Advanced iOS")
        #expect(subject.code == "40005")
        #expect(repository.subjects.count == 1)
    }
    
    @Test func emptyCodeIsSavedAsNil() throws {
        let repository = MockSubjectRepository()
        let useCase = ManageSubjectsUseCase(repository: repository)
        
        let subject = try useCase.add(name: "Database", code: " ")
        
        #expect(subject.code == nil)
    }
    
    @Test func blankNameThrowsMissingName() {
        let repository = MockSubjectRepository()
        let useCase = ManageSubjectsUseCase(repository: repository)
        
        #expect(throws: ManageSubjectsUseCase.SubjectError.missingName) {
            try useCase.add(name: "  ", code: "40005")
        }
        #expect(repository.subjects.isEmpty)
    }
    
    @Test func duplicateNameIgnoringCaseThrowsDuplicateName() {
        let repository = MockSubjectRepository(subjects: [
            Subject(name: "Advanced iOS", code: "40005")
        ])
        let useCase = ManageSubjectsUseCase(repository: repository)
        
        #expect(throws: ManageSubjectsUseCase.SubjectError.duplicateName) {
            try useCase.add(name: "advanced ios", code: nil)
        }
        
        #expect(repository.subjects.count == 1)
    }
    
    @Test func duplicateNameWithSpacesThrowsDuplicateName() {
        let repository = MockSubjectRepository(subjects: [
            Subject(name: "Advanced iOS", code: "40005")
        ])
        let useCase = ManageSubjectsUseCase(repository: repository)
        
        #expect(throws: ManageSubjectsUseCase.SubjectError.duplicateName) {
            try useCase.add(name: "  advanced ios  ", code: nil)
        }
        
        #expect(repository.subjects.count == 1)
    }
    
    @Test func duplicateCodeIgnoringCaseThrowsDuplicateCode() {
        let repository = MockSubjectRepository(subjects: [
            Subject(name: "Advanced iOS", code: "IOS40005")
        ])
        let useCase = ManageSubjectsUseCase(repository: repository)
        
        #expect(throws: ManageSubjectsUseCase.SubjectError.duplicateCode) {
            try useCase.add(name: "Different Subject", code: "ios40005")
        }
        
        #expect(repository.subjects.count == 1)
    }
    
    @Test func subjectsWithoutCodesAreNotDuplicates() throws {
        let repository = MockSubjectRepository(subjects: [
            Subject(name: "Advanced iOS", code: nil)
        ])
        let useCase = ManageSubjectsUseCase(repository: repository)
        try useCase.add(name: "Image Processing", code: nil)
        
        #expect(repository.subjects.count == 2)
    }
    
    @Test func addSaveFailureThrowsSaveFailed() {
        let repository = MockSubjectRepository()
        repository.shouldFailOnSave = true
        let useCase = ManageSubjectsUseCase(repository: repository)
        
        #expect(throws: ManageSubjectsUseCase.SubjectError.saveFailed) {
            try useCase.add(name: "Advanced iOS", code: "40005")
        }
        
        #expect(repository.subjects.isEmpty)
    }
    
    // MARK: - Update

    @Test func updatesNameAndCodeWithTrimming() throws {
        let subject = Subject(name: "Database", code: nil)
        let repository = MockSubjectRepository(subjects: [subject])
        let useCase = ManageSubjectsUseCase(repository: repository)

        try useCase.update(id: subject.id, name: "  Advanced iOS ", code: " 40005 ")

        #expect(repository.subjects.first?.name == "Advanced iOS")
        #expect(repository.subjects.first?.code == "40005")
        #expect(repository.subjects.first?.id == subject.id)
    }

    @Test func savingWithSameNameIsNotADuplicate() throws {
        let subject = Subject(name: "Advanced iOS", code: "40005")
        let repository = MockSubjectRepository(subjects: [subject])
        let useCase = ManageSubjectsUseCase(repository: repository)

        try useCase.update(id: subject.id, name: "Advanced iOS", code: "40005")

        #expect(repository.subjects.count == 1)
    }

    @Test func renamingToAnotherSubjectsNameThrowsDuplicateName() {
        let ios = Subject(name: "Advanced iOS", code: "40005")
        let imageProcessing = Subject(name: "Image Processing", code: "31256")
        let repository = MockSubjectRepository(subjects: [ios, imageProcessing])
        let useCase = ManageSubjectsUseCase(repository: repository)

        #expect(throws: ManageSubjectsUseCase.SubjectError.duplicateName) {
            try useCase.update(id: imageProcessing.id, name: "advanced ios", code: nil)
        }

        #expect(repository.subjects.last?.name == "Image Processing")
    }

    @Test func updatingWithBlankNameThrowsMissingName() {
        let subject = Subject(name: "Advanced iOS", code: nil)
        let repository = MockSubjectRepository(subjects: [subject])
        let useCase = ManageSubjectsUseCase(repository: repository)

        #expect(throws: ManageSubjectsUseCase.SubjectError.missingName) {
            try useCase.update(id: subject.id, name: "   ", code: nil)
        }

        #expect(repository.subjects.first?.name == "Advanced iOS")
    }

    @Test func updatingUnknownSubjectThrowsSubjectNotFound() {
        let repository = MockSubjectRepository()
        let useCase = ManageSubjectsUseCase(repository: repository)

        #expect(throws: ManageSubjectsUseCase.SubjectError.subjectNotFound) {
            try useCase.update(id: UUID(), name: "Advanced iOS", code: nil)
        }
    }

    @Test func updateSaveFailureThrowsSaveFailed() {
        let subject = Subject(name: "Database", code: nil)
        let repository = MockSubjectRepository(subjects: [subject])
        repository.shouldFailOnSave = true
        let useCase = ManageSubjectsUseCase(repository: repository)

        #expect(throws: ManageSubjectsUseCase.SubjectError.saveFailed) {
            try useCase.update(id: subject.id, name: "Advanced iOS", code: nil)
        }

        #expect(repository.subjects.first?.name == "Database")
    }
    
    @Test func renamingSubjectRenamesItsAssignments() throws {
        let subject = Subject(name: "Database", code: nil)
        let repository = MockSubjectRepository(subjects: [subject])
        let assignmentRepository = MockAssignmentRepository(assignments: [
            Assignment(title: "Report", course: "Database", dueDate: .now, priority: .high, tasks: []),
            Assignment(title: "Essay", course: "Ethics of AI", dueDate: .now, priority: .low, tasks: [])
        ])
        let useCase = ManageSubjectsUseCase(repository: repository, assignmentRepository: assignmentRepository)

        try useCase.update(id: subject.id, name: "Database Systems", code: nil)

        #expect(assignmentRepository.assignments[0].course == "Database Systems")
        #expect(assignmentRepository.assignments[1].course == "Ethics of AI")
    }
    
    @Test func failedAssignmentRenameRestoresSubject() {
        let subject = Subject(name: "Database", code: "31271")
        let repository = MockSubjectRepository(subjects: [subject])
        let assignmentRepository = MockAssignmentRepository(assignments: [
            Assignment(title: "Report", course: "Database", dueDate: .now, priority: .high, tasks: [])
        ])
        assignmentRepository.shouldFailOnSave = true
        let useCase = ManageSubjectsUseCase(repository: repository, assignmentRepository: assignmentRepository)

        #expect(throws: ManageSubjectsUseCase.SubjectError.saveFailed) {
            try useCase.update(id: subject.id, name: "Database Systems", code: "31271")
        }

        #expect(repository.subjects.first?.name == "Database")
        #expect(assignmentRepository.assignments.first?.course == "Database")
    }

    // MARK: - Delete
    
    @Test func deletesExistingSubject() throws {
        let subject = Subject(name: "Advanced iOS", code: "40005")
        let repository = MockSubjectRepository(subjects: [subject])
        let useCase = ManageSubjectsUseCase(repository: repository)
        
        try useCase.delete(id: subject.id)
        
        #expect(repository.subjects.isEmpty)
    }
    
    @Test func deletingOneSubjectKeepsTheOther() throws {
        let ios = Subject(name: "Advanced iOS", code: "40005")
        let imageProcessing = Subject(name: "Image Processing", code: "31256")
        let repository = MockSubjectRepository(subjects: [ios, imageProcessing])
        let useCase = ManageSubjectsUseCase(repository: repository)
        
        try useCase.delete(id: ios.id)
        
        #expect(repository.subjects.count == 1)
        #expect(repository.subjects.first?.id == imageProcessing.id)
    }
    
    @Test func deletingUnknownSubjectThrowsSubjectNotFound() {
        let repository = MockSubjectRepository()
        let useCase = ManageSubjectsUseCase(repository: repository)
        
        #expect(throws: ManageSubjectsUseCase.SubjectError.subjectNotFound) {
            try useCase.delete(id: UUID())
        }
    }
    
    @Test func deleteSaveFailureThrowsSaveFailed() {
        let subject = Subject(name: "Advanced iOS", code: "40005")
        let repository = MockSubjectRepository(subjects: [subject])
        repository.shouldFailOnSave = true
        let useCase = ManageSubjectsUseCase(repository: repository)
        
        #expect(throws: ManageSubjectsUseCase.SubjectError.saveFailed) {
            try useCase.delete(id: subject.id)
        }
        
        #expect(repository.subjects.count == 1)
    }
}
