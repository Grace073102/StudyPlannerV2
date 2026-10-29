//
//  AssignmentDetailView.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 14/10/2026.
//

import SwiftUI

struct AssignmentDetailView: View {

    @EnvironmentObject var assignmentViewModel: AssignmentViewModel
    @Environment(\.dismiss) private var dismiss

    let assignment: Assignment

    @State private var showEditAssignment = false
    @State private var showDeleteConfirmation = false
    @State private var deleteErrorMessage = ""
    @State private var showDeleteError = false
    @State private var showDoneError = false
    @State private var doneErrorMessage = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                AssignmentProgressView(assignment: currentAssignment)

                SubtaskListView(assignment: currentAssignment)

                AssignmentPDFSection(assignmentID: currentAssignment.id)

                if let description = currentAssignment.description,
                   !description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)

                        Text(description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(Theme.card))
                    )
                }
                if currentAssignment.isCompleted && !currentAssignment.isMarkedDone {
                    Label("All tasks completed", systemImage: "checkmark.circle.fill")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)
                        .frame(maxWidth: .infinity)
                } else {
                    Button {
                        do {
                            try assignmentViewModel.toggleDone(id: currentAssignment.id)
                        } catch {
                            doneErrorMessage = error.localizedDescription
                            showDoneError = true
                        }
                    } label: {
                        Label(
                            currentAssignment.isMarkedDone ? "Mark as Not Done" : "Mark as Done",
                            systemImage: currentAssignment.isMarkedDone ? "arrow.uturn.backward" : "checkmark.circle"
                        )
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(currentAssignment.isMarkedDone ? .gray : .accentColor)
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(currentAssignment.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 4) {
                    Button {
                        showEditAssignment = true
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundStyle(Color.accentColor)
                    }

                    Button {
                        showDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.red)
                            .frame(width: 26, height: 26)
                    }
                }
                .padding(.horizontal, 3)
                .padding(.vertical, 2)
            }
        }
        .sheet(isPresented: $showEditAssignment) {
            EditAssignmentView(
                assignment: currentAssignment
            )
            .environmentObject(assignmentViewModel)
        }
        .alert(
            "Delete Assignment?",
            isPresented: $showDeleteConfirmation
        ) {
            Button("Delete", role: .destructive) {
                do {
                    try assignmentViewModel.delete(currentAssignment)
                    dismiss()
                } catch {
                    deleteErrorMessage = error.localizedDescription
                    showDeleteError = true
                }
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text(
                "This assignment and all of its subtasks will be permanently deleted."
            )
        }
        .alert("Unable to Delete Assignment", isPresented: $showDeleteError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(deleteErrorMessage)
        }
        .alert("Unable to Update Assignment", isPresented: $showDoneError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(doneErrorMessage)
        }
    }

    private var currentAssignment: Assignment {
        assignmentViewModel.assignments.first {
            $0.id == assignment.id
        } ?? assignment
    }
}
