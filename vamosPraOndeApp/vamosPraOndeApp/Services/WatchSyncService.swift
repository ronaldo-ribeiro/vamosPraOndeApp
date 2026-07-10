//
//  WatchSyncService.swift
//  vamosPraOndeApp
//
//  Mantém o Apple Watch em dia com as viagens via WatchConnectivity.
//  O iPhone é o dono dos dados (Firebase fica só aqui); o relógio recebe
//  um snapshot leve pelo applicationContext — o último estado sempre vence.
//

import Foundation
import WatchConnectivity

final class WatchSyncService: NSObject, WCSessionDelegate {
    static let shared = WatchSyncService()

    /// Último snapshot calculado; reenviado quando a sessão ativa ou o
    /// relógio (re)aparece.
    private var lastTrips: [TripSync]?

    func activate() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    /// Converte os destinos em snapshot e envia (viagens futuras, mais
    /// próxima primeiro).
    func sync(_ destinations: [Destination]) {
        let today = Calendar.current.startOfDay(for: Date())
        let trips = destinations
            .compactMap { d -> (TripSync, Date)? in
                guard let date = d.date,
                      Calendar.current.startOfDay(for: date) >= today else { return nil }
                let trip = TripSync(
                    id: d.id ?? d.title,
                    cityName: d.cityName,
                    subtitle: d.subtitle,
                    date: d.date,
                    endDate: d.endDate,
                    seed: d.coverSeed
                )
                return (trip, date)
            }
            .sorted { $0.1 < $1.1 }
            .map(\.0)
        lastTrips = trips
        push(trips)
    }

    private func push(_ trips: [TripSync]) {
        guard WCSession.isSupported(),
              WCSession.default.activationState == .activated,
              let data = TripSyncPayload.encode(trips) else { return }
        // applicationContext descarta contextos antigos não entregues —
        // exatamente a semântica de "estado mais recente" que queremos.
        try? WCSession.default.updateApplicationContext(
            [TripSyncPayload.contextKey: data]
        )
    }

    // MARK: - WCSessionDelegate

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if activationState == .activated, let lastTrips {
            push(lastTrips)
        }
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        if let lastTrips { push(lastTrips) }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        // Troca de relógio pareado: reativar para o novo.
        session.activate()
    }
}
