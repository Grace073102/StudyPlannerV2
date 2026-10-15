//
//  RequirementListView.swift
//  StudyPlannerV2
//
//  Created by Djy on 15/10/2026.
//

import SwiftUI

struct RequirementListView: View {

    @ObservedObject var viewModel: RequirementViewModel
    let placementID: UUID

    @State private var showingAddRequirement = false

    var body: some View {

        let requirements = viewModel.requirements(for: placementID)
        let completedCount = viewModel.completedCount(for: placementID)
        let progress = viewModel.progress(for: placementID)

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Overall Progress
                VStack(alignment: .leading, spacing: 12) {

                    HStack {
                        Text("Overall Progress")
                            .font(.headline)

                        Spacer()

                        Text("\(Int(progress * 100))%")
                            .foregroundStyle(Color.accentColor)
                    }

                    ProgressView(value: progress)
                        .tint(Color.accentColor)

                    Text("\(completedCount) of \(requirements.count) completed")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18))

                // Requirement List
                Text("Requirements")
                    .font(.headline)

                if requirements.isEmpty {

                    VStack(spacing: 12) {
                        Image(systemName: "checklist")
                            .font(.largeTitle)
                            .foregroundStyle(Color.accentColor)

                        Text("No Requirements Yet")
                            .font(.headline)

                        Text("Add requirements to track your placement preparation.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(32)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                } else {

                    ForEach(requirements) { requirement in

                        HStack(spacing: 12) {

                            Image(systemName: requirement.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(requirement.isCompleted ? .green : .gray)

                            VStack(alignment: .leading, spacing: 6) {

                                Text(requirement.name)
                                    .font(.headline)

                                Text(requirement.category.rawValue)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                if let dueDate = requirement.dueDate {
                                    Text("Due: \(dueDate.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.caption)
                                }

                                if let expiryDate = requirement.expiryDate {
                                    Text("Expires: \(expiryDate.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.caption)
                                        .foregroundStyle(
                                            Calendar.current.startOfDay(for: expiryDate) <
                                            Calendar.current.startOfDay(for: Date())
                                            ? Color.red : Color.secondary
                                        )
                                }
                            }

                            Spacer()
                        }
                        .padding(16)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                }
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Checklist")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddRequirement = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}
