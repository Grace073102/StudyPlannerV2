//
//  UpcomingDeadlinesView.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 14/10/2026.
//

import SwiftUI

struct UpcomingDeadlinesView: View {
    let items: [UpcomingItem]

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
                    Text("See All")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }

            if items.isEmpty {
                Text("No upcoming deadlines")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            } else {
                ForEach(items) { item in
                    HStack(spacing: 12) {
                        Image(systemName: item.kind == .assignment ? "doc.text": "briefcase")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(iconColour(for: item))
                            .frame(width: 36, height: 36)
                            .background(
                                iconColour(for: item).opacity(0.15),
                                in: .rect(cornerRadius: 10)
                            )
                            .accessibilityLabel(item.kind == .assignment ? "Assignment": "Placement requirement")

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .lineLimit(1)

                            Text(item.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }

                        Spacer()

                        Text(
                            item.dueDate,
                            format: .dateTime.day().month(.abbreviated)
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)

                        if let priority = item.priority {
                            Text(priority.rawValue)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundStyle(priority.color)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(priority.color.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(10)
                    .frame(minHeight: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.tertiarySystemGroupedBackground))
                    )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(
                    color: .black.opacity(0.06),
                    radius: 5,
                    x: 0,
                    y: 2
                )
        )
    }
    
    private func iconColour(for item: UpcomingItem) -> Color {
        item.kind == .assignment ? .accentColor : .yellow
    }
}
