//
//  UpcomingItem.swift
//  StudyPlannerV2
//
//  Created by Pichaya Viwatassawin on 18/10/2026.
//


import Foundation

/// One row in Upcoming Deadlines: either an assignment or a placement requirement.
struct UpcomingItem: Identifiable {

    enum Kind {
        case assignment
        case requirement
    }

    let id: String
    let title: String
    let subtitle: String
    let dueDate: Date
    let kind: Kind
    let priority: Assignment.Priority?

    /// Combines unfinished assignments and requirements with a due date, sorted by earliest date first.
    static func make(
        assignments: [Assignment],
        requirements: [PlacementRequirement],
        limit: Int = 5
    ) -> [UpcomingItem] {
        var items: [UpcomingItem] = []

        for assignment in assignments where !assignment.isCompleted {
            items.append(
                UpcomingItem(
                    id: assignment.id,
                    title: assignment.title,
                    subtitle: assignment.course,
                    dueDate: assignment.dueDate,
                    kind: .assignment,
                    priority: assignment.priority
                )
            )
        }

        for requirement in requirements where !requirement.isCompleted {
            guard let dueDate = requirement.dueDate else {
                continue
            }

            items.append(
                UpcomingItem(
                    id: requirement.id.uuidString,
                    title: requirement.name,
                    subtitle: requirement.category.rawValue,
                    dueDate: dueDate,
                    kind: .requirement,
                    priority: nil
                )
            )
        }

        items.sort { $0.dueDate < $1.dueDate }
        return Array(items.prefix(limit))
    }
}
