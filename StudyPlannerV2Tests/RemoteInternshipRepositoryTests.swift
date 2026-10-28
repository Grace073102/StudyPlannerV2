//
//  RemoteInternshipRepositoryTests.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 24/10/2026.
//

import Foundation
import Testing
@testable import StudyPlannerV2

/// Serial execution keeps the shared fake response isolated between tests.
@Suite(.serialized)
@MainActor
struct RemoteInternshipRepositoryTests {

    @Test
    func searchSendsFiltersAndDecodesPagination() async throws {
        let session = makeSession()
        defer {
            session.invalidateAndCancel()
            InternshipURLProtocol.handler = nil
        }

        InternshipURLProtocol.handler = { request in
            let url = try #require(request.url)
            let components = try #require(
                URLComponents(
                    url: url,
                    resolvingAgainstBaseURL: false
                )
            )

            let items = components.queryItems ?? []

            func value(_ name: String) -> String? {
                items.first { $0.name == name }?.value
            }

            #expect(url.host == "api.cleanjobdata.com")
            #expect(url.path == "/jobs")
            #expect(request.httpMethod == "GET")
            #expect(
                request.value(
                    forHTTPHeaderField: "Authorization"
                ) == "Bearer test-key"
            )

            #expect(value("country_id") == "14")
            #expect(value("location") == nil)
            #expect(value("employment_type") == "INTERN")
            #expect(value("title") == "software & design")
            #expect(value("remote") == "true")
            #expect(value("cursor") == "next+page/token=")

            let json = """
            {
                "data": [
                    {
                        "id": "job-123",
                        "title": "Software Intern",
                        "company": {"name": "Example Company"},
                        "location": "Sydney, Australia",
                        "employment_type": "INTERN"
                    }
                ],
                "pagination": {
                    "next_page": "another-cursor"
                }
            }
            """

            return (200, Data(json.utf8))
        }

        let repository = try RemoteInternshipRepository(
            apiKey: "test-key",
            session: session
        )

        let page = try await repository.search(
            InternshipSearch(
                title: "  software & design  ",
                remoteOnly: true,
                cursor: "next+page/token="
            )
        )

        #expect(page.data.count == 1)

        let listing = try #require(page.data.first)
        #expect(listing.id == "job-123")
        #expect(listing.title == "Software Intern")
        #expect(listing.companyDisplayName == "Example Company")
        #expect(listing.employmentType == "INTERN")
        #expect(page.pagination.nextPage == "another-cursor")
    }

    @Test
    func searchExcludesCompanyOnlyAustralianLocationMatches() async throws {
        let session = makeSession()
        defer {
            session.invalidateAndCancel()
            InternshipURLProtocol.handler = nil
        }

        InternshipURLProtocol.handler = { _ in
            let json = """
            {
                "data": [
                    {
                        "id": "incorrect-match",
                        "title": "Intern",
                        "location": "New York",
                        "company": {
                            "name": "Success Academy Charter Schools"
                        },
                        "locations": [
                            {
                                "country_code": "AU",
                                "raw_location": "Success Academy Charter Schools"
                            },
                            {
                                "country_code": "US",
                                "raw_location": "New York"
                            }
                        ]
                    },
                    {
                        "id": "valid-perth",
                        "title": "Engineering Intern",
                        "location": "Perth",
                        "company": {
                            "name": "Example Company"
                        },
                        "locations": [
                            {
                                "country_code": "AU",
                                "raw_location": "Perth"
                            }
                        ]
                    }
                ],
                "pagination": {
                    "next_page": "next-cursor"
                }
            }
            """

            return (200, Data(json.utf8))
        }

        let repository = try RemoteInternshipRepository(
            apiKey: "test-key",
            session: session
        )

        let page = try await repository.search(
            InternshipSearch()
        )

        #expect(page.data.map(\.id) == ["valid-perth"])
        #expect(page.pagination.nextPage == "next-cursor")
    }
    
    @Test
    func rateLimitResponseThrowsExpectedError() async throws {
        let session = makeSession()
        defer {
            session.invalidateAndCancel()
            InternshipURLProtocol.handler = nil
        }

        InternshipURLProtocol.handler = { _ in
            (429, Data())
        }

        let repository = try RemoteInternshipRepository(
            apiKey: "test-key",
            session: session
        )

        await #expect(
            throws: InternshipDiscoveryError.serviceUnavailable(429)
        ) {
            _ = try await repository.search(InternshipSearch())
        }
    }

    @Test
    func malformedResponseThrowsInvalidData() async throws {
        let session = makeSession()
        defer {
            session.invalidateAndCancel()
            InternshipURLProtocol.handler = nil
        }

        InternshipURLProtocol.handler = { _ in
            (200, Data("not valid JSON".utf8))
        }

        let repository = try RemoteInternshipRepository(
            apiKey: "test-key",
            session: session
        )

        await #expect(
            throws: InternshipDiscoveryError.invalidData
        ) {
            _ = try await repository.search(InternshipSearch())
        }
    }

    private func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [InternshipURLProtocol.self]
        return URLSession(configuration: configuration)
    }
}

/// Intercepts requests from the test session before they reach the network.
private final class InternshipURLProtocol:
    URLProtocol, @unchecked Sendable {

    nonisolated(unsafe) static var handler:
        (@Sendable (URLRequest) throws -> (Int, Data))?

    override class func canInit(
        with request: URLRequest
    ) -> Bool {
        true
    }

    override class func canonicalRequest(
        for request: URLRequest
    ) -> URLRequest {
        request
    }

    override func startLoading() {
        do {
            guard let handler = Self.handler,
                  let url = request.url
            else {
                throw URLError(.badServerResponse)
            }

            let (status, data) = try handler(request)

            guard let response = HTTPURLResponse(
                url: url,
                statusCode: status,
                httpVersion: nil,
                headerFields: [
                    "Content-Type": "application/json"
                ]
            ) else {
                throw URLError(.badServerResponse)
            }

            client?.urlProtocol(
                self,
                didReceive: response,
                cacheStoragePolicy: .notAllowed
            )
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
