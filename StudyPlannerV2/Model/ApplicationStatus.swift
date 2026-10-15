//
//  ApplicationStatus.swift
//  StudyPlannerV2
//
//  Created by emily zhang on 15/10/2026.
//

import Foundation
/// Lets the student track the progress of internship applications 
enum ApplicationStatus: String, Codable, CaseIterable, Sendable {
    case saved, applied, interviewing, offered, rejected
    
    var displayName: String {
        switch self {
        case .saved: "Saved"
        case .applied: "Applied"
        case .interviewing: "Interviewing"
        case .offered: "Offered"
        case .rejected: "Rejected"
        }
    }
}
