//
//  InternshipRequirementDetailView.swift
//  StudyPlannerV2
//
//  Created by Djy on 28/10/2026.
//

import SwiftUI

struct InternshipRequirementDetailView: View {

    @ObservedObject var viewModel: InternshipRequirementViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showingDeleteConfirmation = false
    @State private var showingEditRequirement = false
    @State private var showingDeleteError = false
    @State private var deleteErrorMessage = ""

    let requirementID: UUID

    var body: some View {

        let requirement = viewModel.requirements.first {
            $0.id == requirementID
        }

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let requirement = requirement {

                    // Requirement Summary
                    VStack(alignment: .leading, spacing: 12) {
                        Text(requirement.name)
                            .font(.title2)
                            .fontWeight(.bold)

                        HStack(spacing: 6) {
                            Image(systemName: requirement.isCompleted ? "checkmark.circle.fill" : "circle")

                            Text(requirement.isCompleted ? "Completed" : "To do"
                            )
                        }
                        .font(.subheadline)
                        .foregroundStyle(requirement.isCompleted ? Color.accentColor : Color.secondary
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Theme.padding)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.corner))

                    // Requirement Details
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Requirement Details")
                            .font(.headline)

                        Divider()

                        HStack {
                            Text("Category")
                                .foregroundStyle(.secondary)

                            Spacer()

                            Text(requirement.category.rawValue)
                                .multilineTextAlignment(.trailing)
                        }

                        Divider()

                        HStack {
                            Text("Due Date")
                                .foregroundStyle(.secondary)

                            Spacer()

                            if let dueDate = requirement.dueDate {
                                Text(dueDate.formatted(date: .abbreviated, time: .omitted))
                            } else {
                                Text("Not set")
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Divider()

                        HStack {
                            Text("Expiry Date")
                                .foregroundStyle(.secondary)

                            Spacer()

                            if let expiryDate = requirement.expiryDate {
                                Text(expiryDate.formatted(date: .abbreviated, time: .omitted))
                            } else {
                                Text("Not set")
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Divider()

                        HStack {
                            Text("Completion Status")
                                .foregroundStyle(.secondary)

                            Spacer()

                            Text(requirement.isCompleted  ? "Completed"  : "Incomplete")
                        }
                    }
                    .font(.subheadline)
                    .padding(Theme.padding)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.corner))

                    // PDF Attachments
                    AssignmentPDFSection(
                        assignmentID: "internship-requirement-\(requirement.id.uuidString)",
                        attachmentDescription: "Attach PDFs related to this internship requirement."
                    )
                    .id(requirement.id)

                } else {
                    ContentUnavailableView(
                        "Requirement Not Found",
                        systemImage: "exclamationmark.circle",
                        description: Text("This requirement is no longer available.")
                    )
                }
            }
            .padding(Theme.padding)
        }
        .background(Theme.background)
        .navigationTitle("Requirement Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {

                if viewModel.requirements.contains(
                    where: { $0.id == requirementID }
                ) {
                    HStack(spacing: 4) {
                        Button {
                            showingEditRequirement = true
                        } label: {
                            Image(systemName: "pencil")
                                .foregroundStyle(Color.accentColor)
                        }
                        .accessibilityLabel("Edit Requirement")

                        Button {
                            showingDeleteConfirmation = true
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.red)
                                .frame(width: 26, height: 26)
                        }
                        .accessibilityLabel("Delete Requirement")
                    }
                    .padding(.horizontal, 3)
                    .padding(.vertical, 2)
                }
            }
        }
        .sheet(isPresented: $showingEditRequirement) {
            if let requirement = viewModel.requirements.first(where: { $0.id == requirementID }) {
                EditInternshipRequirementView(viewModel: viewModel, requirement: requirement)
            }
        }
        .alert("Delete Requirement?", isPresented: $showingDeleteConfirmation
        ) {
            Button("Cancel", role: .cancel) { }

            Button("Delete", role: .destructive) {
                do {
                    try viewModel.deleteRequirement(id: requirementID)

                    dismiss()

                } catch {
                    deleteErrorMessage = error.localizedDescription
                    showingDeleteError = true
                }
            }
        } message: {
            Text("Are you sure you want to delete this requirement? This action cannot be undone.")
        }
        .alert("Unable to Delete", isPresented: $showingDeleteError
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(deleteErrorMessage)
        }
        .alert(
            "Reminder Error",
            isPresented: Binding(
                get: {
                    !showingEditRequirement &&
                    !showingDeleteConfirmation &&
                    !showingDeleteError &&
                    viewModel.notificationErrorMessage != nil
                },
                set: { isPresented in
                    if !isPresented {
                        viewModel.clearNotificationError()
                    }
                }
            )
        ) {
            Button("OK") {
                viewModel.clearNotificationError()
            }
        } message: {
            Text(viewModel.notificationErrorMessage ?? "")
        }
    }
}
