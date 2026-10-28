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
    
    /// The list opens the existing edit form.
    let onEdit: (Placement) -> Void
    
    /// Deletes the placement using the existing ViewModel
    let onDelete: (UUID) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showDeleteConfirmation = false
    
    /// The current version of this placement, so the screen updates after an edit.
    private var summary: ManagePlacementsUseCase.PlacementSummary? {
        placementViewModel.placements.first { $0.placement.id == placementID }
    }
    
    var body: some View {
        Group {
            if let summary {
                Form {
                    // MARK: - Placement Details
                    Section("Placement Details") {
                        LabeledContent(
                            "Name",
                            value: summary.placement.name
                        )
                        
                        LabeledContent(
                            "Dates",
                            value: dateRange(for: summary.placement)
                        )
                        if let subjectID = summary.placement.subjectID,
                           let subject = placementViewModel.subjects.first(
                            where: { $0.id == subjectID }
                           ) {
                            LabeledContent(
                                "Subject",
                                value: subject.name)
                        }
                        LabeledContent("Status", value: summary.status.displayName)
                        if let description = summary.placement.description,
                           !description.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Description")
                                    .foregroundStyle(.secondary)
                                Text(description)
                            }
                        }
                    }
                    
                    // MARK: - Requirements
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Requirements")
                                .font(.headline)
                            
                            let requirements = requirementViewModel.requirements(
                                for: placementID
                            )
                            
                            let completed = requirementViewModel.completedCount(
                                for: placementID
                            )
                            
                            let progress = requirementViewModel.progress(
                                for: placementID
                            )
                            
                            if requirements.isEmpty {
                                Text(
                                    "No requirements yet. Add the checks, training and documents you need before this placement."
                                )
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            } else {
                                Text("\(completed) of \(requirements.count) completed")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                ProgressView(value: progress)
                            }
                            
                            if let message = requirementViewModel.repositoryErrorMessage {
                                Label(
                                    message,
                                    systemImage: "exclamationmark.triangle.fill"
                                )
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
                                    Text(
                                        requirements.isEmpty
                                        ? "Add Requirements"
                                        : "Manage Requirements"
                                    )
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                }
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.accentColor)
                            }
                            .buttonStyle(.plain)
                            .accessibilityHint(
                                "Opens the requirements checklist for this placement"
                            )
                        }
                        .padding(.vertical, 4)
                    }
                    // MARK: Delete Placement
                    Section {
                        Button("Delete Placement", role: .destructive) {
                            showDeleteConfirmation = true
                        }
                    }
                }
                .scrollContentBackground(.hidden)
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
                        .foregroundStyle(Color.accentColor)
                }
                .disabled(summary == nil)
                .accessibilityLabel("Edit Placement")
            }
        }
        .alert("Delete Placement", isPresented: $showDeleteConfirmation
        ) {
            Button("Delete", role: .destructive) {
                onDelete(placementID)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this placement? Its requirements will also be deleted.")
        }
    }
    
    // MARK: - Date Formatting
    private func dateRange(for placement: Placement) -> String {
        let start = placement.startDate.formatted(date: .abbreviated, time: .omitted)
        let end = placement.endDate.formatted(date: .abbreviated, time: .omitted)
        return "\(start) – \(end)"
    }
}

/// The coloured status label used on the list cards and the detail screen.
struct PlacementStatusBadge: View {
    let status: Placement.Status

    var body: some View {
        Label(status.displayName, systemImage: status.icon)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(.primary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status.color.opacity(0.25))
            .clipShape(Capsule())
    }
}
