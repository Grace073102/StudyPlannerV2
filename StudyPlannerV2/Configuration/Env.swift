//
//  Env.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 24/10/2026.
//

import Foundation

enum Env {
    enum ConfigurationError: LocalizedError {
        case missingAPIKey

        var errorDescription: String? {
            "Add your CleanJobData key to Development.xcconfig."
        }
    }

    static func cleanJobDataAPIKey() throws -> String {
        guard let value = Bundle.main.object(
            forInfoDictionaryKey: "CLEANJOBDATA_API_KEY"
        ) as? String else {
            throw ConfigurationError.missingAPIKey
        }

        let key = value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !key.isEmpty,
              key != "YOUR_API_KEY_HERE",
              !key.contains("$(")
        else {
            throw ConfigurationError.missingAPIKey
        }

        return key
    }
}
