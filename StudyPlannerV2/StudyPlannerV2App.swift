//
//  StudyPlannerV2App.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 14/10/2026.
//

import SwiftUI
import SwiftData

@main
struct StudyPlannerApp: App {
    @State private var startup: Result<SwiftDataAssignmentRepository, Error>

    init() {
        _startup = State(initialValue: Self.prepareStorage())
    }

    var body: some Scene {
        WindowGroup {
            switch startup {
            case .success(let repository):
                RootView(repository: repository)

            case .failure:
                VStack(spacing: 16) {
                    Text("Unable to Open Your Planner")
                        .font(.title2)
                        .bold()

                    Text(
                        "Your saved data has not been cleared. Please try again."
                    )
                    .multilineTextAlignment(.center)

                    Button("Try Again") {
                        startup = Self.prepareStorage()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
    }

    private static func prepareStorage()
        -> Result<SwiftDataAssignmentRepository, Error> {
        do {
            let schema = Schema([
                StoredAssignment.self,
                StoredAcademicTask.self,
                StoredMigration.self
            ])

            let configuration = ModelConfiguration(
                "StudyPlannerSwiftData",
                schema: schema,
                isStoredInMemoryOnly: false
            )

            let container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )

            let repository = SwiftDataAssignmentRepository(
                container: container
            )

            try repository.migrateLegacyAssignmentsIfNeeded()

            return .success(repository)
        } catch {
            return .failure(error)
        }
    }
}
