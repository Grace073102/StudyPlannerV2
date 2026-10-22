//
//  StudyPlannerV2App.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 14/10/2026.
//

import SwiftUI
import SwiftData

struct AppRepositories {
    let assignments: SwiftDataAssignmentRepository
    let requirements: SwiftDataRequirementRepository
    let subjects: SwiftDataSubjectRepository
    let placements: SwiftDataPlacementRepository
    let savedInternships: SwiftDataSavedInternshipRepository
    let managePlacements: ManagePlacementsUseCase
}

@main
struct StudyPlannerApp: App {
    @State private var startup: Result<AppRepositories, Error>
    
    init() {
        _startup = State(initialValue: Self.prepareStorage())
    }

    var body: some Scene {
        WindowGroup {
            switch startup {
            case .success(let repositories):
                RootView(
                    repository: repositories.assignments,
                    requirementRepository: repositories.requirements,
                    placementRepository: repositories.placements,
                    savedInternshipRepository: repositories.savedInternships
                )
                
            case .failure:
                VStack(spacing: 16) {
                    Text("Unable to Open Your Planner")
                        .font(.title2)
                        .bold()

                    Text(
                        "Your saved data has not been cleared. Please try again."
                    )
                    .multilineTextAlignment(.center)

                    Button("Try Again") {
                        startup = Self.prepareStorage()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
    }

    private static func prepareStorage()
        -> Result<AppRepositories, Error> {
        do {
            let schema = Schema([
                StoredAssignment.self,
                StoredAcademicTask.self,
                StoredMigration.self,
                StoredPlacementRequirement.self,
                StoredSubject.self,
                StoredPlacement.self,
                StoredSavedInternship.self
            ])

            let configuration = ModelConfiguration(
                "StudyPlannerSwiftData",
                schema: schema,
                isStoredInMemoryOnly: false
            )

            let container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )

            let repository = SwiftDataAssignmentRepository(
                container: container
            )
            
            

            try repository.migrateLegacyAssignmentsIfNeeded()

            let requirementRepository = SwiftDataRequirementRepository(
                container: container
            )

            let subjectRepository = SwiftDataSubjectRepository(
                container: container
            )

            let placementRepository = SwiftDataPlacementRepository(
                container: container,
                onRequirementsChanged: {
                    requirementRepository.reloadAfterPlacementDeletion()
                }
            )
            try placementRepository.linkExistingRequirements()
            requirementRepository.reloadAfterPlacementDeletion()

            let managePlacements = ManagePlacementsUseCase(
                repository: placementRepository,
                loadRequirementIDs: { placementID in
                    let requirements = try requirementRepository.load()

                    return requirements
                        .filter { $0.placementID == placementID }
                        .map(\.id)
                },
                cancelRequirementNotifications: { requirementID in
                    RequirementNotificationManager.shared.cancelNotifications(
                        for: requirementID
                    )
                }
            )

            let savedInternshipRepository = SwiftDataSavedInternshipRepository(
                container: container
            )

            return .success(
                AppRepositories(
                    assignments: repository,
                    requirements: requirementRepository,
                    subjects: subjectRepository,
                    placements: placementRepository,
                    savedInternships: savedInternshipRepository,
                    managePlacements: managePlacements

                )
            )
        } catch {
            return .failure(error)
        }
    }
}
