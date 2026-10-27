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

    /// An error from this screen, shown inside the form instead of an alert.
    @State private var errorText: String?

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

                Button {
                    updateStatus()
                } label: {
                    Text("Update Status")
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.onAccent)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                }
                .listRowBackground(
                    Color.accentColor.opacity(selectedStatus == internship.applicationStatus ? 0.5 : 1)
                )
                .disabled(selectedStatus == internship.applicationStatus)
            }

            // Only open web links (http or https) that have a host.
            if let url = internship.companyWebsiteURL,
               let scheme = url.scheme?.lowercased(),
               ["http", "https"].contains(scheme),
               url.host != nil {
                Section("Company") {
                    Link(destination: url) {
                        Label("Visit Company Website", systemImage: "globe")
                    }
                }
            }

            // Errors from this screen are shown here, not in an alert, so the list screen's alert does not show them a second time.
            if let errorText {
                Section {
                    Label(errorText, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
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
        .navigationTitle("Your Saved Internship")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.clearError()
        }
        .alert(
            "Delete Saved Internship?",
            isPresented: $showDeleteConfirmation
        ) {
            Button("Delete", role: .destructive) {
                deleteInternship()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete \(internship.title)?")
        }
    }
    
    // MARK: - Actions

    /// Updates the internship's application status.
    private func updateStatus() {
        errorText = nil
        if viewModel.updateApplicationStatus(id: internship.id, to: selectedStatus) {
            dismiss()
        } else {
            showError()
        }
    }

    /// Deletes the saved internship.
    private func deleteInternship() {
        errorText = nil
        if viewModel.deleteInternship(id: internship.id) {
            dismiss()
        } else {
            showError()
        }
    }

    /// Takes the error from the ViewModel, so only this screen shows it.
    private func showError() {
        errorText = viewModel.errorMessage
        viewModel.clearError()
    }
}
