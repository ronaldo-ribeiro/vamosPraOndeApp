//
//  WatchSyncService.swift
//  vamosPraOndeApp
//
//  Mantém o Apple Watch em dia com as viagens via WatchConnectivity.
//  O iPhone é o dono dos dados (Firebase fica só aqui); o relógio recebe
//  um snapshot leve pelo applicationContext — o último estado sempre vence.
//  No caminho inverso, o relógio manda toggles da checklist por
//  transferUserInfo e nós aplicamos no Firestore.
//

import Foundation
import WatchConnectivity
import FirebaseAuth
import FirebaseFirestore

final class WatchSyncService: NSObject, WCSessionDelegate {
    static let shared = WatchSyncService()

    /// Últimos destinos vistos; reenviados quando a sessão ativa, o relógio
    /// (re)aparece ou um fuso termina de resolver.
    private var lastDestinations: [Destination] = []

    /// Cache destino → fuso (geocodificar é lento e tem rate limit).
    private var timeZoneCache: [String: String] =
        (UserDefaults.standard.dictionary(forKey: "watchTimeZoneCache") as? [String: String]) ?? [:]
    private var resolvingTimeZones = false

    func activate() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    /// Converte os destinos em snapshot e envia (viagens futuras, mais
    /// próxima primeiro).
    func sync(_ destinations: [Destination]) {
        lastDestinations = destinations
        push(makeTrips(from: destinations))
        resolveMissingTimeZones(for: destinations)
    }

    private func makeTrips(from destinations: [Destination]) -> [TripSync] {
        let today = Calendar.current.startOfDay(for: Date())
        return destinations
            .compactMap { d -> (TripSync, Date)? in
                guard let date = d.date,
                      Calendar.current.startOfDay(for: date) >= today else { return nil }
                let trip = TripSync(
                    id: d.id ?? d.title,
                    cityName: d.cityName,
                    subtitle: d.subtitle,
                    date: d.date,
                    endDate: d.endDate,
                    seed: d.coverSeed,
                    timeZoneID: d.id.flatMap { timeZoneCache[$0] },
                    checklist: d.checklist
                )
                return (trip, date)
            }
            .sorted { $0.1 < $1.1 }
            .map(\.0)
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

    /// Resolve (um por vez, com cache) o fuso dos destinos que ainda não
    /// têm, e reenvia o snapshot quando terminar.
    private func resolveMissingTimeZones(for destinations: [Destination]) {
        guard !resolvingTimeZones else { return }
        let pending = destinations.filter { d in
            guard let id = d.id else { return false }
            return d.date != nil && timeZoneCache[id] == nil
        }
        guard !pending.isEmpty else { return }
        resolvingTimeZones = true
        Task { [weak self] in
            guard let self else { return }
            for destination in pending {
                guard let id = destination.id,
                      let zone = await TimeZoneService.timeZone(for: destination.coordinate)
                else { continue }
                self.timeZoneCache[id] = zone.identifier
            }
            UserDefaults.standard.set(self.timeZoneCache, forKey: "watchTimeZoneCache")
            self.resolvingTimeZones = false
            self.push(self.makeTrips(from: self.lastDestinations))
        }
    }

    /// Marca/desmarca um item da checklist direto no Firestore (o relógio
    /// não tem Firebase). Se o app estiver aberto, o listener do repositório
    /// percebe e o snapshot volta atualizado para o relógio.
    private static func applyChecklistToggle(
        destinationID: String, itemID: String, done: Bool
    ) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Firestore.firestore()
            .collection("users").document(uid)
            .collection("destinations").document(destinationID)
        guard let snapshot = try? await ref.getDocument(),
              var destination = try? snapshot.data(as: Destination.self),
              var checklist = destination.checklist,
              let index = checklist.firstIndex(where: { $0.id == itemID })
        else { return }
        checklist[index].isDone = done
        destination.checklist = checklist
        try? ref.setData(from: destination, merge: true)
    }

    // MARK: - WCSessionDelegate

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if activationState == .activated, !lastDestinations.isEmpty {
            push(makeTrips(from: lastDestinations))
        }
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        if !lastDestinations.isEmpty {
            push(makeTrips(from: lastDestinations))
        }
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        handleIncoming(userInfo)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        handleIncoming(message)
    }

    private func handleIncoming(_ payload: [String: Any]) {
        guard let toggle = payload[TripSyncPayload.toggleKey] as? [String: Any],
              let destinationID = toggle["destinationID"] as? String,
              let itemID = toggle["itemID"] as? String,
              let done = toggle["done"] as? Bool else { return }
        Task {
            await Self.applyChecklistToggle(
                destinationID: destinationID, itemID: itemID, done: done
            )
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        // Troca de relógio pareado: reativar para o novo.
        session.activate()
    }
}
