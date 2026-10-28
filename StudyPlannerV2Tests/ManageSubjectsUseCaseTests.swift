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
