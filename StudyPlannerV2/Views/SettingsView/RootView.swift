//
//  RootView.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 14/10/2026.
//

import SwiftData
import SwiftUI

struct RootView: View {
    @StateObject private var assignmentViewModel: AssignmentViewModel

    @StateObject private var taskViewModel: TaskViewModel
    
    @StateObject private var requirementViewModel: RequirementViewModel
    @StateObject private var placementViewModel: PlacementViewModel
    @StateObject private var savedInternshipViewModel: SavedInternshipViewModel
    @StateObject private var subjectViewModel: SubjectViewModel
    
    init(
        repository: AssignmentRepository,
        requirementRepository: RequirementRepository,
        managePlacements: ManagePlacementsUseCase,
        subjectRepository: SubjectRepository,
        savedInternshipRepository: SavedInternshipRepository
    ) {
        let assignmentViewModel = AssignmentViewModel(
            repository: repository
        )

        _assignmentViewModel = StateObject(
            wrappedValue: assignmentViewModel
        )

        _taskViewModel = StateObject(
            wrappedValue: TaskViewModel(
                assignmentViewModel: assignmentViewModel
            )
        )

        _requirementViewModel = StateObject(
            wrappedValue: RequirementViewModel(
                repository: requirementRepository
            )
        )
        
        _placementViewModel = StateObject(
            wrappedValue: PlacementViewModel(
                useCase: managePlacements, subjectRepository: subjectRepository)
        )
        
        _savedInternshipViewModel = StateObject(
            wrappedValue: SavedInternshipViewModel(
                repository: savedInternshipRepository)
        )
        
        _subjectViewModel = StateObject(
            wrappedValue: SubjectViewModel(repository: subjectRepository)
        )
    }

    var body: some View {
        TabView {
            Tab("Dashboard", systemImage: "house") {
                AssignmentView()
            }
            Tab("Assignments", systemImage: "doc.text") {
                NavigationStack {
                    AssignmentListView()
                }
            }

            
            Tab("Career", systemImage: "briefcase") {
                CareerView(placementViewModel: placementViewModel, savedInternshipViewModel: savedInternshipViewModel)
            }

        }
        .environmentObject(assignmentViewModel)
        .environmentObject(taskViewModel)
        .environmentObject(requirementViewModel)
        .environmentObject(placementViewModel)
        .environmentObject(savedInternshipViewModel)
        .environmentObject(subjectViewModel)
        .alert(
            "Something Went Wrong",
            isPresented: Binding(
                get: { taskViewModel.errorMessage != nil },
                set: { if !$0 { taskViewModel.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(taskViewModel.errorMessage ?? "")
        }
    }
}

#Preview {
    let schema = Schema([
        StoredAssignment.self,
        StoredAcademicTask.self,
        StoredPlacementRequirement.self,
        StoredPlacement.self,
        StoredSubject.self,
        StoredSavedInternship.self
    ])

    let configuration = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: true
    )

    let container = try! ModelContainer(
        for: schema,
        configurations: [configuration]
    )

    RootView(
        repository: SwiftDataAssignmentRepository(
            container: container
        ),
        requirementRepository: SwiftDataRequirementRepository(
            container: container
        ),
        managePlacements: ManagePlacementsUseCase(
            repository: SwiftDataPlacementRepository(container: container)
        ),
        subjectRepository: SwiftDataSubjectRepository(container: container),
        savedInternshipRepository: SwiftDataSavedInternshipRepository(container: container)
    )
}
