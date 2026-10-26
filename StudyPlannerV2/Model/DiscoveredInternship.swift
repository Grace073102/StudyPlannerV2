//
//  DiscoveredInternship.swift
//  StudyPlannerV2
//
//  Created by Eden Fernando on 24/10/2026.
//

import Foundation

struct DiscoveredInternship: Decodable, Identifiable {
    let id: String
    let title: String
    let location: String?
    let company: Company?
    let applicationURLText: String?
    let descriptionHTML: String?
    let published: String?
    let salaryText: String?
    let remoteType: String?
    let employmentType: String?

    struct Company: Decodable {
        let name: String?
        let websiteURLText: String?

        enum CodingKeys: String, CodingKey {
            case name
            case websiteURLText = "website_url"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, title, location, company, published
        case applicationURLText = "application_url"
        case descriptionHTML = "description"
        case salaryText = "salary_text"
        case remoteType = "remote_type"
        case employmentType = "employment_type"
    }

    var companyDisplayName: String {
        guard let name = company?.name?
            .trimmingCharacters(in: .whitespacesAndNewlines),
            !name.isEmpty
        else {
            return "Company not provided"
        }

        return name
    }
    
    var companyWebsiteURL: URL? {
        guard let value = company?.websiteURLText else {
            return nil
        }

        let text = value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard let url = URL(string: text),
              let scheme = url.scheme?.lowercased(),
              ["https", "http"].contains(scheme),
              url.host != nil
        else {
            return nil
        }

        return url
    }

    /// Identifies this provider's listings separately from manual entries.
    var savedJobID: String {
        "cleanjobdata:\(id)"
    }

    var applicationURL: URL? {
        guard let text = applicationURLText,
              let url = URL(string: text),
              let scheme = url.scheme?.lowercased(),
              ["https", "http"].contains(scheme),
              url.host != nil
        else {
            return nil
        }

        return url
    }
}

struct InternshipPage: Decodable {
    let data: [DiscoveredInternship]
    let pagination: Pagination

    struct Pagination: Decodable {
        let nextPage: String?

        enum CodingKeys: String, CodingKey {
            case nextPage = "next_page"
        }
    }
}

struct InternshipSearch {
    var title: String = ""
    var remoteOnly: Bool = false
    var cursor: String? = nil
}
