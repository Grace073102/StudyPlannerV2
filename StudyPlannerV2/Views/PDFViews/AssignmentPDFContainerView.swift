//
//  AssignmentPDFContainerView.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 20/10/2026.
//


import SwiftUI

struct AssignmentPDFContainerView: View {
    let attachedPDFs: [URL]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("PDF Documents", systemImage: "folder.fill")
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
                        .padding(12)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(12)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
