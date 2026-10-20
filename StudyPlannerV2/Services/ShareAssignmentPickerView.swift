//
//  ShareAssignmentPickerView.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 20/10/2026.
//

import SwiftUI

struct ShareAssignmentPickerView: View {

    let pdfName: String
    let assignments: [SharedAssignment]
    let onImport: (SharedAssignment) -> Void
    let onCancel: () -> Void

    @State private var selectedAssignmentID: String?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {

                HStack(spacing: 12) {
                    Image(systemName: "doc.richtext.fill")
                        .font(.title2)
                        .foregroundStyle(.red)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(pdfName)
                            .font(.headline)
                            .lineLimit(2)

                        Text("PDF Document")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .padding(16)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Text("Choose an Assignment")
                    .font(.headline)

                if assignments.isEmpty {
                    ContentUnavailableView(
                        "No Assignments",
                        systemImage: "folder.badge.questionmark",
                        description: Text(
                            "Open CampusFlow and create an assignment before sharing a PDF."
                        )
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(assignments) { assignment in
                                Button {
                                    selectedAssignmentID = assignment.id
                                } label: {
                                    HStack {
                                        Text(assignment.title)
                                            .foregroundStyle(.primary)

                                        Spacer()

                                        Image(
                                            systemName:
                                                selectedAssignmentID == assignment.id
                                                ? "checkmark.circle.fill"
                                                : "circle"
                                        )
                                        .foregroundStyle(
                                            selectedAssignmentID == assignment.id
                                            ? Color.accentColor
                                            : .secondary
                                        )
                                    }
                                    .padding(16)
                                    .background(
                                        Color(.secondarySystemBackground)
                                    )
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 12)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                Spacer(minLength: 0)

                Button {
                    guard let selectedAssignmentID,
                          let selected = assignments.first(where: {
                              $0.id == selectedAssignmentID
                          }) else {
                        return
                    }

                    onImport(selected)
                } label: {
                    Label("Attach PDF", systemImage: "paperclip")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(14)
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedAssignmentID == nil)
            }
            .padding(20)
            .navigationTitle("Import to CampusFlow")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
    }
}
