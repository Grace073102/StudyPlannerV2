//
//  UpcomingItemTests.swift
//  StudyPlannerV2
//
//  Created by Pichaya Viwatassawin on 19/10/2026.
//


import Foundation
import Testing
@testable import StudyPlannerV2

/// Tests UpcomingItem.make: leaves out finished items, skips requirements without a due date, sorts earliest first and keeps only the first five.
@MainActor
struct UpcomingItemTests {

    private let today = Calendar.current.date(
        from: DateComponents(year: 2026, month: 10, day: 20)
    )!

    private func days(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: n, to: today)!
    }

    private func makeAssignment(title: String, dueIn n: Int, done: Bool = false) -> Assignment {
        Assignment(
            title: title,
            course: "40005 Advanced iOS",
            dueDate: days(n),
            priority: .medium,
            tasks: [AcademicTask(title: "Task", isCompleted: done)]
        )
    }

    private func makeRequirement(name: String, dueIn n: Int?, done: Bool = false) -> PlacementRequirement {
        var dueDate: Date? = nil
        if let n {
            dueDate = days(n)
        }

        return PlacementRequirement(
            placementID: UUID(),
            name: name,
            category: .checksAndClearances,
            dueDate: dueDate,
            isCompleted: done
        )
    }

    @Test func completedItemsAreLeftOut() {
        let items = UpcomingItem.make(
            assignments: [
                makeAssignment(title: "Finished assignment", dueIn: 1, done: true),
                makeAssignment(title: "Capstone", dueIn: 2)
            ],
            requirements: [
                makeRequirement(name: "Finished check", dueIn: 1, done: true)
            ]
        )

        #expect(items.map(\.title) == ["Capstone"])
    }

    @Test func requirementsWithoutDueDateAreSkipped() {
        let items = UpcomingItem.make(
            assignments: [],
            requirements: [
                makeRequirement(name: "No date yet", dueIn: nil),
                makeRequirement(name: "Police Check", dueIn: 2)
            ]
        )

        #expect(items.map(\.title) == ["Police Check"])
    }

    @Test func itemsAreSortedEarliestFirst() {
        let items = UpcomingItem.make(
            assignments: [
                makeAssignment(title: "Capstone", dueIn: 3),
                makeAssignment(title: "IPPR report", dueIn: -1)
            ],
            requirements: [
                makeRequirement(name: "Police Check", dueIn: 2)
            ]
        )

        #expect(items.map(\.title) == ["IPPR report", "Police Check", "Capstone"])
        #expect(items.map(\.kind) == [.assignment, .requirement, .assignment])
    }

    @Test func onlyFirstFiveAreKept() {
        var assignments: [Assignment] = []
        for n in 1...7 {
            assignments.append(makeAssignment(title: "Assignment \(n)", dueIn: n))
        }

        let items = UpcomingItem.make(assignments: assignments, requirements: [])

        #expect(items.count == 5)
        #expect(items.last?.title == "Assignment 5")
    }
    
    // Boundary Test: exactly five items are all kept.
    @Test func exactlyFiveAreAllKept() {
        var assignments: [Assignment] = []
        for n in 1...5 {
            assignments.append(makeAssignment(title: "Assignment \(n)", dueIn: n))
        }

        let items = UpcomingItem.make(assignments: assignments, requirements: [])

        #expect(items.count == 5)
        #expect(items.last?.title == "Assignment 5")
    }
}
