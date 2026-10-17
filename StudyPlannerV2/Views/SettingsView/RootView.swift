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

    init(
        repository: AssignmentRepository,
        requirementRepository: RequirementRepository
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

            Tab("Placements", systemImage: "briefcase") {
                PlaceholderView(title: "Placements", systemImage: "briefcase")
            }

            Tab("Settings", systemImage: "gearshape") {
                PlaceholderView(title: "Settings", systemImage: "gearshape")
            }
        }
        .environmentObject(assignmentViewModel)
        .environmentObject(taskViewModel)
        .environmentObject(requirementViewModel)
    }
}

#Preview {
    let schema = Schema([
        StoredAssignment.self,
        StoredAcademicTask.self,
        StoredPlacementRequirement.self
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
        )
    )
}
