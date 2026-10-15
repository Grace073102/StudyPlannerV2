//
//  PlaceholderView.swift
//  StudyPlannerV2
//
//  Created by Pichaya Viwatassawin on 16/10/2026.
//

import SwiftUI

struct PlaceholderView: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        NavigationStack {
            ContentUnavailableView (title, systemImage: systemImage, description: Text("Section is coming soon"))
                .navigationTitle(title)
        }
    }
}

#Preview {
    PlaceholderView(title: "Placements", systemImage: "briefcase")
}
