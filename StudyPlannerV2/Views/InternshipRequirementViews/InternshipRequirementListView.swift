//
//  InternshipRequirementListView.swift
//  StudyPlannerV2
//
//  Created by Djy on 28/10/2026.
//

import SwiftUI

struct InternshipRequirementListView: View {

    @ObservedObject var viewModel: InternshipRequirementViewModel
    let internshipID: UUID

    @State private var showingAddRequirement = false
    @State private var selectedFilter = "All"

    var body: some View {

        let requirements = viewModel.requirements(for: internshipID)
        let completedCount = viewModel.completedCount(for: internshipID)
        let progress = viewModel.progress(for: internshipID)

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
                .padding(Theme.padding)
                .frame(maxWidth: .infinity)
                .background(Theme.card)
                .clipShape(RoundedRectangle(cornerRadius: Theme.corner))

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
                                .fontWeight(selectedFilter == filter ? .semibold : .regular)
                                .foregroundStyle(selectedFilter == filter ? Color.primary : Color.secondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(selectedFilter == filter ? Theme.card : Color.clear)
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
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.corner))

                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(filteredRequirements.enumerated()), id: \.element.id) { index, requirement in

                            requirementRow(for: requirement)
                                .padding(Theme.padding)

                            if index < filteredRequirements.count - 1 {
                                Divider()
                                    .padding(.leading, 16)
                            }
                        }
                    }
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.corner))
                }
            }
            .padding(Theme.padding)
        }
        .background(Theme.background)
        .navigationTitle("Requirements")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddRequirement = true
                } label: {
                    Image(systemName: "plus")
                        .font(.headline)
                }
                .accessibilityLabel("Add Requirement")
            }
        }
        .onAppear {
            viewModel.loadRequirements()
        }
        .sheet(isPresented: $showingAddRequirement) {
            AddInternshipRequirementView(viewModel: viewModel, internshipID: internshipID)
        }
        .alert(
            viewModel.repositoryErrorMessage != nil
                ? "Requirement Storage Error"
                : viewModel.attachmentCleanupWarning != nil
                    ? "PDF Cleanup Warning"
                    : "Reminder Error",
            isPresented: Binding(
                get: {
                    !showingAddRequirement && (
                        viewModel.repositoryErrorMessage != nil ||
                        viewModel.attachmentCleanupWarning != nil ||
                        viewModel.notificationErrorMessage != nil
                    )
                },
                set: { isPresented in
                    if !isPresented {
                        clearDisplayedMessage()
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                // The binding clears the displayed message when dismissed.
            }
        } message: {
            Text(
                viewModel.repositoryErrorMessage
                    ?? viewModel.attachmentCleanupWarning
                    ?? viewModel.notificationErrorMessage
                    ?? "An unexpected error occurred."
            )
        }
    }

    // Requirement Row
    private func requirementRow(
        for requirement: InternshipRequirement
    ) -> some View {
        HStack(spacing: 12) {

            // Completion Button
            Button {
                viewModel.toggleCompletion(for: requirement)
            } label: {
                Image(systemName: requirement.isCompleted  ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(requirement.isCompleted ? Color.accentColor : Color.secondary)
                .frame(width: 30, height: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(requirement.isCompleted ? "Mark as incomplete" : "Mark as completed")

            // Detail Navigation
            NavigationLink {
                InternshipRequirementDetailView(viewModel: viewModel, requirementID: requirement.id)
            } label: {
                HStack(spacing: 12) {

                    // Requirement Information
                    VStack(alignment: .leading, spacing: 5) {
                        Text(requirement.name)
                            .font(.headline)
                            .strikethrough(requirement.isCompleted)
                            .foregroundStyle(requirement.isCompleted ? Color.secondary : Color.primary)

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
                    statusBadge(for: requirement)

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    // Date Status
    @ViewBuilder
    private func statusBadge(for requirement: InternshipRequirement) -> some View {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let expiryDate = requirement.expiryDate,
           calendar.startOfDay(for: expiryDate) < today {

            badge("Expired", color: .red)

        } else if !requirement.isCompleted,
                  let dueDate = requirement.dueDate,
                  calendar.startOfDay(for: dueDate) < today {

            badge("Overdue", color: .red)

        } else if let expiryDate = requirement.expiryDate, let daysRemaining = calendar.dateComponents([.day], from: today, to: calendar.startOfDay(for: expiryDate)).day, daysRemaining >= 0 && daysRemaining <= 7 {

            badge("Expiring Soon", color: .orange)

        } else if !requirement.isCompleted, let dueDate = requirement.dueDate, let daysRemaining = calendar.dateComponents([.day], from: today, to: calendar.startOfDay(for: dueDate)).day, daysRemaining >= 0 && daysRemaining <= 7 {

            badge("Due Soon", color: .orange)
        }
    }

    private func badge(_ title: String, color: Color) -> some View {
        Text(title)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }

    private func clearDisplayedMessage() {
        if viewModel.repositoryErrorMessage != nil {
            viewModel.clearRepositoryError()
        } else if viewModel.attachmentCleanupWarning != nil {
            viewModel.clearAttachmentCleanupWarning()
        } else {
            viewModel.clearNotificationError()
        }
    }
}
