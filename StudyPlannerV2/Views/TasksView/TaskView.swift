//
//  TaskView.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 14/10/2026.
//

import SwiftUI

struct TaskView: View {
    
    let task: AcademicTask
    var course: String? = nil
    var onChange: () -> Void = {}

    var body: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation {
                    onChange()
                }
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundStyle(task.isCompleted ? .blue : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.subheadline)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)

                if let course = course {
                    Text(course)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.blue)
                }

                HStack(spacing: 10) {
                    if let plannedDate = task.plannedDate {
                        HStack(spacing: 3) {
                            Image(systemName: "calendar")
                            Text(plannedDate, format: .dateTime.day().month(.abbreviated))
                        }
                    }

                    if let estimatedMinutes = task.estimatedMinutes {
                        HStack(spacing: 3) {
                            Image(systemName: "clock")
                            Text(formattedDuration(estimatedMinutes))
                        }
                    }
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    private func formattedDuration(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) min"
        }

        let hours = minutes / 60
        let remainingMinutes = minutes % 60

        if remainingMinutes == 0 {
            return "\(hours) hr"
        }

        return "\(hours) hr \(remainingMinutes) min"
    }
}
