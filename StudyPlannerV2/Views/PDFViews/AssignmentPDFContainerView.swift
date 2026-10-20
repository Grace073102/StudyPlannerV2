//
//  AssignmentPDFContainerView.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 20/10/2026.
//


import SwiftUI

struct AssignmentPDFContainerView: View {

    let attachedPDFs: [URL]
    let onDelete: (URL) -> Void

    @State private var pdfToDelete: URL?
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Label("Notes", systemImage: "folder.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                Text("\(attachedPDFs.count) files")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if attachedPDFs.isEmpty {

                Text("No PDFs attached yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

            } else {

                ForEach(attachedPDFs, id: \.self) { pdf in

                    HStack(spacing: 8) {

                        NavigationLink {
                            PDFPreviewView(pdfURL: pdf)
                        } label: {

                            HStack(spacing: 12) {

                                Image(systemName: "doc.richtext.fill")
                                    .foregroundStyle(.red)

                                Text(pdf.lastPathComponent)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                    .lineLimit(2)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        Button {
                            pdfToDelete = pdf
                            showDeleteConfirmation = true
                        } label: {

                            Image(systemName: "trash")
                                .font(.subheadline)
                                .foregroundStyle(.red)
                                .frame(width: 36, height: 36)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(
                            "Delete \(pdf.lastPathComponent)"
                        )
                    }
                    .padding(12)
                    .background(
                        Color(.secondarySystemGroupedBackground)
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 10)
                    )
                }
            }
        }
        .padding(12)
        .background(
            Color(.tertiarySystemGroupedBackground)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .alert(
            "Delete PDF?",
            isPresented: $showDeleteConfirmation
        ) {

            Button("Delete", role: .destructive) {
                if let pdfToDelete {
                    onDelete(pdfToDelete)
                }

                pdfToDelete = nil
            }

            Button("Cancel", role: .cancel) {
                pdfToDelete = nil
            }

        } message: {
            Text(
                "This PDF attachment will be permanently removed from CampusFlow."
            )
        }
    }
}
