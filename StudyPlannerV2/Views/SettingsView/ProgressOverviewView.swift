//
//  ProgressOverviewView.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 14/10/2026.
//

import SwiftUI

struct ProgressOverviewView: View {

    let progress: Double
    let completedCount: Int
    let totalCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Circular Progress
            ZStack {
                // Background circle
                Circle()
                    .stroke(
                        Color(.systemGray5),
                        lineWidth: 7
                    )
                // Progress circle
                Circle()
                    .trim(
                        from: 0,
                        to: progress
                    )
                    .stroke(
                        Color.accentColor,
                        style: StrokeStyle(
                            lineWidth: 7,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(
                        .easeInOut,
                        value: progress
                    )
                
                Text("\(Int(progress * 100))%")
                                    .font(.caption)
                                    .fontWeight(.bold)
            }
            .frame(
                width: 56,
                height: 56
            )
            Text("Overall progress")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text("\(completedCount) of \(totalCount) tasks done")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(Theme.padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Theme.card, in: .rect(cornerRadius: Theme.corner))
    }
}

#Preview {
    ProgressOverviewView(
        progress: 0.6,
        completedCount: 15,
        totalCount: 25
    )
    .padding()
    .background(Theme.background)
}
