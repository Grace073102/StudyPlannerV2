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

    var body: some View {
        PDFKitView(url: pdfURL)
            .navigationTitle(pdfURL.lastPathComponent)
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemBackground))
    }
}

private struct PDFKitView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.document = PDFDocument(url: url)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        if uiView.document?.documentURL != url {
            uiView.document = PDFDocument(url: url)
        }
    }
}
