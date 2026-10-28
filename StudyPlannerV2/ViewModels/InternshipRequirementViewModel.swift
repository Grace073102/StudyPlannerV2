//
//  InternshipRequirementViewModel.swift
//  StudyPlannerV2
//
//  Created by Djy on 28/10/2026.
//

import Foundation
import Combine

@MainActor
final class InternshipRequirementViewModel: ObservableObject {

    @Published private(set) var requirements: [InternshipRequirement] = []

    @Published private(set) var repositoryErrorMessage: String?
    @Published private(set) var notificationErrorMessage: String?

    private let repository: InternshipRequirementRepository
    private let addRequirementUseCase: AddInternshipRequirementUseCase
    private var repositoryChanges: AnyCancellable?
    private var reminderTasks: [UUID: Task<Void, Never>] = [:]

    init(repository: InternshipRequirementRepository) {
        self.repository = repository
        self.addRequirementUseCase = AddInternshipRequirementUseCase(repository: repository)

        loadRequirements()

        repositoryChanges = repository.changes.sink { [weak self] in
            guard let self else { return }

            if let errorMessage = self.repository.errorMessage {
                self.repositoryErrorMessage = errorMessage
            } else {
                self.loadRequirements()
            }
        }
    }

    // Load requirements
    func loadRequirements() {
        do {
            requirements = try repository.load()
            repositoryErrorMessage = nil
        } catch {
            repositoryErrorMessage = error.localizedDescription
        }
    }

    // Refresh requirements after saving changes
    private func reloadRequirements() throws {
        do {
            requirements = try repository.load()
            repositoryErrorMessage = nil
        } catch {
            throw RequirementPersistenceError(message: "Your changes were saved, but the requirements could not be refreshed. Please reopen the page to check the latest information.")
        }
    }

    // Find requirements belonging to an internship
    func requirements(for internshipID: UUID) -> [InternshipRequirement] {
        requirements.filter {
            $0.internshipID == internshipID
        }
    }

    // Add a requirement
    func add(
        internshipID: UUID,
        name: String,
        category: InternshipRequirement.Category,
        dueDate: Date?,
        expiryDate: Date?
    ) throws {
        let requirement = try addRequirementUseCase.execute(
            internshipID: internshipID,
            name: name,
            category: category,
            dueDate: dueDate,
            expiryDate: expiryDate
        )

        updateReminders(for: requirement)
        try reloadRequirements()
    }

    // Update a requirement
    func updateRequirement(
        id: UUID,
        name: String,
        category: InternshipRequirement.Category,
        dueDate: Date?,
        expiryDate: Date?
    ) throws {
        let useCase = UpdateInternshipRequirementUseCase(repository: repository)

        let updatedRequirement = try useCase.execute(
            id: id,
            name: name,
            category: category,
            dueDate: dueDate,
            expiryDate: expiryDate
        )

        updateReminders(for: updatedRequirement)
        try reloadRequirements()
    }

    // Delete a requirement
    func deleteRequirement(id: UUID) throws {
        let useCase = DeleteInternshipRequirementUseCase(repository: repository)

        try useCase.execute(id: id)

        reminderTasks[id]?.cancel()
        reminderTasks[id] = nil

        InternshipRequirementNotificationManager.shared
            .cancelNotifications(for: id)

        try reloadRequirements()
    }

    // Count completed requirements
    func completedCount(for internshipID: UUID) -> Int {
        requirements(for: internshipID).filter {
            $0.isCompleted
        }.count
    }

    // Calculate checklist progress
    func progress(for internshipID: UUID) -> Double {
        let internshipRequirements = requirements(for: internshipID)

        guard !internshipRequirements.isEmpty else {
            return 0
        }

        let completed = internshipRequirements.filter {
            $0.isCompleted
        }.count

        return Double(completed) / Double(internshipRequirements.count)
    }

    // Mark a requirement as complete or incomplete
    func toggleCompletion(for requirement: InternshipRequirement) {
        let useCase = ToggleInternshipRequirementCompletionUseCase(repository: repository)

        do {
            let updatedRequirement = try useCase.execute(id: requirement.id)

            updateReminders(for: updatedRequirement)
            try reloadRequirements()
        } catch {
            repositoryErrorMessage = error.localizedDescription
        }
    }

    // Update reminders in save order for each requirement.
    private func updateReminders(
        for requirement: InternshipRequirement
    ) {
        let id = requirement.id
        let previousTask = reminderTasks[id]
        let manager = InternshipRequirementNotificationManager.shared

        // Each new task waits for the previous update to finish.
        // This prevents an older edit from scheduling a reminder
        // after a newer edit has already scheduled one.
        let task = Task { [weak self] in
            await previousTask?.value

            guard let self else {
                return
            }

            // An edit might have been replaced while this task waited.
            guard !Task.isCancelled else {
                return
            }

            manager.removeNotifications(for: id)

            let needsDueReminder = !requirement.isCompleted && requirement.dueDate != nil
            let needsExpiryReminder = requirement.expiryDate != nil

            guard needsDueReminder || needsExpiryReminder else {
                notificationErrorMessage = nil
                return
            }

            do {
                let granted = try await manager.requestPermission()

                guard !Task.isCancelled else {
                    return
                }

                guard granted else {
                    notificationErrorMessage = "The requirement was saved, but notifications are disabled. You can enable them in Settings to receive reminders."
                    return
                }

                try await manager.scheduleNotifications(for: requirement)

                // If this task was superseded during scheduling, the
                // next task will remove its reminders before scheduling
                // the latest version.
                guard !Task.isCancelled else {
                    return
                }

                notificationErrorMessage = nil
            } catch {
                guard !Task.isCancelled else {
                    return
                }

                notificationErrorMessage = "The requirement was saved, but its reminder could not be scheduled. \(error.localizedDescription)"
            }
        }

        // Cancel the older task, then keep the new task as the latest.
        previousTask?.cancel()
        reminderTasks[id] = task
    }

    func clearRepositoryError() {
        repositoryErrorMessage = nil
    }

    func clearNotificationError() {
        notificationErrorMessage = nil
    }
}
