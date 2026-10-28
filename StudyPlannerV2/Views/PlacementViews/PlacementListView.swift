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
    @EnvironmentObject var requirementViewModel: RequirementViewModel
    
    /// The placement the student chose to delete, waiting for confirmation.
    @State private var placementToDelete: Placement?
    
    /// Whether the add/edit form is showing, and which placement it edits (nil = add).
    @State private var showForm = false
    @State private var formPlacement: Placement?
    
    private var showDeleteDialog: Binding<Bool> {
        Binding(
            get: { placementToDelete != nil },
            set: { if !$0 { placementToDelete = nil } }
        )
    }
    
    private var showErrorAlert: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil && !showForm },
            set: { if !$0 { viewModel.clearError() } }
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("My Placements")
                    .font(.title2)
                    .fontWeight(.bold)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Button {
                    formPlacement = nil
                    showForm = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Theme.onAccent)
                        .frame(width: 44, height: 44)
                        .background(Theme.accentFill, in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add Placement")
            }
            .padding(.horizontal, Theme.padding)
            .padding(.vertical, 8)
            // Placement List
            Group {
                if viewModel.placements.isEmpty {
                    ContentUnavailableView(
                        "No Placements",
                        systemImage: "calendar.badge.plus",
                        description: Text("Add a placement to keep track of your schedule.")
                    )
                } else {
                    List {
                        ForEach(viewModel.placements) { summary in
                            NavigationLink {
                                PlacementDetailView(
                                    placementID: summary.placement.id,
                                    placementViewModel: viewModel,
                                    requirementViewModel: requirementViewModel,
                                    onEdit: { placement in
                                        formPlacement = placement
                                        showForm = true
                                    },
                                    onDelete: {placementID in
                                        viewModel.deletePlacement(id: placementID)
                                    }
                                )
                            } label: {
                                card(for: summary)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(
                                top: 6,
                                leading: Theme.padding,
                                bottom: 6,
                                trailing: Theme.padding
                            ))
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    placementToDelete = summary.placement
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .alert(
            "Delete Placement?",
            isPresented: showDeleteDialog,
            presenting: placementToDelete
        ) { placement in
            Button("Delete", role: .destructive) {
                viewModel.deletePlacement(id: placement.id)
            }
            Button("Cancel", role: .cancel) { }
        } message: { placement in
            Text("Are you sure you want to delete \(placement.name)? Its requirements will also be deleted.")
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("My Placements")
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.loadPlacements()
            viewModel.loadSubjects()
        }
        .sheet(isPresented: $showForm, onDismiss: {
            formPlacement = nil
        }) {
            PlacementFormView(viewModel: viewModel, placement: formPlacement)
                .id(formPlacement?.id)
        }
        .alert(
            "Placement Error",
            isPresented: showErrorAlert
        ) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    // MARK: - Card
    
    private func card(for summary: ManagePlacementsUseCase.PlacementSummary) -> some View {
        let placement = summary.placement
        
        return HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(placement.name)
                    .font(.headline)
                
                if let subjectID = placement.subjectID,
                   let subject = viewModel.subjects.first(where: { $0.id == subjectID }) {
                    Label {
                        Text(subject.name)
                            .foregroundStyle(.secondary)
                    } icon: {
                        Image(systemName: "book.closed")
                            .foregroundStyle(Color.accentColor)
                    }
                    .font(.caption)
                }
                
                Text(dateRangeText(for: placement))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if let description = placement.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            PlacementStatusBadge(status: summary.status)
        }
        .padding(Theme.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.corner))
        .accessibilityElement(children: .combine)
        .accessibilityAction(named: "Edit") {
            formPlacement = placement
            showForm = true
        }
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
    
    // MARK: Helper for the date range text
    private func dateRangeText(for placement: Placement) -> String {
        let start = placement.startDate.formatted(.dateTime.day().month().year())
        let end = placement.endDate.formatted(.dateTime.day().month().year())
        return "\(start) – \(end)"
    }
}
