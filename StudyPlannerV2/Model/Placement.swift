//
//  Placement.swift
//  StudyPlannerV2
//
//  Created by emily zhang on 15/10/2026.
//

import Foundation
/// A placement or internship that a student created and manages.
struct Placement: Identifiable, Codable, Equatable, Hashable, Sendable {
    let id: UUID
    var name: String
    var discipline: String
    var startDate: Date
    var endDate: Date
    var description: String?
    
    enum Status: String, Sendable {
        case upcoming, inProgress, completed
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        discipline: String,
        startDate: Date,
        endDate: Date,
        description: String = ""
    ) {
        self.id = id
        self.name = name
        self.discipline = discipline
        self.startDate = startDate
        self.endDate = endDate
        self.description = description
    }
    /// Status relative to a given date
    func status(on date: Date, calendar: Calendar = .current) -> Status {
        let day = calendar.startOfDay(for: date)
        if day < calendar.startOfDay(for: startDate) { return .upcoming }
        if day > calendar.startOfDay(for: endDate) { return .completed }
        return .inProgress
    }
}
