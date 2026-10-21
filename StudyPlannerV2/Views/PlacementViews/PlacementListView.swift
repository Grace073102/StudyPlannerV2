//
//  PlacementListView.swift
//  StudyPlannerV2
//
//  Created by emily zhang on 21/10/2026.
//

import SwiftUI

/// Displays the student's placements and their current statuses.
struct PlacementListView: View {

    @ObservedObject var viewModel: PlacementViewModel

    /// The placement the student chose to delete, waiting for confirmation.
    @State private var placementToDelete: Placement?

    /// Whether the add/edit form is showing, and which placement it edits (nil = add).
    @State private var showForm = false
    @State private var formPlacement: Placement?

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.placements.isEmpty {
                    ContentUnavailableView(
                        "No Placements",
                        systemImage: "calendar.badge.plus",
                        description: Text("Add a placement to keep track of your schedule.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.placements) { summary in
                                Button {
                                    formPlacement = summary.placement
                                    showForm = true
                                } label: {
                                    card(for: summary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(Theme.padding)
                    }
                }
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("My Placements")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        formPlacement = nil
                        showForm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Placement")
                }
            }
            .onAppear {
                viewModel.loadPlacements()
            }
            .sheet(isPresented: $showForm) {
                PlacementFormView(viewModel: viewModel, placement: formPlacement)
            }
            .confirmationDialog(
                "Delete Placement?",
                isPresented: Binding(
                    get: { placementToDelete != nil },
                    set: { if !$0 { placementToDelete = nil } }
                ),
                titleVisibility: .visible,
                presenting: placementToDelete
            ) { placement in
                Button("Delete", role: .destructive) {
                    viewModel.deletePlacement(id: placement.id)
                }
            } message: { placement in
                Text("Are you sure you want to delete \(placement.name)?")
            }
            .alert(
                "Placement Error",
                isPresented: Binding(
                    // Not while the form is open, because the form shows its own alert.
                    get: { viewModel.errorMessage != nil && !showForm },
                    set: { if !$0 { viewModel.clearError() } }
                )
            ) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    // MARK: - Card

    private func card(for summary: ManagePlacementsUseCase.PlacementSummary) -> some View {
        let placement = summary.placement

        return HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(placement.name)
                    .font(.headline)

                Text(placement.discipline)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("\(placement.startDate, format: .dateTime.day().month().year()) – \(placement.endDate, format: .dateTime.day().month().year())")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Label(summary.status.displayName, systemImage: summary.status.icon)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(summary.status.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(summary.status.color.opacity(0.25))
                .clipShape(Capsule())
        }
        .padding(Theme.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.corner))
        .accessibilityElement(children: .combine)
        .accessibilityAction(named: "Delete") {
            placementToDelete = placement
        }
        .contextMenu {
            Button(role: .destructive) {
                placementToDelete = placement
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
