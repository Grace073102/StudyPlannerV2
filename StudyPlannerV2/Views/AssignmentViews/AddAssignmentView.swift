//
//  AddAssignmentView.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 14/10/2026.
//

import SwiftUI

struct AddAssignmentView: View {

    @EnvironmentObject var assignmentViewModel: AssignmentViewModel
    @EnvironmentObject var subjectViewModel: SubjectViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var course = ""
    @State private var dueDate = Date()
    @State private var priority: Assignment.Priority = .high
    @State private var description = ""
    @State private var errorMessage = ""
    @State private var showError = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    VStack(alignment: .leading, spacing: 7) {
                        Text("Assignment Title")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        TextField(
                            "e.g. Database Assignment",
                            text: $title
                        )
                        .textInputAutocapitalization(.words)
                        .padding(.horizontal, 14)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    Color.gray.opacity(0.4),
                                    lineWidth: 1
                                )
                        )
                    }

                    VStack(alignment: .leading, spacing: 7) {
                        HStack {
                            Text("Subject")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Spacer()

                            // Only show the menu once the student has added subjects
                            if !subjectViewModel.subjects.isEmpty {
                                Menu {
                                    ForEach(subjectViewModel.subjects) { subject in
                                        Button(subject.name) {
                                            course = subject.name
                                        }
                                    }
                                } label: {
                                    Label("Choose Subject", systemImage: "books.vertical")
                                        .font(.subheadline)
                                }
                            }
                        }

                        TextField(
                            "e.g. Database Systems",
                            text: $course
                        )
                        .textInputAutocapitalization(.words)
                        .padding(.horizontal, 14)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    Color.gray.opacity(0.4),
                                    lineWidth: 1
                                )
                        )
                    }

                    VStack(alignment: .leading, spacing: 7) {
                        Text("Due Date")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        DatePicker(
                            "",
                            selection: $dueDate,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .labelsHidden()
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .padding(.horizontal, 14)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    Color.gray.opacity(0.4),
                                    lineWidth: 1
                                )
                        )
                    }

                    VStack(alignment: .leading, spacing: 7) {
                        Text("Priority")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Menu {
                            ForEach(
                                Assignment.Priority.allCases,
                                id: \.self
                            ) { value in
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
                                    .stroke(
                                        Color.gray.opacity(0.4),
                                        lineWidth: 1
                                    )
                            )
                        }
                    }

                    VStack(alignment: .leading, spacing: 7) {
                        Text("Description (Optional)")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    Color.gray.opacity(0.4),
                                    lineWidth: 1
                                )

                            if description.isEmpty {
                                Text("Enter assignment details...")
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                            }

                            TextEditor(text: $description)
                                .padding(8)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                        }
                        .accessibilityLabel("Description, optional")
                        .frame(height: 120)
                    }

                    Button {
                        saveAssignment()
                    } label: {
                        Text("Add Assignment")
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.onAccent)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Theme.accentFill)
                            )
                    }
                    .disabled(!isValid)
                    .opacity(isValid ? 1 : 0.5)
                }
                .padding(20)
            }
            .navigationTitle("Add Assignment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .cancellationAction
                ) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.primary)
                    }
                }
            }
            .alert(
                "Unable to Add Assignment",
                isPresented: $showError
            ) {
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

    private func saveAssignment() {
        do {
            try assignmentViewModel.add(
                title: title,
                course: course,
                dueDate: dueDate,
                priority: priority,
                description: description
            )

            subjectViewModel.addSubjectIfNeeded(name: course)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
