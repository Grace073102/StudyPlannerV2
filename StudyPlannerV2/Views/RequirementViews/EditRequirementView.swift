//
//  EditRequirementView.swift
//  StudyPlannerV2
//
//  Created by Djy on 15/10/2026.
//

import SwiftUI

struct EditRequirementView: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: RequirementViewModel

    @State private var name: String
    @State private var category: PlacementRequirement.Category
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    @State private var hasExpiryDate: Bool
    @State private var expiryDate: Date
    @State private var showingError = false
    @State private var errorMessage = ""

    let requirementID: UUID
    
    init(
        viewModel: RequirementViewModel,
        requirement: PlacementRequirement
    ) {
        self.viewModel = viewModel
        self.requirementID = requirement.id

        _name = State(initialValue: requirement.name)
        _category = State(initialValue: requirement.category)
        _hasDueDate = State(initialValue: requirement.dueDate != nil)
        _dueDate = State(initialValue: requirement.dueDate ?? Date())
        _hasExpiryDate = State(initialValue: requirement.expiryDate != nil)
        _expiryDate = State(initialValue: requirement.expiryDate ?? Date())
    }

    var body: some View {

        NavigationStack {

            Form {

                // Requirement Details
                Section("Requirement Details") {

                    TextField("Requirement Name", text: $name)

                    Picker("Category", selection: $category) {
                        ForEach(PlacementRequirement.Category.allCases, id: \.self) { category in
                            Text(category.rawValue)
                                .tag(category)
                        }
                    }
                }

                // Important Dates
                Section("Important Dates") {

                    Toggle("Set Due Date", isOn: $hasDueDate)
                        .tint(Color.accentColor)

                    if hasDueDate {
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    }

                    Toggle("Set Expiry Date", isOn: $hasExpiryDate)
                        .tint(Color.accentColor)

                    if hasExpiryDate {
                        DatePicker("Expiry Date", selection: $expiryDate, displayedComponents: .date)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle("Edit Requirement")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {

                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {

                        do {
                            try viewModel.updateRequirement(
                                id: requirementID,
                                name: name,
                                category: category,
                                dueDate: hasDueDate ? dueDate : nil,
                                expiryDate: hasExpiryDate ? expiryDate : nil
                            )

                            dismiss()

                        } catch {
                            errorMessage = error.localizedDescription
                            showingError = true
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .fontWeight(.semibold)
                }
            }
            .alert("Unable to Save", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
}
