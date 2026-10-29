//
//  InternshipPrepCard.swift
//  StudyPlannerV2
//
//  Created by Pichaya Viwatassawin on 29/10/2026.
//

import SwiftUI

/// Card on dashboard for student's next internship and its requirements
struct InternshipPrepCard: View {
    let internship: SavedInternship
    let completedCount: Int
    let totalCount: Int
    var requirements: [InternshipRequirement] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Internship Prep")
                .font(.headline)
                .fontWeight(.bold)

            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(internship.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)

                    Text(subtitleText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Label(
                    internship.applicationStatus.displayName,
                    systemImage: internship.applicationStatus.icon
                )
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(internship.applicationStatus.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(internship.applicationStatus.color.opacity(0.15), in: Capsule())
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

    private var subtitleText: String {
        if let deadline = internship.applicationDeadline {
            return "\(internship.company) · Apply by \(deadline.formatted(.dateTime.day().month(.abbreviated)))"
        }
        return internship.company
    }

    /// Next 3 unfinished requirements with a due date, earliest first
    private var nextRequirements: [InternshipRequirement] {
        var result: [InternshipRequirement] = []
        for requirement in requirements where !requirement.isCompleted && requirement.dueDate != nil {
            result.append(requirement)
        }
        result.sort { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
        return Array(result.prefix(3))
    }
}

#Preview {
    let internship = SavedInternship(
        jobID: "preview-1",
        title: "iOS Developer Intern",
        company: "Atlassian",
        applicationDeadline: Calendar.current.date(byAdding: .day, value: 10, to: .now),
        applicationStatus: .applied
    )

    InternshipPrepCard(
        internship: internship,
        completedCount: 1,
        totalCount: 3,
        requirements: [
            InternshipRequirement(
                internshipID: internship.id,
                name: "Update resume",
                category: .applicationDocuments,
                dueDate: Calendar.current.date(byAdding: .day, value: 2, to: .now)
            ),
            InternshipRequirement(
                internshipID: internship.id,
                name: "Practise interview questions",
                category: .interviewPreparation,
                dueDate: Calendar.current.date(byAdding: .day, value: 5, to: .now)
            )
        ]
    )
    .padding()
    .background(Theme.background)
}
