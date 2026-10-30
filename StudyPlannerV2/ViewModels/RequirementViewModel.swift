//
//  RequirementViewModel.swift
//  StudyPlannerV2
//
//  Created by Djy on 15/10/2026.
//

import Foundation
import Combine

@MainActor
final class RequirementViewModel: ObservableObject {
    
    @Published private(set) var requirements: [PlacementRequirement] = []
    
    @Published private(set) var repositoryErrorMessage: String?
    @Published private(set) var notificationErrorMessage: String?
    @Published private(set) var attachmentCleanupWarning: String?
    
    private let repository: RequirementRepository
    private let addRequirementUseCase: AddRequirementUseCase
    private var repositoryChanges: AnyCancellable?
    
    init(repository: RequirementRepository) {
        
        self.repository = repository
        self.addRequirementUseCase = AddRequirementUseCase(repository: repository)
        
        loadRequirements()
        repositoryChanges = repository.changes.sink { [weak self] in
            self?.loadRequirements()
        }
    }
    
    func loadRequirements() {
        do {
            requirements = try repository.load()
            repositoryErrorMessage = nil
        } catch {
            repositoryErrorMessage = error.localizedDescription
        }
    }
    
    private func reloadRequirements() throws {
        do {
            requirements = try repository.load()
            repositoryErrorMessage = nil
        } catch {
            let message = "Your changes were saved, but the requirements could not be refreshed. Please reopen the page to check the latest information."

            throw RequirementPersistenceError(message: message)
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
        try reloadRequirements()

        if requirement.dueDate != nil || requirement.expiryDate != nil {
            Task {
                do {
                    let granted = try await RequirementNotificationManager.shared.requestPermission()
                    
                    guard granted else {
                        notificationErrorMessage = "The requirement was saved, but notifications are disabled. You can enable them in Settings to receive reminders."
                        return
                    }
                    
                    try await RequirementNotificationManager.shared.scheduleNotifications(for: requirement)
                    notificationErrorMessage = nil
                    
                } catch {
                    notificationErrorMessage = "The requirement was saved, but its reminder could not be scheduled. \(error.localizedDescription)"
                }
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
        try reloadRequirements()

        if let updatedRequirement = requirements.first(where: { $0.id == id }) {

            if updatedRequirement.dueDate == nil && updatedRequirement.expiryDate == nil {

                RequirementNotificationManager.shared.removeNotifications(for: id)
                notificationErrorMessage = nil

            } else {

                Task {
                    do {
                        let granted = try await RequirementNotificationManager.shared.requestPermission()

                        guard granted else {
                            RequirementNotificationManager.shared.removeNotifications(for: id)

                            notificationErrorMessage = "The requirement was saved, but notifications are disabled. You can enable them in Settings to receive reminders."
                            return
                        }

                        try await RequirementNotificationManager.shared.scheduleNotifications(for: updatedRequirement)
                        notificationErrorMessage = nil

                    } catch {
                        notificationErrorMessage = "The requirement was saved, but its reminder could not be scheduled. \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    func deleteRequirement(id: UUID) throws {
        let useCase = DeleteRequirementUseCase(repository: repository)

        attachmentCleanupWarning = nil

        let cleanupWarning = try useCase.execute(id: id)

        RequirementNotificationManager.shared.removeNotifications(for: id)
        requirements.removeAll { $0.id == id }

        loadRequirements()
        attachmentCleanupWarning = cleanupWarning
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

            try reloadRequirements()

            if (updatedRequirement.isCompleted || updatedRequirement.dueDate == nil) && updatedRequirement.expiryDate == nil {
                RequirementNotificationManager.shared.removeNotifications(for: updatedRequirement.id)
                notificationErrorMessage = nil
            } else {

                Task {
                    do {
                        let granted = try await RequirementNotificationManager.shared.requestPermission()

                        guard granted else {
                            RequirementNotificationManager.shared.removeNotifications(for: updatedRequirement.id)

                            notificationErrorMessage = "The requirement was saved, but notifications are disabled. You can enable them in Settings to receive reminders."
                            return
                        }

                        try await RequirementNotificationManager.shared.scheduleNotifications(for: updatedRequirement)
                        notificationErrorMessage = nil

                    } catch {
                        notificationErrorMessage = "The requirement was saved, but its reminder could not be scheduled. \(error.localizedDescription)"
                    }
                }
            }
        } catch {
            repositoryErrorMessage = error.localizedDescription
        }
    }
    
    func clearRepositoryError() {
        repositoryErrorMessage = nil
    }
    
    func clearNotificationError() {
        notificationErrorMessage = nil
    }
    
    func clearAttachmentCleanupWarning() {
        attachmentCleanupWarning = nil
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
