//
//  AssignmentProgressView.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 14/10/2026.
//

import SwiftUI

struct AssignmentProgressView: View {
    let assignment: Assignment

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Overall Progress")
                        .font(.headline)
                        .fontWeight(.semibold)

                    Text(
                        "\(Int(progress * 100))% completed"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
            }

            ProgressView(value: progress)
                .tint(.blue)
                .scaleEffect(x: 1, y: 1.5)

            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.caption)

                    Text(
                        assignment.dueDate,
                        format: .dateTime
                            .day()
                            .month(.abbreviated)
                            .year()
                    )
                    .font(.caption)
                }
                .foregroundStyle(.secondary)

                Spacer()

                Text(assignment.priority.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        assignment.priority.color
                    )
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        assignment.priority.color
                            .opacity(0.12)
                    )
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(
                    color: .black.opacity(0.05),
                    radius: 5,
                    x: 0,
                    y: 2
                )
        )
    }

    private var progress: Double {
        guard !assignment.tasks.isEmpty else {
            return 0
        }

        let completedTasks =
            assignment.tasks.filter {
                $0.isCompleted
            }.count

        return Double(completedTasks) /
            Double(assignment.tasks.count)
    }
}
