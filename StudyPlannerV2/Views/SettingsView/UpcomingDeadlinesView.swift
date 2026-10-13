//
//  UpcomingDeadlinesView.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 14/10/2026.
//

import SwiftUI

struct UpcomingDeadlinesView: View {
    let assignments: [Assignment]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Upcoming Deadlines")
                        .font(.headline)
                        .fontWeight(.bold)

                    Text("Stay on top of your work")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                NavigationLink {
                    AssignmentListView()
                } label: {
                    HStack(spacing: 3) {
                        Text("View All")
                        Image(systemName: "chevron.right")
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                }
            }

            if assignments.isEmpty {
                Text("No upcoming deadlines")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            } else {
                ForEach(
                    assignments
                        .sorted { $0.dueDate < $1.dueDate }
                        .prefix(5)
                ) { assignment in
                    HStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(assignment.priority.color)
                            .frame(width: 4, height: 52)

                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(assignment.title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)

                                Text(assignment.course)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            Text(
                                assignment.dueDate,
                                format: .dateTime
                                    .day()
                                    .month(.abbreviated)
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)

                            Text(assignment.priority.rawValue)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundStyle(
                                    assignment.priority.color
                                )
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    assignment.priority.color
                                        .opacity(0.12)
                                )
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 10)
                    }
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                Color(
                                    .secondarySystemBackground
                                )
                            )
                    )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(
                    color: .black.opacity(0.06),
                    radius: 5,
                    x: 0,
                    y: 2
                )
        )
    }
}
