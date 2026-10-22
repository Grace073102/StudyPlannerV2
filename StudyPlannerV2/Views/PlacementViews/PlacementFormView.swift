//
//  PlacementFormView.swift
//  StudyPlannerV2
//
//  Created by emily zhang on 21/10/2026.
//

import SwiftUI

/// Allows students to add or edit a placement.
struct PlacementFormView: View {

    @ObservedObject var viewModel: PlacementViewModel
    @Environment(\.dismiss) private var dismiss

    /// Existing placement to edit, or nil when adding.
    var placement: Placement?

    @State private var name: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var placementDescription: String
    @State private var selectedSubjectID: UUID?

    /// Creates a form for adding or editing a placement.
    init(viewModel: PlacementViewModel, placement: Placement? = nil) {
        self.viewModel = viewModel
        self.placement = placement

        _name = State(initialValue: placement?.name ?? "")
        _startDate = State(initialValue: placement?.startDate ?? Date())
        _endDate = State(initialValue: placement?.endDate ?? Date())
        _placementDescription = State(initialValue: placement?.description ?? "")
        _selectedSubjectID = State(initialValue: placement?.subjectID)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Placement Name") {
                    TextField("e.g. Teaching Professional Experience", text: $name)
                }

                Section("Linked Subject (Optional)") {
                    Picker("Subject", selection: $selectedSubjectID) {
                        Text("None")
                            .tag(nil as UUID?)
                        ForEach(viewModel.subjects, id: \.id) {subject in
                            Text(subject.name)
                                .tag(Optional(subject.id))
                        }
                    }
                    if viewModel.subjects.isEmpty {
                        Text("No subject available. Add a subject in the Assignments tab first.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Description (Optional)") {
                    TextField(
                        "Anything you want to remember",
                        text: $placementDescription,
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                }

                Section("Placement Dates") {
                    DatePicker(
                        "Start Date",
                        selection: $startDate,
                        displayedComponents: .date
                    )

                    DatePicker(
                        "End Date",
                        selection: $endDate,
                        displayedComponents: .date
                    )
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle(placement == nil ? "Add Placement" : "Edit Placement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.clearError()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePlacement()
                    }
                }
            }
            .onAppear {
                viewModel.clearError()
                viewModel.loadSubjects()
            }
            .alert(
                "Placement Error",
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

    /// Saves a new placement or updates an existing one.
    private func savePlacement() {
        if let placement {
            // Save the subject selected by the student
            let updatedPlacement = Placement(
                id: placement.id,
                name: name,
                startDate: startDate,
                endDate: endDate,
                description: placementDescription,
                subjectID: selectedSubjectID
                
            )

            if viewModel.updatePlacement(updatedPlacement) {
                dismiss()
            }
        } else {
            let newPlacement = Placement(
                name: name,
                startDate: startDate,
                endDate: endDate,
                description: placementDescription,
                subjectID: selectedSubjectID
            )

            if viewModel.addPlacement(newPlacement) {
                dismiss()
            }
        }
    }
}
