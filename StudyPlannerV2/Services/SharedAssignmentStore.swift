//
//  SharedAssignmentStore.swift
//  StudyPlannerV2
//
//  Created by Grace Chi Yen Chong on 20/10/2026.
//

import Foundation

struct SharedAssignment: Codable, Identifiable {
    let id: String
    let title: String
}

enum SharedAssignmentStore {

    static let appGroupID = "group.com.campusflow.shared"

    private static var sharedFileURL: URL? {
        FileManager.default
            .containerURL(
                forSecurityApplicationGroupIdentifier: appGroupID
            )?
            .appendingPathComponent("assignments.json")
    }

    static func save(_ assignments: [SharedAssignment]) throws {
        guard let url = sharedFileURL else {
            throw SharedAssignmentError.containerUnavailable
        }

        let data = try JSONEncoder().encode(assignments)

        try data.write(
            to: url,
            options: .atomic
        )
    }

    static func load() throws -> [SharedAssignment] {
        guard let url = sharedFileURL else {
            throw SharedAssignmentError.containerUnavailable
        }

        guard FileManager.default.fileExists(atPath: url.path) else {
            return []
        }

        let data = try Data(contentsOf: url)

        return try JSONDecoder().decode(
            [SharedAssignment].self,
            from: data
        )
    }
}

enum SharedAssignmentError: LocalizedError {
    case containerUnavailable

    var errorDescription: String? {
        switch self {
        case .containerUnavailable:
            return "CampusFlow shared storage is unavailable. Please check the App Group configuration."
        }
    }
}
