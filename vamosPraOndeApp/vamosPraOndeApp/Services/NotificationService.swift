//
//  NotificationService.swift
//  vamosPraOndeApp
//
//  Lembretes locais da viagem (7 dias e 1 dia antes).
//

import Foundation
import UserNotifications

enum NotificationService {
    /// Lembretes: dias antes da viagem.
    static let reminders = [7, 1]
    private static let reminderHour = 9

    static func requestAuthorization() async {
        _ = try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])
    }

    /// Data de disparo `daysBefore` dias antes da viagem, às `hour`h.
    /// Retorna nil se essa data já passou.
    static func fireDate(
        tripDate: Date,
        daysBefore: Int,
        hour: Int = reminderHour,
        from now: Date = Date(),
        calendar: Calendar = .current
    ) -> Date? {
        guard let shifted = calendar.date(byAdding: .day, value: -daysBefore, to: tripDate) else {
            return nil
        }
        var comps = calendar.dateComponents([.year, .month, .day], from: shifted)
        comps.hour = hour
        comps.minute = 0
        guard let fire = calendar.date(from: comps), fire > now else { return nil }
        return fire
    }

    /// Reagenda os lembretes de um destino (cancela os antigos primeiro).
    static func reschedule(for destination: Destination) async {
        guard let id = destination.id else { return }
        let center = UNUserNotificationCenter.current()
        cancel(for: id)

        // Sem data (lista de desejos) → nada a lembrar.
        guard let tripDate = destination.date else { return }

        for days in reminders {
            guard let fire = fireDate(tripDate: tripDate, daysBefore: days) else { continue }
            let content = UNMutableNotificationContent()
            content.title = String(localized: "Vamos pra onde? ✈️")
            content.body = days == 1
                ? String(localized: "É amanhã: \(destination.cityName)! Bora arrumar as malas. 🧳")
                : String(localized: "Faltam \(days) dias para \(destination.cityName)! 🌅")
            content.sound = .default

            let comps = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute], from: fire
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let request = UNNotificationRequest(
                identifier: identifier(id, days),
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }

    static func cancel(for id: String) {
        let ids = reminders.map { identifier(id, $0) }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    /// Cancela todos os lembretes (usado ao excluir a conta).
    static func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    private static func identifier(_ id: String, _ days: Int) -> String {
        "\(id)-\(days)d"
    }
}
