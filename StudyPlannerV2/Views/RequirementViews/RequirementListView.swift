//
//  RequirementListView.swift
//  StudyPlannerV2
//
//  Created by Djy on 15/10/2026.
//


import SwiftUI

struct RequirementListView: View {

    @ObservedObject var viewModel: RequirementViewModel
    let placementID: UUID

    @State private var showingAddRequirement = false
    @State private var selectedFilter = "All"

    var body: some View {

        let requirements = viewModel.requirements(for: placementID)
        let completedCount = viewModel.completedCount(for: placementID)
        let progress = viewModel.progress(for: placementID)

        let filteredRequirements = requirements.filter { requirement in
            if selectedFilter == "To do" {
                return !requirement.isCompleted
            } else if selectedFilter == "Completed" {
                return requirement.isCompleted
            } else {
                return true
            }
        }

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Preparation Progress
                VStack(alignment: .leading, spacing: 16) {

                    HStack(alignment: .bottom) {

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Preparation progress")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text("\(Int(progress * 100))%")
                                .font(.system(size: 32, weight: .bold))
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 6) {
                            Text("\(completedCount) of \(requirements.count)")
                                .font(.headline)

                            Text("completed")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    ProgressView(value: progress)
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18))


                // Checklist Header
                HStack {
                    Text("Your checklist")
                        .font(.headline)

                    Spacer()
                }


                // Filter
                HStack(spacing: 12) {

                    ForEach(["All", "To do", "Completed"], id: \.self) { filter in

                        Button {
                            selectedFilter = filter
                        } label: {
                            Text(filter)
                                .font(.subheadline)
                                .fontWeight(
                                    selectedFilter == filter
                                        ? .semibold : .regular
                                )
                                .foregroundStyle(
                                    selectedFilter == filter
                                        ? Color.primary : Color.secondary
                                )
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    selectedFilter == filter
                                        ? Color(.secondarySystemGroupedBackground)
                                        : Color.clear
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }


                // Requirement List
                if filteredRequirements.isEmpty {

                    VStack(spacing: 12) {

                        Image(systemName: "checklist")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)

                        Text("No Requirements")
                            .font(.headline)

                        Text("There are no requirements in this category.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(32)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                } else {

                    VStack(spacing: 0) {

                        ForEach(Array(filteredRequirements.enumerated()), id: \.element.id) { index, requirement in

                            HStack(spacing: 12) {

                                // Completion Button
                                Button {
                                    viewModel.toggleCompletion(for: requirement)
                                } label: {
                                    Image(
                                        systemName: requirement.isCompleted
                                            ? "checkmark.circle.fill"
                                            : "circle"
                                    )
                                    .font(.title2)
                                    .foregroundStyle(
                                        requirement.isCompleted
                                            ? Color.green : Color.secondary
                                    )
                                    .frame(width: 30, height: 44)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(
                                    requirement.isCompleted
                                        ? "Mark as incomplete"
                                        : "Mark as completed"
                                )

                                // Detail Navigation
                                NavigationLink {
                                    RequirementDetailView(
                                        viewModel: viewModel,
                                        requirementID: requirement.id
                                    )
                                } label: {
                                    
                                    HStack(spacing: 12) {

                                        // Requirement Information
                                        VStack(alignment: .leading, spacing: 5) {

                                            Text(requirement.name)
                                                .font(.headline)
                                                .strikethrough(requirement.isCompleted)
                                                .foregroundStyle(
                                                    requirement.isCompleted
                                                        ? Color.secondary : Color.primary
                                                )

                                            Text(requirement.category.rawValue)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)

                                            if let dueDate = requirement.dueDate {
                                                Text("Due: \(dueDate.formatted(date: .abbreviated, time: .omitted))")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            }

                                            if let expiryDate = requirement.expiryDate {
                                                Text("Expires: \(expiryDate.formatted(date: .abbreviated, time: .omitted))")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)


                                        // Status
                                        VStack(alignment: .trailing) {

                                            if requirement.isCompleted {

                                                Text("Completed")
                                                    .foregroundStyle(.green)

                                            } else if let expiryDate = requirement.expiryDate,
                                                      Calendar.current.startOfDay(for: expiryDate) <
                                                      Calendar.current.startOfDay(for: Date()) {

                                                Text("Expired")
                                                    .foregroundStyle(.red)

                                            } else if let dueDate = requirement.dueDate,
                                                      Calendar.current.startOfDay(for: dueDate) <
                                                      Calendar.current.startOfDay(for: Date()) {

                                                Text("Overdue")
                                                    .foregroundStyle(.red)

                                            } else {

                                                Text("Upcoming")
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                        .font(.caption)
                                        .fontWeight(.medium)

                                        // Chevron
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundStyle(.tertiary)
                                    }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(16)

                            if index < filteredRequirements.count - 1 {
                                Divider()
                                    .padding(.leading, 16)
                            }
                        }
                    }
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                }
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Requirements")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddRequirement = true
                } label: {
                    Image(systemName: "plus")
                        .font(.headline)
                }
            }
        }
        .sheet(isPresented: $showingAddRequirement) {
            AddRequirementView(
                viewModel: viewModel,
                placementID: placementID
            )
        }
    }
}


#Preview {

    let placementID = UUID()

    let sampleRequirements = [

        PlacementRequirement(
            placementID: placementID,
            name: "Police Check",
            category: .checksAndClearances,
            dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
            isCompleted: true
        ),

        PlacementRequirement(
            placementID: placementID,
            name: "First Aid Certificate",
            category: .trainingAndCertificates,
            dueDate: Calendar.current.date(byAdding: .day, value: 14, to: Date()),
            isCompleted: false
        ),

        PlacementRequirement(
            placementID: placementID,
            name: "Placement Orientation",
            category: .placementPreparation,
            dueDate: Calendar.current.date(byAdding: .day, value: 21, to: Date()),
            isCompleted: false
        )
    ]

    let repository = LocalRequirementRepository(
        requirements: sampleRequirements
    )

    let viewModel = RequirementViewModel(
        repository: repository
    )

    return NavigationStack {
        RequirementListView(
            viewModel: viewModel,
            placementID: placementID
        )
    }
}
