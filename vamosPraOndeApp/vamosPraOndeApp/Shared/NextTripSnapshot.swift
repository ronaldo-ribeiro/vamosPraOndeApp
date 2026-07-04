//
//  NextTripSnapshot.swift
//  vamosPraOndeApp
//
//  Snapshot da próxima viagem, compartilhado com o widget via App Group.
//  Este arquivo pertence aos dois targets (app e VamosWidget).
//

import Foundation
import WidgetKit

struct NextTripSnapshot: Codable {
    let cityName: String
    let subtitle: String
    let date: Date

    static let appGroupID = "group.ronaldoribeiro.vamosPraOndeApp"
    private static let key = "nextTripSnapshot"

    static func load() -> NextTripSnapshot? {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(NextTripSnapshot.self, from: data)
    }

    /// Grava (ou limpa, se nil) o snapshot e pede ao sistema para
    /// atualizar os widgets.
    static func save(_ snapshot: NextTripSnapshot?) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        if let snapshot, let data = try? JSONEncoder().encode(snapshot) {
            defaults.set(data, forKey: key)
        } else {
            defaults.removeObject(forKey: key)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }

    static let sample = NextTripSnapshot(
        cityName: "Lisboa",
        subtitle: "Portugal",
        date: Calendar.current.date(byAdding: .day, value: 45, to: Date()) ?? Date()
    )
}
