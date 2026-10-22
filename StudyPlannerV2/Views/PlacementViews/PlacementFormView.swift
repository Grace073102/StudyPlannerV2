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
    @State private var discipline: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var placementDescription: String

    /// Creates a form for adding or editing a placement.
    init(viewModel: PlacementViewModel, placement: Placement? = nil) {
        self.viewModel = viewModel
        self.placement = placement

        _name = State(initialValue: placement?.name ?? "")
        _discipline = State(initialValue: placement?.discipline ?? "")
        _startDate = State(initialValue: placement?.startDate ?? Date())
        _endDate = State(initialValue: placement?.endDate ?? Date())
        _placementDescription = State(initialValue: placement?.description ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Placement Name") {
                    TextField("e.g. Teaching Professional Experience", text: $name)
                }

                Section("Discipline") {
                    TextField("e.g. Education", text: $discipline)
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
            // Keep the existing subject, so editing never removes it.
            let updatedPlacement = Placement(
                id: placement.id,
                name: name,
                discipline: discipline,
                startDate: startDate,
                endDate: endDate,
                description: placementDescription,
                subjectID: placement.subjectID
            )

            if viewModel.updatePlacement(updatedPlacement) {
                dismiss()
            }
        } else {
            let newPlacement = Placement(
                name: name,
                discipline: discipline,
                startDate: startDate,
                endDate: endDate,
                description: placementDescription
            )

            if viewModel.addPlacement(newPlacement) {
                dismiss()
            }
        }
    }
}
