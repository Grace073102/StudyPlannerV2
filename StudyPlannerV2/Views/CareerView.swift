//
//  CareerView.swift
//  StudyPlannerV2
//
//  Created by Pichaya Viwatassawin on 21/10/2026.
//

import SwiftUI
import SwiftData

struct CareerView: View {
    @ObservedObject var placementViewModel: PlacementViewModel
    @ObservedObject var savedInternshipViewModel: SavedInternshipViewModel
    
    @State private var selection: CareerSection = .placements
    
    enum CareerSection: String, CaseIterable, Identifiable {
        case placements = "Placements"
        case internships = "Internships"
        
        var id: Self {self}
    }
    
    var body: some View {
        NavigationStack{
            Group{
                switch selection {
                case .placements:
                    PlacementListView(viewModel: placementViewModel)
                case .internships:
                    SavedInternshipListView(viewModel: savedInternshipViewModel)
                }
            }
            .safeAreaInset(edge: .top) {
                Picker("Career section", selection: $selection) {
                    ForEach(CareerSection.allCases) { section in
                        Text(section.rawValue).tag(section)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, Theme.padding)
                .padding(.vertical, 8)
            }
        }
        .background(Theme.background)
    }
}

#Preview {
    let schema = Schema([
        StoredPlacement.self,
        StoredPlacementRequirement.self,
        StoredSavedInternship.self
    ])
    let configuration = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: true
    )

    let container = try! ModelContainer(
        for: schema,
        configurations: [configuration]
    )
    
    CareerView(placementViewModel: PlacementViewModel(repository: SwiftDataPlacementRepository(container: container)),savedInternshipViewModel: SavedInternshipViewModel(repository: SwiftDataSavedInternshipRepository(container: container)))
        .environmentObject(RequirementViewModel(repository: SwiftDataRequirementRepository(container: container)))
}
