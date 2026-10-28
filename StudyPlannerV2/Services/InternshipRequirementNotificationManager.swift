//
//  InternshipRequirementNotificationManager.swift
//  StudyPlannerV2
//
//  Created by Djy on 28/10/2026.
//

import Foundation
import UserNotifications

final class InternshipRequirementNotificationManager {

    static let shared = InternshipRequirementNotificationManager()

    private var cancelledRequirementIDs: Set<UUID> = []

    private init() {}

    // Request notification permission
    func requestPermission() async throws -> Bool {
        try await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])
    }

    // Schedule reminders for an internship requirement
    func scheduleNotifications(for requirement: InternshipRequirement) async throws {

        guard !cancelledRequirementIDs.contains(requirement.id) else {
            return
        }

        defer {
            if cancelledRequirementIDs.contains(requirement.id) {
                removeNotifications(for: requirement.id)
            }
        }

        removeNotifications(for: requirement.id)

        if !requirement.isCompleted,
           let dueDate = requirement.dueDate {

            try await scheduleReminder(
                id: notificationID(for: requirement.id, kind: "due"),
                title: "Internship Requirement Due Soon",
                body: "\(requirement.name) is approaching its due date.",
                targetDate: dueDate
            )
        }

        if let expiryDate = requirement.expiryDate {
            try await scheduleReminder(
                id: notificationID(for: requirement.id, kind: "expiry"),
                title: "Internship Requirement Expiring Soon",
                body: "\(requirement.name) is approaching its expiry date.",
                targetDate: expiryDate
            )
        }
    }

    // Schedule one notification
    private func scheduleReminder(
        id: String,
        title: String,
        body: String,
        targetDate: Date
    ) async throws {

        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        let targetDay = calendar.startOfDay(for: targetDate)

        guard targetDay >= today else {
            return
        }

        guard let reminderDay = calendar.date(byAdding: .day, value: -7, to: targetDay) else {
            return
        }

        let notificationDay = max(reminderDay, today)

        guard var notificationDate = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: notificationDay) else {
            return
        }

        if notificationDate <= now {
            guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: today), let nextNotificationDate = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: tomorrow) else {
                return
            }

            notificationDate = nextNotificationDate
        }

        guard calendar.startOfDay(for: notificationDate) <= targetDay else {
            return
        }

        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        try await UNUserNotificationCenter.current().add(request)
    }

    // Permanently cancel reminders when a requirement is deleted
    func cancelNotifications(for id: UUID) {
        cancelledRequirementIDs.insert(id)
        removeNotifications(for: id)
    }

    // Remove reminders before updating or rescheduling
    func removeNotifications(for id: UUID) {
        let identifiers = [
            notificationID(for: id, kind: "due"),
            notificationID(for: id, kind: "expiry")
        ]

        let center = UNUserNotificationCenter.current()

        center.removePendingNotificationRequests(withIdentifiers: identifiers)

        center.removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    private func notificationID(for id: UUID, kind: String) -> String {
        "internship-\(id.uuidString)-\(kind)"
    }
}
