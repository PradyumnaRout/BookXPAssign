//
//  PdfView.swift
//  BookXPAssign
//
//  Created by vikash kumar on 21/06/25.
//

import SwiftUI
import PDFPreviewer

struct PdfView: View {
    static let TestPDFURL: URL = {
        guard let pdfURL = URL(string: AppConstants.pdfUrl) else {
            fatalError()
        }
        return pdfURL
    }()
    
    @StateObject var controller = PDFPreviewerModel()
    var body: some View {
        VStack {
            PDFPreviewer(model: controller)
                .padding(.vertical)
                .task {
                    await controller.loadDocument(from: Self.TestPDFURL)
                }
        }
    }
}

#Preview {
    PdfView()
}
