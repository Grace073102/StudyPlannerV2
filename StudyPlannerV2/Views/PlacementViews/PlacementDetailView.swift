//
//  PlacementDetailView.swift
//  StudyPlannerV2
//
//  Created by emily zhang on 28/10/2026.
//

import SwiftUI

/// Shows one placement's details, its status, and a summary of its requirements.
struct PlacementDetailView: View {

    let placementID: UUID
    @ObservedObject var placementViewModel: PlacementViewModel
    @ObservedObject var requirementViewModel: RequirementViewModel

    /// Called when the student taps the pencil. The list opens the form, so form errors are shown in one place only.
    let onEdit: (Placement) -> Void

    /// The current version of this placement, so the screen updates after an edit.
    private var summary: ManagePlacementsUseCase.PlacementSummary? {
        placementViewModel.placements.first { $0.placement.id == placementID }
    }

    var body: some View {
        Group {
            if let summary {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        detailsCard(for: summary)
                        requirementsCard
                    }
                    .padding(Theme.padding)
                }
            } else {
                ContentUnavailableView(
                    "Placement Not Found",
                    systemImage: "questionmark.folder",
                    description: Text("This placement may have been deleted.")
                )
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(summary?.placement.name ?? "Placement")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if let summary {
                        onEdit(summary.placement)
                    }
                } label: {
                    Image(systemName: "pencil")
                }
                .disabled(summary == nil)
                .accessibilityLabel("Edit Placement")
            }
        }
    }

    // MARK: - Details

    private func detailsCard(for summary: ManagePlacementsUseCase.PlacementSummary) -> some View {
        let placement = summary.placement

        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Placement Details")
                    .font(.headline)
                Spacer()
                PlacementStatusBadge(status: summary.status)
            }

            LabeledContent("Name", value: placement.name)

            LabeledContent("Dates", value: dateRange(for: placement))

            if let subjectID = placement.subjectID,
               let subject = placementViewModel.subjects.first(where: { $0.id == subjectID }) {
                LabeledContent("Subject", value: subject.name)
            }

            if let description = placement.description, !description.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Description")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(description)
                }
            }
        }
        .padding(Theme.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.corner))
    }

    private func dateRange(for placement: Placement) -> String {
        let start = placement.startDate.formatted(date: .abbreviated, time: .omitted)
        let end = placement.endDate.formatted(date: .abbreviated, time: .omitted)
        return "\(start) – \(end)"
    }

    // MARK: - Requirements

    private var requirementsCard: some View {
        let requirements = requirementViewModel.requirements(for: placementID)
        let completed = requirementViewModel.completedCount(for: placementID)
        let progress = requirementViewModel.progress(for: placementID)

        return VStack(alignment: .leading, spacing: 12) {
            Text("Requirements")
                .font(.headline)

            if requirements.isEmpty {
                Text("No requirements yet. Add the checks, training and documents you need before this placement.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text("\(completed) of \(requirements.count) completed")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ProgressView(value: progress)
            }

            // Shown if the requirements could not be loaded, instead of a silent "0 of 0".
            if let message = requirementViewModel.repositoryErrorMessage {
                Label(message, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            NavigationLink {
                RequirementListView(
                    viewModel: requirementViewModel,
                    placementID: placementID
                )
            } label: {
                HStack {
                    Text(requirements.isEmpty ? "Add Requirements" : "Manage Requirements")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .fontWeight(.semibold)
                .foregroundStyle(Color.accentColor)
            }
            .accessibilityHint("Opens the requirements checklist for this placement")
        }
        .padding(Theme.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.corner))
    }
}

/// The coloured status label used on the list cards and the detail screen.
struct PlacementStatusBadge: View {
    let status: Placement.Status

    var body: some View {
        Label(status.displayName, systemImage: status.icon)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(status.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status.color.opacity(0.25))
            .clipShape(Capsule())
    }
}
