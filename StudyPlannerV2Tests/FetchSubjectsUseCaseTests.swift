//
//  FetchSubjectsUseCaseTests.swift
//  StudyPlannerV2
//
//  Created by emily zhang on 26/10/2026.
//

import Foundation
import Testing
@testable import StudyPlannerV2
 
/// Tests subject fetching, sorting and repository errors.

@MainActor
struct FetchSubjectsUseCaseTests {
    
    // MARK: - Fetch
    /// Returns all subjects stored in the repository.
    @Test func fetchSubjectsReturnsAllSubjects() throws {
        let repository = MockSubjectRepository(subjects: [
            Subject(name: "Professional Experience 1"),
            Subject(name: "English Education 1")
        ])
        
        // Execute and verify that all subjects are returned in alphabetical order
        let useCase = FetchSubjectsUseCase(repository: repository)
        let results = try useCase.execute()
        #expect(results.count == 2)
        #expect(results.map(\.name) == ["English Education 1", "Professional Experience 1"])
    }
    
    /// Returns an empty array when no subjects exist.
    @Test func fetchSubjectsWhenEmptyReturnsEmptyArray() throws {
        let repository = MockSubjectRepository()
        
        // Execute and verify that an empty array is returned when there are no subjects
        let useCase = FetchSubjectsUseCase(repository: repository)
        let results = try useCase.execute()
        #expect(results.isEmpty)
    }
    
    // MARK: - Sorting
    /// Sorts subjects alphabetically, ignoring uppercase and lowercase.
    @Test func fetchSubjectsSortsAlphabetically() throws {
        let repository = MockSubjectRepository(subjects: [
            Subject(name: "English Education 1"),
            Subject(name: "Visual arts education"),
            Subject(name: "child development")
        ])
        
        // Execute and verify that subjects are sorted alphabetically, regardless of their original order
        let useCase = FetchSubjectsUseCase(repository: repository)
        let results = try useCase.execute()
        #expect(results.map(\.name) == ["child development", "English Education 1", "Visual arts education"])
    }
    
    // MARK: - Repository Errors
    /// Throws a loadFailed error when the repository cannot load subjects.
    @Test func fetchSubjectsWhenRepositoryFailsThrowsError() {
        let repository = MockSubjectRepository()
        repository.shouldFailOnLoad = true
        
        let useCase = FetchSubjectsUseCase(repository: repository)
        
        // Expect a loadFailed error when fetching subjects
        #expect(throws: FetchSubjectsError.loadFailed("Failed to load subjects.")) {
            try useCase.execute()
        }
    }
    
    /// Returns the only subject when the repository contains one.
    @Test func fetchSubjectsWithOneSubjectReturnsIt() throws {
        let repository = MockSubjectRepository(subjects: [
            Subject(name: "English Education 1")
        ])
        let useCase = FetchSubjectsUseCase(repository: repository)
        
        // Execute and verify the single subject is returned
        let results = try useCase.execute()
        #expect(results.count == 1)
        #expect(results.first?.name == "English Education 1")
    }
    
    /// Works again after a failed load, with no old error left over.
    @Test func fetchSubjectsAfterFailureWorksAgainOnceRepositoryRecovers() throws {
        let repository = MockSubjectRepository(subjects: [Subject(name: "English Education 1")])
        let useCase = FetchSubjectsUseCase(repository: repository)
        repository.shouldFailOnLoad = true
        
        // Expect an error when the repository fails to load subjects
        #expect(throws: FetchSubjectsError.self) {try useCase.execute()}
        
        // Verify fetching succeeds after the repository recovers
        repository.shouldFailOnLoad = false
        let results = try useCase.execute()
        #expect(results.map(\.name) == ["English Education 1"])
    }
}
