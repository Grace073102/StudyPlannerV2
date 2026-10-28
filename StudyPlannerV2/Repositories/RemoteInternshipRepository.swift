//
//  RemoteInternshipRepository.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 24/10/2026.
//

/// Calls CleanJobData directly for local development.
/// The API key comes from the developer's private configuration.

import Foundation

@MainActor
protocol InternshipDiscoveryRepository {
    func search(
        _ query: InternshipSearch
    ) async throws -> InternshipPage
}

enum InternshipDiscoveryError: LocalizedError, Equatable {
    case invalidEndpoint
    case invalidResponse
    case serviceUnavailable(Int)
    case invalidData

    var errorDescription: String? {
        switch self {
        case .invalidEndpoint:
            return "The internship service is not configured correctly."

        case .invalidResponse:
            return "The internship service returned an unexpected response."

        case .serviceUnavailable(let status):
            if status == 429 {
                return "The internship request limit has been reached. Please try again later."
            }

            return "Internships could not be loaded. Please try again later."

        case .invalidData:
            return "The internship data could not be read."
        }
    }
}

@MainActor
final class RemoteInternshipRepository:
    InternshipDiscoveryRepository {

    private let jobsEndpoint: URL
    private let session: URLSession
    private let apiKey: String

    init(
        apiKey: String,
        session: URLSession = .shared
    ) throws {
        let key = apiKey.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !key.isEmpty,
              key != "YOUR_API_KEY_HERE",
              !key.contains("$(")
        else {
            throw Env.ConfigurationError.missingAPIKey
        }

        guard let endpoint = URL(
            string: "https://api.cleanjobdata.com/jobs"
        ) else {
            throw InternshipDiscoveryError.invalidEndpoint
        }

        self.jobsEndpoint = endpoint
        self.apiKey = key
        self.session = session
    }

    func search(
        _ query: InternshipSearch
    ) async throws -> InternshipPage {
        guard var components = URLComponents(
            url: jobsEndpoint,
            resolvingAgainstBaseURL: false
        ) else {
            throw InternshipDiscoveryError.invalidEndpoint
        }

        var items = [
            URLQueryItem(name: "country_id", value: "14"),
            URLQueryItem(
                name: "employment_type",
                value: "INTERN"
            ),
            URLQueryItem(
                name: "sort_by",
                value: "published"
            ),
            URLQueryItem(name: "limit", value: "20"),
            URLQueryItem(
                name: "extra_fields",
                value: "description"
            )
        ]

        let title = query.title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        items.append(
            URLQueryItem(
                name: "title",
                value: title.isEmpty ? "intern" : title
            )
        )

        if query.remoteOnly {
            items.append(
                URLQueryItem(name: "remote", value: "true")
            )
        }

        if let cursor = query.cursor {
            items.append(
                URLQueryItem(name: "cursor", value: cursor)
            )
        }

        components.queryItems = items

        guard let url = components.url else {
            throw InternshipDiscoveryError.invalidEndpoint
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )
        request.setValue(
            "Bearer \(apiKey)",
            forHTTPHeaderField: "Authorization"
        )

        let (data, response) = try await session.data(
            for: request
        )

        try Task.checkCancellation()

        guard let httpResponse = response as? HTTPURLResponse else {
            throw InternshipDiscoveryError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw InternshipDiscoveryError.serviceUnavailable(
                httpResponse.statusCode
            )
        }

    
        do {
            let page = try JSONDecoder().decode(
                InternshipPage.self,
                from: data
            )

            return InternshipPage(
                data: page.data.filter {
                    !$0.hasCompanyOnlyAustralianMatch
                },
                pagination: page.pagination
            )
        } catch {
            throw InternshipDiscoveryError.invalidData
        }
    }
}
