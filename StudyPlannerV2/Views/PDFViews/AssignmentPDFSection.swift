//
//  AssignmentPDFSection.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 20/10/2026.
//

import SwiftUI
import UniformTypeIdentifiers

struct AssignmentPDFSection: View {

    let assignmentID: String

    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel: DocumentViewModel
    @State private var showPDFPicker = false

    init(assignmentID: String) {
        self.assignmentID = assignmentID

        _viewModel = StateObject(
            wrappedValue: DocumentViewModel(assignmentID: assignmentID)
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("PDF Attachments")
                .font(.headline)

            Text("Attach PDFs related to this assignment.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            AssignmentPDFContainerView(
                attachedPDFs: viewModel.attachedPDFs,
                onDelete: { pdf in
                    viewModel.deletePDF(pdf)
                }
            )

            Button {
                showPDFPicker = true
            } label: {
                Label(
                    "Attach PDF",
                    systemImage: "plus.circle.fill"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(Theme.card))
        )

        .fileImporter(
            isPresented: $showPDFPicker,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in

            switch result {

            case .success(let urls):
                if let url = urls.first {
                    viewModel.importPDF(from: url)
                }

            case .failure(let error):
                viewModel.errorMessage = error.localizedDescription
            }
        }

        .alert(
            "PDF Operation Failed",
            isPresented: Binding(
                get: {
                    viewModel.errorMessage != nil
                },
                set: { isPresented in
                    if !isPresented {
                        viewModel.errorMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred.")
        }

        .onAppear {
            viewModel.refresh()
        }

        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                viewModel.refresh()
            }
        }
    }
}
