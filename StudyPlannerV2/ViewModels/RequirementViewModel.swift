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
    
    private let repository: RequirementRepository
    private let addRequirementUseCase: AddRequirementUseCase
    
    init(repository: RequirementRepository) {
        
        self.repository = repository
        self.addRequirementUseCase = AddRequirementUseCase(repository: repository)
        
        loadRequirements()
    }
    
    func loadRequirements() {
        requirements = repository.load()
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
        _ = try addRequirementUseCase.execute(
            placementID: placementID,
            name: name,
            category: category,
            dueDate: dueDate,
            expiryDate: expiryDate
        )
        
        loadRequirements()
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
    }
    
    func deleteRequirement(id: UUID) throws {
        let useCase = DeleteRequirementUseCase(
            repository: repository
        )

        try useCase.execute(id: id)
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
        var updatedRequirement = requirement
    
        updatedRequirement.isCompleted.toggle()
        repository.update(updatedRequirement)
        loadRequirements()
    }
}

enum RequirementValidationError: LocalizedError {
    case emptyName
    case notFound
    case invalidDates
    
    var errorDescription: String? {
        switch self {
            
        case .emptyName:
            return "Please enter a requirement name."
            
        case .notFound:
            return "This requirement could not be found."
            
        case .invalidDates:
            return "The expiry date cannot be earlier than the due date."
        }
    }
}
