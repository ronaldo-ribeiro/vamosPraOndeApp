//
//  TripSync.swift
//  vamosPraOndeApp
//
//  Snapshot leve das viagens, enviado do iPhone para o Apple Watch via
//  WatchConnectivity. Este arquivo pertence a três targets: o app iOS,
//  o VamosWatch e o VamosWatchWidget (Foundation puro, sem Firebase).
//

import Foundation

/// Uma viagem enxuta para o relógio: só o que o pulso precisa.
struct TripSync: Codable, Identifiable, Hashable {
    var id: String
    var cityName: String
    var subtitle: String
    var date: Date?
    var endDate: Date?
    /// Semente da capa procedural (mesma arte no relógio, se quisermos).
    var seed: String
    /// Fuso do destino (o iPhone resolve por geocodificação e manda pronto).
    var timeZoneID: String? = nil
    /// Checklist de mala — marcável no pulso.
    var checklist: [ChecklistItem]? = nil
}

/// Codifica/decodifica o pacote trocado no `applicationContext` e o cache
/// local do relógio (App Group entre o app do Watch e a complicação).
enum TripSyncPayload {
    static let contextKey = "trips"
    /// userInfo do relógio → iPhone: marcar/desmarcar item da checklist.
    /// Dict: destinationID (String), itemID (String), done (Bool).
    static let toggleKey = "checklistToggle"
    static let appGroupID = "group.ronaldoribeiro.vamosPraOndeApp"
    private static let cacheKey = "watchTripsSnapshot"

    static func encode(_ trips: [TripSync]) -> Data? {
        try? JSONEncoder().encode(trips)
    }

    static func decode(_ data: Data) -> [TripSync]? {
        try? JSONDecoder().decode([TripSync].self, from: data)
    }

    // MARK: Cache no relógio (lido pela complicação)

    static func loadCache() -> [TripSync] {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: cacheKey),
              let trips = decode(data) else { return [] }
        return trips
    }

    static func saveCache(_ trips: [TripSync]) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        if let data = encode(trips) {
            defaults.set(data, forKey: cacheKey)
        }
    }

    /// A próxima viagem futura (ou de hoje) de uma lista.
    static func nextTrip(in trips: [TripSync], now: Date = Date()) -> TripSync? {
        let today = Calendar.current.startOfDay(for: now)
        return trips
            .compactMap { trip -> (TripSync, Date)? in
                guard let date = trip.date,
                      Calendar.current.startOfDay(for: date) >= today else { return nil }
                return (trip, date)
            }
            .min { $0.1 < $1.1 }?
            .0
    }
}
