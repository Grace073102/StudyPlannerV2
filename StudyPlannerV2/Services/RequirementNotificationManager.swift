//
//  RequirementNotificationManager.swift
//  StudyPlannerV2
//
//  Created by Djy on 15/10/2026.
//

import Foundation
import UserNotifications

final class RequirementNotificationManager {

    static let shared = RequirementNotificationManager()
    private var cancelledRequirementIDs: Set<UUID> = []

    private init() {
        
    }

    // Request notification permission
    func requestPermission() async throws -> Bool {
        try await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])
    }

    // Schedule reminders for a requirement
    func scheduleNotifications(for requirement: PlacementRequirement) async throws {

        guard !cancelledRequirementIDs.contains(requirement.id) else { return }
        defer {
            if cancelledRequirementIDs.contains(requirement.id) {
                removeNotifications(for: requirement.id)
            }
        }

        removeNotifications(for: requirement.id)

        if !requirement.isCompleted, let dueDate = requirement.dueDate {
            try await scheduleReminder(
                id: "\(requirement.id.uuidString)-due",
                title: "Requirement Due Soon",
                body: "\(requirement.name) is approaching its due date.",
                targetDate: dueDate
            )
        }

        if let expiryDate = requirement.expiryDate {
            try await scheduleReminder(
                id: "\(requirement.id.uuidString)-expiry",
                title: "Requirement Expiring Soon",
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
        let today = calendar.startOfDay(for: Date())
        let targetDay = calendar.startOfDay(for: targetDate)

        guard targetDay >= today else { return }

        let reminderDay = calendar.date(
            byAdding: .day,
            value: -7,
            to: targetDay
        )!

        
        let notificationDay = max(reminderDay, today)

        var components = calendar.dateComponents(
            [.year, .month, .day],
            from: notificationDay
        )

        components.hour = 9
        components.minute = 0

        guard var notificationDate = calendar.date(from: components) else {
            return
        }

        if notificationDate <= Date() {
            guard let tomorrow = calendar.date(
                byAdding: .day,
                value: 1,
                to: today
            ) else {
                return
            }

            notificationDate = calendar.date(
                bySettingHour: 9,
                minute: 0,
                second: 0,
                of: tomorrow
            )!
        }

        guard calendar.startOfDay(for: notificationDate) <= targetDay else {
            return
        }

        components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: notificationDate
        )


        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )

        try await UNUserNotificationCenter.current().add(request)
    }


    func cancelNotifications(for id: UUID) {
        cancelledRequirementIDs.insert(id)
        removeNotifications(for: id)
    }

    // Cancel pending reminders
    func removeNotifications(for id: UUID) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [
                    "\(id.uuidString)-due",
                    "\(id.uuidString)-expiry"
                ]
            )
    }
}
