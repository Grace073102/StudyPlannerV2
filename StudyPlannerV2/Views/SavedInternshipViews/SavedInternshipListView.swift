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
        NavigationStack {
            Group {
                if viewModel.internships.isEmpty {
                    ContentUnavailableView(
                        "No Saved Internships",
                        systemImage: "bookmark",
                        description: Text("Internships you save will appear here.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.internships, id: \.id) { internship in
                                NavigationLink {
                                    SavedInternshipDetailView(
                                        viewModel: viewModel,
                                        internship: internship
                                    )
                                } label: {
                                    internshipCard(for: internship)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        internshipToDelete = internship
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(Theme.padding)
                    }
                }
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Saved Internships")
            .onAppear {
                viewModel.loadInternships()
            }
            .confirmationDialog(
                "Delete Saved Internship?",
                isPresented: Binding(
                    get: { internshipToDelete != nil },
                    set: { if !$0 { internshipToDelete = nil } }
                ),
                titleVisibility: .visible,
                presenting: internshipToDelete
            ) { internship in
                Button("Delete", role: .destructive) {
                    viewModel.deleteInternship(id: internship.id)
                }
            } message: { internship in
                Text("Are you sure you want to delete \(internship.title)?")
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
