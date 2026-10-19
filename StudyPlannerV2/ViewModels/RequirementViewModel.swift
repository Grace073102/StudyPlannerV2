//
//  RequirementViewModel.swift
//  StudyPlannerV2
//
//  Created by Djy on 15/10/2026.
//

import Foundation
import Combine

final class RequirementViewModel: ObservableObject {
    
    @Published private(set) var requirements: [PlacementRequirement] = []
    
    @Published private(set) var repositoryErrorMessage: String?
    
    private let repository: RequirementRepository
    private let addRequirementUseCase: AddRequirementUseCase
    
    init(repository: RequirementRepository) {
        
        self.repository = repository
        self.addRequirementUseCase = AddRequirementUseCase(repository: repository)
        
        loadRequirements()
    }
    
    func loadRequirements() {
        do {
            requirements = try repository.load()
            repositoryErrorMessage = nil
        } catch {
            repositoryErrorMessage = error.localizedDescription
        }
    }
    
    func requirements(for placementID: UUID) -> [PlacementRequirement] {
        requirements.filter {
            $0.placementID == placementID
        }
    }
    
    
    func add(
        placementID: UUID,
        name: String,
        category: PlacementRequirement.Category,
        dueDate: Date?,
        expiryDate: Date?
    ) throws {
        let requirement = try addRequirementUseCase.execute(

            placementID: placementID,
            name: name,
            category: category,
            dueDate: dueDate,
            expiryDate: expiryDate
        )
        loadRequirements()

        Task {
            do {
                let granted = try await RequirementNotificationManager.shared.requestPermission()

                if granted {
                    try await RequirementNotificationManager.shared.scheduleNotifications(
                        for: requirement
                    )
                }
            } catch {
                print("Notification scheduling failed: \(error.localizedDescription)")
            }
        }
    }
    
    func updateRequirement(
        id: UUID,
        name: String,
        category: PlacementRequirement.Category,
        dueDate: Date?,
        expiryDate: Date?
    ) throws {

        let useCase = UpdateRequirementUseCase(
            repository: repository
        )

        try useCase.execute(
            id: id,
            name: name,
            category: category,
            dueDate: dueDate,
            expiryDate: expiryDate
        )
        loadRequirements()

        if let updatedRequirement = requirements.first(where: { $0.id == id }) {
            Task {
                do {
                    try await RequirementNotificationManager.shared.scheduleNotifications(
                        for: updatedRequirement
                    )
                } catch {
                    print("Failed to update notifications: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func deleteRequirement(id: UUID) throws {
        let useCase = DeleteRequirementUseCase(repository: repository)

        try useCase.execute(id: id)

        RequirementNotificationManager.shared.removeNotifications(for: id)
        loadRequirements()
    }

    
    func completedCount(for placementID: UUID) -> Int {
        requirements(for: placementID).filter {
            $0.isCompleted
        }.count
    }
    
    func progress(for placementID: UUID) -> Double {
        let placementRequirements = requirements(for: placementID)
        
        guard !placementRequirements.isEmpty else {
            return 0
        }
        
        let completed = placementRequirements.filter {
            $0.isCompleted
        }.count
        
        return Double(completed) / Double(placementRequirements.count)
    }
    
    
    func toggleCompletion(for requirement: PlacementRequirement) {
        let useCase = ToggleRequirementCompletionUseCase(repository: repository)

        do {
            let updatedRequirement = try useCase.execute(id: requirement.id)

            loadRequirements()

            Task {
                do {
                    try await RequirementNotificationManager.shared
                        .scheduleNotifications(for: updatedRequirement)
                } catch {
                    print("Failed to schedule requirement notifications: \(error)")
                }
            }

        } catch {
            repositoryErrorMessage = error.localizedDescription
        }
    }
    
    func clearRepositoryError() {
        repositoryErrorMessage = nil
    }
}

struct RequirementPersistenceError: LocalizedError {
    let message: String

    var errorDescription: String? {
        message
    }
}

enum RequirementValidationError: LocalizedError {
    case emptyName
    case notFound
    case invalidDueDate

    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Please enter a requirement name."

        case .notFound:
            return "This requirement could not be found."
            
        case .invalidDueDate:
            return "The due date cannot be in the past. Choose today or a future date."
        }
    }
}
