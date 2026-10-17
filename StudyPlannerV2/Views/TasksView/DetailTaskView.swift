//
//  DetailTaskView.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 14/10/2026.
//

import SwiftUI

struct DetailTaskView: View {
    @EnvironmentObject var assignmentViewModel: AssignmentViewModel
    @EnvironmentObject var taskViewModel: TaskViewModel

    @State private var selectedFilter = "All"
    @Namespace private var animation

    let filters = ["All", "Today", "This Week", "Completed"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Tasks")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                }

                HStack(spacing: 0) {
                    ForEach(filters, id: \.self) { filter in
                        Button {
                            withAnimation(.easeInOut) {
                                selectedFilter = filter
                            }
                        } label: {
                            ZStack {
                                if selectedFilter == filter {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.accentColor.opacity(0.15))
                                        .matchedGeometryEffect(
                                            id: "filter",
                                            in: animation
                                        )
                                }

                                Text(filter)
                                    .font(.subheadline)
                                    .fontWeight(
                                        selectedFilter == filter
                                        ? .semibold
                                        : .regular
                                    )
                                    .foregroundStyle(
                                        selectedFilter == filter
                                        ? Color.accentColor
                                        : .secondary
                                    )
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(Theme.card))
                )

                prioritySection(
                    title: "High Priority",
                    priority: .high
                )

                prioritySection(
                    title: "Medium Priority",
                    priority: .medium
                )

                prioritySection(
                    title: "Low Priority",
                    priority: .low
                )
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }

    private func prioritySection(
        title: String,
        priority: Assignment.Priority
    ) -> some View {
        let assignments = visibleAssignments(priority: priority)

        return Group {
            if !assignments.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.headline)

                    VStack(spacing: 0) {
                        ForEach(assignments) { assignment in
                            ForEach(visibleTasks(for: assignment)) { task in
                                TaskView(
                                    task: task,
                                    course: assignment.course
                                ) {
                                    taskViewModel.toggleTask(
                                        taskID: task.id
                                    )
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Theme.card)
                    )
                }
            }
        }
    }

    private func visibleTasks(
        for assignment: Assignment
    ) -> [AcademicTask] {
        assignment.tasks.filter { task in
            switch selectedFilter {
            case "Today":
                guard let plannedDate = task.plannedDate else {
                    return false
                }

                return Calendar.current.isDateInToday(plannedDate)

            case "This Week":
                guard let plannedDate = task.plannedDate else {
                    return false
                }

                return Calendar.current.isDate(
                    plannedDate,
                    equalTo: Date(),
                    toGranularity: .weekOfYear
                )

            case "Completed":
                return task.isCompleted

            default:
                return true
            }
        }
    }

    private func visibleAssignments(
        priority: Assignment.Priority
    ) -> [Assignment] {
        assignmentViewModel.assignments.filter {
            $0.priority == priority && !visibleTasks(for: $0).isEmpty
        }
    }
}
