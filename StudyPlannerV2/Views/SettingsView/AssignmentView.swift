//
//  AssignmentView.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 14/10/2026.
//

import SwiftUI

struct AssignmentView: View {
    @EnvironmentObject var assignmentViewModel: AssignmentViewModel
    @EnvironmentObject var taskViewModel: TaskViewModel
    @State private var showAddAssignment = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Text("Dashboard")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Spacer()

                        Button {
                            showAddAssignment = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(Theme.onAccent)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(Color.accentColor)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Today's study plan")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            let count = taskViewModel.todayIncompleteTasks.count
                            Text("\(count) \(count == 1 ? "task" : "tasks")")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            let minutes = taskViewModel.todayStudyMinutes
                            Text(minutes > 0 ? "\(formattedDuration(minutes)) planned" : "Nothing planned")
                                .font(.subheadline)
                        }
                        .foregroundStyle(Theme.onAccent)
                        .padding(Theme.padding)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .background(Color.accentColor, in: .rect(cornerRadius: Theme.corner))
                        
                        ProgressOverviewView(
                            progress: assignmentViewModel.overallProgress,
                            completedCount: assignmentViewModel.completedTaskCount,
                            totalCount: assignmentViewModel.totalTaskCount
                        )
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    UpcomingDeadlinesView(
                        assignments: assignmentViewModel.assignments
                    )

                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Upcoming Tasks")
                                    .font(.headline)
                                    .fontWeight(.semibold)

                                Text("Tasks due within the next 7 days")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            NavigationLink {
                                DetailTaskView()
                                    .environmentObject(assignmentViewModel)
                                    .environmentObject(taskViewModel)
                            } label: {
                                HStack(spacing: 3) {
                                    Text("View All")
                                    Image(systemName: "chevron.right")
                                }
                                .font(.caption)
                                .fontWeight(.semibold)
                            }
                        }

                        if taskViewModel.upcomingTasks.isEmpty {
                            Text("No tasks due within the next 7 days")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(taskViewModel.upcomingTasks) { task in
                                TaskView(
                                    task: task,
                                    course: courseName(for: task)
                                ) {
                                    taskViewModel.toggleTask(
                                        taskID: task.id
                                    )
                                }
                            }
                        }
                    }
                    .padding(16)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.secondarySystemGroupedBackground))
                            .shadow(
                                color: .black.opacity(0.06),
                                radius: 5,
                                x: 0,
                                y: 2
                            )
                    )

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(
                Color(.systemGroupedBackground)
            )
            .sheet(
                isPresented: $showAddAssignment
            ) {
                AddAssignmentView()
                    .environmentObject(
                        assignmentViewModel
                    )
            }
        }
    }
    
    private func courseName(for task: AcademicTask) -> String? {
        assignmentViewModel.assignments.first { assignment in
            assignment.tasks.contains {
                $0.id == task.id
            }
        }?.course
    }

    private func formattedDuration(
        _ minutes: Int
    ) -> String {
        if minutes < 60 {
            return "\(minutes) min"
        }

        let hours = minutes / 60
        let remainingMinutes = minutes % 60

        if remainingMinutes == 0 {
            return "\(hours) hr"
        }

        return "\(hours) hr \(remainingMinutes) min"
    }
}

#Preview {
    let assignmentViewModel = AssignmentViewModel(
        repository: LocalAssignmentRepository()
    )

    AssignmentView()
        .environmentObject(assignmentViewModel)
        .environmentObject(
            TaskViewModel(assignmentViewModel: assignmentViewModel)
        )
}
