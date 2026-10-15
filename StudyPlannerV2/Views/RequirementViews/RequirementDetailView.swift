//
//  RequirementDetailView.swift
//  StudyPlannerV2
//
//  Created by Djy on 15/10/2026.
//

import SwiftUI

struct RequirementDetailView: View {

    @ObservedObject var viewModel: RequirementViewModel
    
    @State private var showingEditRequirement = false

    let requirementID: UUID

    var body: some View {

        let requirement = viewModel.requirements.first {
            $0.id == requirementID
        }

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                if let requirement = requirement {

                    // Requirement Name and Status
                    VStack(alignment: .leading, spacing: 12) {

                        Text(requirement.name)
                            .font(.title2)
                            .fontWeight(.bold)

                        HStack(spacing: 6) {
                            Image(
                                systemName: requirement.isCompleted
                                    ? "checkmark.circle.fill"
                                    : "circle"
                            )

                            Text(
                                requirement.isCompleted
                                    ? "Completed"
                                    : "To do"
                            )
                        }
                        .font(.subheadline)
                        .foregroundStyle(
                            requirement.isCompleted
                                ? Color.green
                                : Color.secondary
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(
                        RoundedRectangle(cornerRadius: 18)
                    )

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
                                Text(
                                    dueDate.formatted(
                                        date: .abbreviated,
                                        time: .omitted
                                    )
                                )
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
                                Text(
                                    expiryDate.formatted(
                                        date: .abbreviated,
                                        time: .omitted
                                    )
                                )
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

                            Text(
                                requirement.isCompleted
                                    ? "Completed"
                                    : "Incomplete"
                            )
                        }
                    }
                    .font(.subheadline)
                    .padding(16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(
                        RoundedRectangle(cornerRadius: 18)
                    )

                } else {

                    ContentUnavailableView(
                        "Requirement Not Found",
                        systemImage: "exclamationmark.circle",
                        description: Text(
                            "This requirement is no longer available."
                        )
                    )
                }
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Requirement Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.requirements.contains(where: { $0.id == requirementID }) {
                    Button("Edit") {
                        showingEditRequirement = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditRequirement) {
            if let requirement = viewModel.requirements.first(where: { $0.id == requirementID }) {
                EditRequirementView(
                    viewModel: viewModel,
                    requirement: requirement
                )
            }
        }
    }
}

