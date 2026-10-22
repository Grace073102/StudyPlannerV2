//
//  SavedInternshipViewModel.swift
//  StudyPlannerV2
//
//  Created by emily zhang on 19/10/2026.
//

import Foundation
import Combine
 
/// Manages saved internship opportunities displayed in the app.
/// Uses ManageSavedInternshipsUseCase to perform internship operations.
@MainActor
final class SavedInternshipViewModel: ObservableObject {
 
    /// Internship opportunities saved by the student.
    @Published private(set) var internships: [SavedInternship] = []
 
    /// Message for the last operation that failed (load, save, update or delete).
    /// Clear it with clearError() when a form opens or closes.
    @Published var errorMessage: String?
    private let useCase: ManageSavedInternshipsUseCase
 
    /// Creates the ViewModel with a saved internship repository.
    init(repository: SavedInternshipRepository) {
        self.useCase = ManageSavedInternshipsUseCase(repository: repository)
        loadInternships()
    }
    
    /// Loads saved internship opportunities.
    func loadInternships() {
        do {
            internships = try useCase.fetchAll()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Saves an internship opportunity and refreshes the list.
    /// Returns true if the internship was saved successfully.
    @discardableResult
    func saveInternship(_ internship: SavedInternship) -> Bool {
        do {
            try useCase.save(internship)
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
        loadInternships()
        return true
    }
    
    /// Updates an internship's application status and refreshes the list.
    /// Returns true if the status was updated successfully.
    @discardableResult
    func updateApplicationStatus(
        id: UUID,
        to status: ApplicationStatus) -> Bool {
        do {
            try useCase.updateApplicationStatus(id: id, to: status)
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
        loadInternships()
        return true
    }
    
    /// Deletes a saved internship and refreshes the list.
    /// Returns true if the internship was deleted successfully.
    @discardableResult
    func deleteInternship(id: UUID) -> Bool {
        do {
            try useCase.delete(id: id)
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
        loadInternships()
        return true
    }
    
    /// Clears the error message, for example when a form opens or is dismissed.
    func clearError() {
        errorMessage = nil
    }
}
