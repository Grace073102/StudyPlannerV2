//
//  SavedInternshipListView.swift
//  StudyPlannerV2
//
//  Created by emily zhang on 21/10/2026.
//

import SwiftUI

/// Displays internship opportunities saved by the student.
struct SavedInternshipListView: View {
    
    @ObservedObject var viewModel: SavedInternshipViewModel
    
    /// The internship selected for deletion.
    @State private var internshipToDelete: SavedInternship?
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Saved Internships")
                    .font(.title2)
                    .fontWeight(.bold)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
            }
            .padding(.horizontal, Theme.padding)
            .padding(.vertical, 8)
            
            // Internship List
            Group {
                if viewModel.internships.isEmpty {
                    ContentUnavailableView(
                        "No Saved Internships",
                        systemImage: "bookmark",
                        description: Text("Internships you save will appear here.")
                    )
                } else {
                    List {
                        ForEach(viewModel.internships, id: \.id) { internship in
                            internshipRow(for: internship)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .alert(
            "Delete Saved Internship?",
            isPresented: Binding(
                get: { internshipToDelete != nil },
                set: { if !$0 { internshipToDelete = nil } }
            ),
            presenting: internshipToDelete
        ) { internship in
            Button("Delete", role: .destructive) {
                viewModel.deleteInternship(id: internship.id)
            }
            Button("Cancel", role: .cancel) { }
        } message: { internship in
            Text("Are you sure you want to delete \(internship.title)?")
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Saved Internships")
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.loadInternships()
        }
        .alert(
            "Internship Error",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
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
    
    // MARK: - Internship Row
    
    /// Displays a saved internship row with navigation and delete actions.
    private func internshipRow(for internship: SavedInternship) -> some View {
        NavigationLink {
            SavedInternshipDetailView(
                viewModel: viewModel,
                internship: internship
            )
        } label: {
            internshipCard(for: internship)
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
                internshipToDelete = internship
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    // MARK: - Card
    
    /// Displays a summary of a saved internship.
    private func internshipCard(for internship: SavedInternship) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(internship.title)
                .font(.headline)
            
            Text(internship.company)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            if let location = internship.location {
                Label(location, systemImage: "mappin")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if let deadline = internship.applicationDeadline {
                Label {
                    Text(deadline, format: .dateTime.day().month().year())
                } icon: {
                    Image(systemName: "calendar")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Label(
                internship.applicationStatus.displayName,
                systemImage: internship.applicationStatus.icon
            )
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(internship.applicationStatus.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(internship.applicationStatus.color.opacity(0.25))
            .clipShape(Capsule())
        }
        .padding(Theme.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: Theme.corner))
        .accessibilityElement(children: .combine)
        .accessibilityAction(named: "Delete") {
            internshipToDelete = internship
        }
    }
}
