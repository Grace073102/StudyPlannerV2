//
//  SubtaskListView.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 14/10/2026.
//

import SwiftUI

struct SubtaskListView: View {

    @EnvironmentObject var taskViewModel: TaskViewModel

    let assignment: Assignment

    @State private var newTaskTitle = ""
    @State private var plannedDate = Date()
    @State private var estimatedMinutes = 30

    @State private var editingTaskID = ""
    @State private var editingTaskTitle = ""
    @State private var editingPlannedDate = Date()
    @State private var editingEstimatedMinutes = 30
    @State private var showEditTask = false

    @State private var deletingTaskID = ""
    @State private var showDeleteConfirmation = false
    
    @State private var addTaskErrorMessage = ""
    @State private var showAddTaskError = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Subtasks")
                        .font(.title3)
                        .fontWeight(.bold)

                    Spacer()

                    Text("\(completedTaskCount)/\(assignment.tasks.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if assignment.tasks.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "checklist")
                            .font(.system(size: 30))
                            .foregroundStyle(.secondary)

                        Text("No subtasks yet")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Text("Add a task below to get started.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(assignment.tasks.enumerated()), id: \.element.id) { index, task in
                            HStack(spacing: 12) {
                                Button {
                                    withAnimation {
                                        taskViewModel.toggleTask(taskID: task.id)
                                    }
                                } label: {
                                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .font(.title2)
                                        .frame(width: 44, height: 44)
                                        .foregroundStyle(task.isCompleted ? Color.accentColor : .secondary)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(task.title)
                                        .font(.subheadline)
                                        .foregroundStyle(task.isCompleted ? .secondary : .primary)
                                        .strikethrough(task.isCompleted)

                                    HStack(spacing: 10) {
                                        if let plannedDate = task.plannedDate {
                                            HStack(spacing: 3) {
                                                Image(systemName: "calendar")
                                                Text(plannedDate, format: .dateTime.day().month(.abbreviated))
                                            }
                                        }

                                        if let estimatedMinutes = task.estimatedMinutes {
                                            HStack(spacing: 3) {
                                                Image(systemName: "clock")
                                                Text(formattedDuration(estimatedMinutes))
                                            }
                                        }
                                    }
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Button {
                                    editingTaskID = task.id
                                    editingTaskTitle = task.title
                                    editingPlannedDate = task.plannedDate ?? Date()
                                    editingEstimatedMinutes = task.estimatedMinutes ?? 30
                                    showEditTask = true
                                } label: {
                                    Image(systemName: "pencil")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.accentColor)
                                        .frame(width: 44, height: 44)
                                        .background(Circle().fill(Color.accentColor.opacity(0.10)))
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)

                                Button {
                                    deletingTaskID = task.id
                                    showDeleteConfirmation = true
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.subheadline)
                                        .foregroundStyle(.red)
                                        .frame(width: 44, height: 44)
                                        .background(Circle().fill(Color.red.opacity(0.10)))
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)

                            if index < assignment.tasks.count - 1 {
                                Divider()
                                    .padding(.leading, 48)
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Theme.card)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color.accentColor)

                    Text("Add New Subtask")
                        .font(.headline)
                        .fontWeight(.semibold)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Task")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        Image(systemName: "checklist")
                            .foregroundStyle(.secondary)

                        TextField("Enter subtask title", text: $newTaskTitle)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.tertiarySystemGroupedBackground))
                    )
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Planned Date")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(.secondary)

                        DatePicker("", selection: $plannedDate, displayedComponents: .date)
                            .labelsHidden()

                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.tertiarySystemGroupedBackground))
                    )
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Estimated Study Time")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Menu {
                        Button { estimatedMinutes = 15 } label: { Text("15 min") }
                        Button { estimatedMinutes = 30 } label: { Text("30 min") }
                        Button { estimatedMinutes = 45 } label: { Text("45 min") }
                        Button { estimatedMinutes = 60 } label: { Text("1 hr") }
                        Button { estimatedMinutes = 90 } label: { Text("1.5 hr") }
                        Button { estimatedMinutes = 120 } label: { Text("2 hr") }
                    } label: {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundStyle(.secondary)

                            Text(formattedDuration(estimatedMinutes))
                                .foregroundStyle(.primary)

                            Spacer()

                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 46)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.tertiarySystemGroupedBackground))
                        )
                    }
                }

                Button {
                    addTask()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                        Text("Add Subtask")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.onAccent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.accentColor)
                    )
                }
                .disabled(cleanedTitle.isEmpty)
                .opacity(cleanedTitle.isEmpty ? 0.5 : 1)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Theme.card)
            )
        }
        .sheet(isPresented: $showEditTask) {
            NavigationStack {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Task")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        TextField("Subtask title", text: $editingTaskTitle)
                            .padding(.horizontal, 12)
                            .frame(height: 46)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.secondarySystemBackground))
                            )
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Planned Date")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        HStack {
                            Image(systemName: "calendar")
                                .foregroundStyle(.secondary)

                            DatePicker("", selection: $editingPlannedDate, displayedComponents: .date)
                                .labelsHidden()

                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 46)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                        )
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Estimated Study Time")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Menu {
                            Button { editingEstimatedMinutes = 15 } label: { Text("15 min") }
                            Button { editingEstimatedMinutes = 30 } label: { Text("30 min") }
                            Button { editingEstimatedMinutes = 45 } label: { Text("45 min") }
                            Button { editingEstimatedMinutes = 60 } label: { Text("1 hr") }
                            Button { editingEstimatedMinutes = 90 } label: { Text("1.5 hr") }
                            Button { editingEstimatedMinutes = 120 } label: { Text("2 hr") }
                        } label: {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundStyle(.secondary)

                                Text(formattedDuration(editingEstimatedMinutes))
                                    .foregroundStyle(.primary)

                                Spacer()

                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .frame(height: 46)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.secondarySystemBackground))
                            )
                        }
                    }

                    Button {
                        saveEditedTask()
                    } label: {
                        Text("Save Changes")
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.onAccent)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.accentColor)
                            )
                    }
                    .disabled(cleanedEditingTitle.isEmpty)
                    .opacity(cleanedEditingTitle.isEmpty ? 0.5 : 1)

                    Spacer()
                }
                .padding(20)
                .navigationTitle("Edit Subtask")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showEditTask = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .alert("Delete Subtask?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                taskViewModel.deleteTask(taskID: deletingTaskID)
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This subtask will be permanently removed.")
        }
        .alert("Unable to Add Subtask", isPresented: $showAddTaskError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(addTaskErrorMessage)
        }
    }

    private var completedTaskCount: Int {
        assignment.tasks.filter { $0.isCompleted }.count
    }

    private var cleanedTitle: String {
        newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var cleanedEditingTitle: String {
        editingTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func addTask() {
        do {
            try taskViewModel.addTask(
                title: newTaskTitle,
                plannedDate: plannedDate,
                estimatedMinutes: estimatedMinutes,
                to: assignment.id
            )

            newTaskTitle = ""
            plannedDate = Date()
            estimatedMinutes = 30
        } catch {
            addTaskErrorMessage = error.localizedDescription
            showAddTaskError = true
        }
    }

    private func saveEditedTask() {
        guard !cleanedEditingTitle.isEmpty else {
            return
        }

        taskViewModel.editTask(
            taskID: editingTaskID,
            newTitle: cleanedEditingTitle,
            plannedDate: editingPlannedDate,
            estimatedMinutes: editingEstimatedMinutes
        )

        showEditTask = false
    }

    private func formattedDuration(_ minutes: Int) -> String {
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
