//
//  PlacementPrepCard.swift
//  StudyPlannerV2
//
//  Created by Pichaya Viwatassawin on 21/10/2026.
//

import SwiftUI

/// Card on dashboard for student's next placement and its requirements
struct PlacementPrepCard: View {
    let summary: ManagePlacementsUseCase.PlacementSummary
    let completedCount: Int
    let totalCount: Int
    var requirements: [PlacementRequirement] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Placement Prep")
                .font(.headline)
                .fontWeight(.bold)
            
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(summary.placement.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(dateText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text("\(completedCount)/\(totalCount)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
                
            }
            
            ProgressView(value: progress)
                .tint(Color.accentColor)
                .accessibilityLabel("\(completedCount) of \(totalCount) requirements completed")
            
            Text(
                totalCount == 0
                ? "No requirements added yet"
                : "\(completedCount) of \(totalCount) requirements complete"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            
            if !nextRequirements.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(nextRequirements, id: \.id) { requirement in
                        HStack(spacing: 6) {
                            Image(systemName: "circle")
                                .font(.caption2)
                                .accessibilityHidden(true)

                            Text(requirement.name)
                                .lineLimit(1)

                            Spacer()

                            if let dueDate = requirement.dueDate {
                                Text(dueDate, format: .dateTime.day().month(.abbreviated))
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(Theme.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.card, in: .rect(cornerRadius: Theme.corner))
    }
    
    private var progress: Double {
        totalCount == 0 ? 0 : Double(completedCount) / Double(totalCount)
    }
    
    /// Next 3 unfinished requirements with a due date, earliest first
    private var nextRequirements: [PlacementRequirement] {
        var result: [PlacementRequirement] = []
        for requirement in requirements where !requirement.isCompleted && requirement.dueDate != nil {
            result.append(requirement)
        }
        result.sort { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
        return Array(result.prefix(3))
    }
    
    private var dateText: String {
        let format = Date.FormatStyle.dateTime
            .weekday(.abbreviated)
            .day()
            .month(.abbreviated)
        
        switch summary.status {
        case .upcoming:
            return "Starts \(summary.placement.startDate.formatted(format))"
        case .inProgress:
            return "Ends \(summary.placement.endDate.formatted(format))"
        case .completed:
            return "Completed"
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        // Upcoming internship with 3 requirements done
        PlacementPrepCard(
            summary: ManagePlacementsUseCase.PlacementSummary(
                placement: Placement(
                    name: "Clinical Placement",
                    startDate: Calendar.current.date(byAdding: .day, value: 14, to: .now)!,
                    endDate: Calendar.current.date(byAdding: .day, value: 70, to: .now)!
                ),
                status: .upcoming
            ),
            completedCount: 3,
            totalCount: 5
        )

        // No requirements yet
        PlacementPrepCard(
            summary: ManagePlacementsUseCase.PlacementSummary(
                placement: Placement(
                    name: "Teaching Prac 1",
                    startDate: Calendar.current.date(byAdding: .day, value: -3, to: .now)!,
                    endDate: Calendar.current.date(byAdding: .day, value: 20, to: .now)!
                ),
                status: .inProgress
            ),
            completedCount: 0,
            totalCount: 0
        )
    }
    .padding()
    .background(Theme.background)
}
