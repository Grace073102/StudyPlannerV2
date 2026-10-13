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

    init() {
        let assignmentViewModel =
            AssignmentViewModel(repository:JSONAssignmentRepository())

        _assignmentViewModel = StateObject(wrappedValue: assignmentViewModel)

        _taskViewModel = StateObject(wrappedValue: TaskViewModel(assignmentViewModel: assignmentViewModel))
    }

    var body: some View {
        AssignmentView()
            .environmentObject(assignmentViewModel)
            .environmentObject(taskViewModel)
    }
}

#Preview {
    RootView()
}
