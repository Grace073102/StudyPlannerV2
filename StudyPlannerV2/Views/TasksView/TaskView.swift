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
        HStack(spacing: 4) {
            Button {
                withAnimation {
                    onChange()
                }
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isCompleted ? Color.accentColor : .secondary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.subheadline)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)

                HStack(spacing: 8) {
                    if let course {
                        Text(course)
                    }

                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            if let minutes = task.estimatedMinutes {
                Text(formattedDuration(minutes))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
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
