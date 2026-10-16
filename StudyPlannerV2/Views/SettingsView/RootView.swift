//
//  RootView.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 14/10/2026.
//

import SwiftUI

struct RootView: View {
    @StateObject private var assignmentViewModel: AssignmentViewModel

    @StateObject private var taskViewModel: TaskViewModel

    init(repository: AssignmentRepository) {
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
    }
}

#Preview {
    RootView(repository: LocalAssignmentRepository())
}
