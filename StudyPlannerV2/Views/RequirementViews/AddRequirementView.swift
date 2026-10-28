//
//  AddRequirementView.swift
//  StudyPlannerV2
//
//  Created by Djy on 15/10/2026.
//

import SwiftUI

struct AddRequirementView: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: RequirementViewModel

    @State private var name = ""
    @State private var category: PlacementRequirement.Category = .applicationsAndRegistration
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var hasExpiryDate = false
    @State private var expiryDate = Date()
    @State private var showingError = false
    @State private var errorMessage = ""
    
    let placementID: UUID

    var body: some View {
        NavigationStack {
            Form {

                Section("Requirement Details") {

                    TextField("Requirement Name", text: $name)

                    Picker("Category", selection: $category) {
                        ForEach(PlacementRequirement.Category.allCases, id: \.self) { category in
                            Text(category.rawValue)
                                .tag(category)
                        }
                    }
                }

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
            .navigationTitle("Add Requirement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        do {
                            try viewModel.add(
                                placementID: placementID,
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
                    } label: {
                        Text("Save")
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.onAccent)
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .fontWeight(.semibold)
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.accentFill)
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

