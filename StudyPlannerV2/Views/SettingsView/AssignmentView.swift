//
//  AssignmentView.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 14/10/2026.
//

import SwiftUI
import SwiftData

struct AssignmentView: View {
    @EnvironmentObject var assignmentViewModel: AssignmentViewModel
    @EnvironmentObject var taskViewModel: TaskViewModel
    @EnvironmentObject var requirementViewModel: RequirementViewModel
    @EnvironmentObject var placementViewModel: PlacementViewModel
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
                        items: UpcomingItem.make(assignments: assignmentViewModel.assignments, requirements: requirementViewModel.requirements)
                    )
                    
                    if let next = nextPlacement {
                        PlacementPrepCard(
                            summary: next,
                            completedCount: requirementViewModel.completedCount(for: next.placement.id),
                            totalCount: requirementViewModel.requirements(for: next.placement.id).count
                        )
                    }

                    VStack(alignment: .leading, spacing: 12){
                        HStack(alignment: .firstTextBaseline){
                            VStack(alignment: .leading, spacing: 3){
                                Text("To-do list")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Text(todoSubtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            NavigationLink {
                                DetailTaskView()
                                    .environmentObject(assignmentViewModel)
                                    .environmentObject(taskViewModel)
                            } label: {
                                Text("See All")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                        }
                        
                        if taskViewModel.todayTasks.isEmpty {
                            Text("Plan a subtask for today from any assignment to see it here.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        else {
                            ForEach(taskViewModel.todayTasks) { task in
                                TaskView(task: task,
                                         course: courseName(for: task)
                                ) {
                                    taskViewModel.toggleTask(taskID: task.id)
                                }
                                
                                if task.id != taskViewModel.todayTasks.last?.id {
                                    Divider()
                                }
                            }
                        }
                    }
                    .padding(Theme.padding)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.card, in: .rect(cornerRadius: Theme.corner))

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(
                Theme.background
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
    
    private var todoSubtitle: String {
        if taskViewModel.todayTasks.isEmpty {
            return "Nothing planned for today"
        }

        let minutes = taskViewModel.todayStudyMinutes
        return minutes > 0 ? "\(formattedDuration(minutes)) left" : "All done for today"
    }
    
    private var nextPlacement: ManagePlacementsUseCase.PlacementSummary? {
        placementViewModel.placements.first { $0.status != .completed }
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
    let schema = Schema([
        StoredAssignment.self,
        StoredAcademicTask.self,
        StoredPlacementRequirement.self,
        StoredPlacement.self
    ])

    let configuration = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: true
    )

    let container = try! ModelContainer(
        for: schema,
        configurations: [configuration]
    )

    let assignmentRepository = SwiftDataAssignmentRepository(container: container)
    let requirementRepository = SwiftDataRequirementRepository(container: container)
    let placementRepository = SwiftDataPlacementRepository(container: container)
    
        let days: (Int) -> Date = { n in
            Calendar.current.date(byAdding: .day, value: n, to: .now)!
        }

        // Sample assignments
        let _ = try? assignmentRepository.add(
            Assignment(
                title: "Capstone App Store package",
                course: "40005 Advanced iOS",
                dueDate: days(3),
                priority: .high,
                tasks: [
                    AcademicTask(title: "Draft architecture diagram", isCompleted: false, plannedDate: .now, estimatedMinutes: 75),
                    AcademicTask(title: "Record walkthrough video", isCompleted: true, plannedDate: .now, estimatedMinutes: 30)
                ]
            )
        )

        let _ = try? assignmentRepository.add(
            Assignment(
                title: "IPPR Section 4 report",
                course: "31256 Image Processing",
                dueDate: days(-1),
                priority: .medium,
                tasks: [
                    AcademicTask(title: "Revise lecture 9 notes", isCompleted: false, plannedDate: .now, estimatedMinutes: 45)
                ]
            )
        )

        // Sample placement requirements
    let placement = Placement(
        name: "Clinical Placement",
        startDate: days(14),
        endDate: days(70)
    )
    
    let _ = try? placementRepository.add(placement)

        let _ = try? requirementRepository.add(
            PlacementRequirement(
                placementID: placement.id,
                name: "Police Check",
                category: .checksAndClearances,
                dueDate: days(2)
            )
        )

        let _ = try? requirementRepository.add(
            PlacementRequirement(
                placementID: placement.id,
                name: "Induction form",
                category: .placementPreparation,
                dueDate: days(-5),
                isCompleted: true
            )
        )

    // ViewModels
        let assignmentViewModel = AssignmentViewModel(repository: assignmentRepository)

        AssignmentView()
            .environmentObject(assignmentViewModel)
            .environmentObject(TaskViewModel(assignmentViewModel: assignmentViewModel))
            .environmentObject(RequirementViewModel(repository: requirementRepository))
            .environmentObject(PlacementViewModel(repository: placementRepository))
}
