//
//  SavedInternshipDetailView.swift
//  StudyPlannerV2
//
//  Created by emily zhang on 21/10/2026.
//

import SwiftUI

/// Displays the details of a saved internship.
struct SavedInternshipDetailView: View {

    @ObservedObject var viewModel: SavedInternshipViewModel
    @Environment(\.dismiss) private var dismiss

    let internship: SavedInternship

    /// The student's selected application status.
    @State private var selectedStatus: ApplicationStatus

    /// Whether the deletion confirmation is showing.
    @State private var showDeleteConfirmation = false

    init(viewModel: SavedInternshipViewModel, internship: SavedInternship) {
        self.viewModel = viewModel
        self.internship = internship
        _selectedStatus = State(initialValue: internship.applicationStatus)
    }

    var body: some View {
        Form {
            Section("Internship Details") {
                LabeledContent("Title", value: internship.title)
                LabeledContent("Company", value: internship.company)

                if let location = internship.location {
                    LabeledContent("Location", value: location)
                }
            }

            Section("Application") {
                if let deadline = internship.applicationDeadline {
                    LabeledContent("Deadline") {
                        Text(deadline, format: .dateTime.day().month().year())
                    }
                }

                Picker("Application Status", selection: $selectedStatus) {
                    ForEach(ApplicationStatus.allCases, id: \.self) { status in
                        Text(status.displayName).tag(status)
                    }
                }

                Button("Update Status") {
                    updateStatus()
                }
                .disabled(selectedStatus == internship.applicationStatus)
            }

            // Only open web links (http or https) that have a host.
            if let url = internship.applicationURL,
               let scheme = url.scheme?.lowercased(),
               ["http", "https"].contains(scheme),
               url.host != nil {
                Section("Job Posting") {
                    Link(destination: url) {
                        Label(
                            "View Original Job Posting",
                            systemImage: "arrow.up.right.square"
                        )
                    }
                }
            }

            Section {
                Button("Delete Saved Internship", role: .destructive) {
                    showDeleteConfirmation = true
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Theme.background)
        .navigationTitle("Internship Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.clearError()
        }
        .confirmationDialog(
            "Delete Saved Internship?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                deleteInternship()
            }
        } message: {
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

    // MARK: - Actions

    /// Updates the internship's application status.
    private func updateStatus() {
        if viewModel.updateApplicationStatus(id: internship.id, to: selectedStatus) {
            dismiss()
        }
    }

    /// Deletes the saved internship.
    private func deleteInternship() {
        if viewModel.deleteInternship(id: internship.id) {
            dismiss()
        }
    }
}
