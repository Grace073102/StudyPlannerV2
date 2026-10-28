//
//  PDFPreviewView.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 20/10/2026.
//


import SwiftUI
import PDFKit

struct PDFPreviewView: View {

    let pdfURL: URL

    @State private var pdfDocument: PDFDocument?
    @State private var errorMessage: String?
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Opening PDF...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else if let pdfDocument {
                PDFKitView(document: pdfDocument)

            } else {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.orange)

                    Text("Unable to Open PDF")
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text(errorMessage ?? "An unknown error occurred.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Button("Try Again") {
                        loadPDF()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.accentFill)
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle(pdfURL.lastPathComponent)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(
                    item: pdfURL,
                    preview: SharePreview(pdfURL.lastPathComponent)
                ) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.body)
                }
                .disabled(
                    isLoading ||
                    pdfDocument == nil ||
                    !FileManager.default.isReadableFile(
                        atPath: pdfURL.path
                    )
                )
                .accessibilityLabel("Share PDF")
            }
        }
        .onAppear {
            loadPDF()
        }
    }

    private func loadPDF() {
        isLoading = true
        errorMessage = nil
        pdfDocument = nil

        guard FileManager.default.fileExists(
            atPath: pdfURL.path
        ) else {
            errorMessage =
                "This PDF file no longer exists. It may have been deleted or moved."
            isLoading = false
            return
        }

        guard FileManager.default.isReadableFile(
            atPath: pdfURL.path
        ) else {
            errorMessage =
                "This PDF cannot be accessed. Please check the file permissions."
            isLoading = false
            return
        }

        guard let document = PDFDocument(url: pdfURL),
              document.pageCount > 0 else {
            errorMessage =
                "This PDF is corrupted, invalid, password-protected, or contains no readable pages."
            isLoading = false
            return
        }

        if document.isLocked {
            errorMessage =
                "This PDF is password-protected and cannot be previewed without unlocking it."
            isLoading = false
            return
        }

        pdfDocument = document
        isLoading = false
    }
}

private struct PDFKitView: UIViewRepresentable {

    let document: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()

        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.document = document

        return pdfView
    }

    func updateUIView(
        _ uiView: PDFView,
        context: Context
    ) {
        if uiView.document !== document {
            uiView.document = document
        }
    }
}
