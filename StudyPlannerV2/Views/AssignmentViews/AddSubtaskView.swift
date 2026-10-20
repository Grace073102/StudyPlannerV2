//
//  AddSubtaskView.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 20/10/2026.
//


import SwiftUI

struct AddSubtaskView: View {

    @EnvironmentObject var taskViewModel: TaskViewModel
    @Environment(\.dismiss) private var dismiss

    let assignmentID: String

    @State private var newTaskTitle = ""
    @State private var plannedDate = Date()
    @State private var estimatedMinutes = 30

    @State private var addTaskErrorMessage = ""
    @State private var showAddTaskError = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
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

                            DatePicker("", selection: $plannedDate, displayedComponents: .date)
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
                                    .fill(Color(.secondarySystemBackground))
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
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Add New Subtask")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Unable to Add Subtask", isPresented: $showAddTaskError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(addTaskErrorMessage)
            }
        }
    }

    private var cleanedTitle: String {
        newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func addTask() {
        do {
            try taskViewModel.addTask(
                title: newTaskTitle,
                plannedDate: plannedDate,
                estimatedMinutes: estimatedMinutes,
                to: assignmentID
            )

            dismiss()
        } catch {
            addTaskErrorMessage = error.localizedDescription
            showAddTaskError = true
        }
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
