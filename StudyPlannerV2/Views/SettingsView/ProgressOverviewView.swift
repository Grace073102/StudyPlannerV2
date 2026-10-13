//
//  ProgressOverviewView.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 14/10/2026.
//

import SwiftUI

struct ProgressOverviewView: View {

    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Title
            Text("Progress Overview")
                .font(.headline)
                .fontWeight(.bold)

            HStack {

                Spacer()

                // Circular Progress
                ZStack {

                    // Background circle
                    Circle()
                        .stroke(
                            Color(.systemGray5),
                            lineWidth: 10
                        )

                    // Progress circle
                    Circle()
                        .trim(
                            from: 0,
                            to: progress
                        )
                        .stroke(
                            Color.blue,
                            style: StrokeStyle(
                                lineWidth: 10,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(
                            .easeInOut,
                            value: progress
                        )

                    // Percentage in the middle
                    VStack(spacing: 2) {

                        Text("\(Int(progress * 100))%")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Completed")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(
                    width: 120,
                    height: 120
                )

                Spacer()
            }

            // Message
            Text(progressMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )
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

    // Message changes depending on progress
    private var progressMessage: String {

        if progress == 0 {
            return "Let's get started!"
        } else if progress < 0.5 {
            return "Good start! Keep going."
        } else if progress < 1 {
            return "You're making great progress!"
        } else {
            return "All tasks completed!"
        }
    }
}
