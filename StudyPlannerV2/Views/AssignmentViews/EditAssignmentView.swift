//
//  EditAssignmentView.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 14/10/2026.
//

import SwiftUI

struct EditAssignmentView: View {

    @EnvironmentObject var assignmentViewModel: AssignmentViewModel
    @Environment(\.dismiss) private var dismiss

    let assignment: Assignment

    @State private var title: String
    @State private var course: String
    @State private var dueDate: Date
    @State private var priority: Assignment.Priority
    @State private var description: String
    @State private var errorMessage = ""
    @State private var showError = false

    init(assignment: Assignment) {
        self.assignment = assignment
        _title = State(initialValue: assignment.title)
        _course = State(initialValue: assignment.course)
        _dueDate = State(initialValue: assignment.dueDate)
        _priority = State(initialValue: assignment.priority)
        _description = State(initialValue: assignment.description ?? "")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("Assignment Title")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        TextField("Assignment Title", text: $title)
                            .textInputAutocapitalization(.words)
                            .padding(.horizontal, 14)
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            )
                    }

                    VStack(alignment: .leading, spacing: 7) {
                        Text("Course")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        TextField("Course", text: $course)
                            .textInputAutocapitalization(.words)
                            .padding(.horizontal, 14)
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            )
                    }

                    VStack(alignment: .leading, spacing: 7) {
                        Text("Due Date")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        DatePicker(
                            "",
                            selection: $dueDate,
                            displayedComponents: .date
                        )
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 14)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        )
                    }

                    VStack(alignment: .leading, spacing: 7) {
                        Text("Priority")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Menu {
                            ForEach(Assignment.Priority.allCases, id: \.self) { value in
                                Button {
                                    priority = value
                                } label: {
                                    Text(value.rawValue)
                                }
                            }
                        } label: {
                            HStack {
                                Circle()
                                    .fill(priority.color)
                                    .frame(width: 9, height: 9)

                                Text(priority.rawValue)
                                    .foregroundStyle(.primary)

                                Spacer()

                                Image(systemName: "chevron.down")
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 14)
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            )
                        }
                    }

                    VStack(alignment: .leading, spacing: 7) {
                        Text("Description (Optional)")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        TextEditor(text: $description)
                            .padding(8)
                            .frame(height: 120)
                            .scrollContentBackground(.hidden)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            )
                    }

                    Button {
                        saveChanges()
                    } label: {
                        Text("Save Changes")
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.onAccent)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.accentColor)
                            )
                    }
                    .disabled(!isValid)
                    .opacity(isValid ? 1 : 0.5)
                }
                .padding(20)
            }
            .navigationTitle("Edit Assignment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Unable to Save Changes", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !course.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func saveChanges() {
        let cleanedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedCourse = course.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedTitle.isEmpty else {
            showErrorMessage("Enter an assignment title before saving.")
            return
        }

        guard !cleanedCourse.isEmpty else {
            showErrorMessage("Enter the course for this assignment before saving.")
            return
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDueDate = calendar.startOfDay(for: dueDate)

        guard selectedDueDate >= today else {
            showErrorMessage("The due date cannot be in the past. Choose today or a future date.")
            return
        }

        var updatedAssignment = assignment
        updatedAssignment.title = cleanedTitle
        updatedAssignment.course = cleanedCourse
        updatedAssignment.dueDate = dueDate
        updatedAssignment.priority = priority
        updatedAssignment.description = cleanedDescription.isEmpty ? nil : cleanedDescription

        assignmentViewModel.update(updatedAssignment)
        dismiss()
    }

    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}
