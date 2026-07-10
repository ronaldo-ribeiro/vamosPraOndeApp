//
//  WatchTripStore.swift
//  VamosWatch
//
//  Recebe o snapshot de viagens do iPhone (WatchConnectivity), guarda no
//  App Group (para a complicação ler) e publica para a UI.
//

import Foundation
import WatchConnectivity
import WidgetKit

@MainActor
final class WatchTripStore: NSObject, ObservableObject {
    @Published private(set) var trips: [TripSync] = []

    /// A sessão já tentou ativar? (para diferenciar "carregando" de "vazio")
    @Published private(set) var isReady = false

    var nextTrip: TripSync? { TripSyncPayload.nextTrip(in: trips) }

    /// As demais viagens futuras, sem a que está no destaque.
    var upcoming: [TripSync] {
        guard let next = nextTrip else { return [] }
        return trips.filter { $0.id != next.id }
    }

    override init() {
        super.init()
        // Começa pelo cache local: a UI abre instantânea mesmo sem iPhone.
        trips = TripSyncPayload.loadCache()
        guard WCSession.isSupported() else {
            isReady = true
            return
        }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    /// Viagem "viva" por id (a UI de detalhes acompanha as atualizações).
    func trip(id: String) -> TripSync? {
        trips.first { $0.id == id }
    }

    /// Marca/desmarca um item da checklist: atualiza otimista aqui e manda
    /// o toggle para o iPhone aplicar no Firestore (transferUserInfo é
    /// enfileirado — entrega mesmo se o iPhone estiver longe agora).
    func toggleChecklistItem(tripID: String, itemID: String) {
        guard let tripIndex = trips.firstIndex(where: { $0.id == tripID }),
              var checklist = trips[tripIndex].checklist,
              let itemIndex = checklist.firstIndex(where: { $0.id == itemID })
        else { return }
        checklist[itemIndex].isDone.toggle()
        trips[tripIndex].checklist = checklist
        TripSyncPayload.saveCache(trips)
        guard WCSession.isSupported() else { return }
        let payload: [String: Any] = [
            TripSyncPayload.toggleKey: [
                "destinationID": tripID,
                "itemID": itemID,
                "done": checklist[itemIndex].isDone
            ]
        ]
        // iPhone por perto → sendMessage (imediato). Senão, transferUserInfo
        // (fila que entrega depois). O sendMessage também é o único que
        // funciona entre simuladores.
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(payload, replyHandler: nil) { _ in
                WCSession.default.transferUserInfo(payload)
            }
        } else {
            WCSession.default.transferUserInfo(payload)
        }
    }

    private func apply(_ newTrips: [TripSync]) {
        trips = newTrips
        TripSyncPayload.saveCache(newTrips)
        WidgetCenter.shared.reloadAllTimelines()
    }
}

extension WatchTripStore: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        // O contexto mais recente pode já ter chegado antes do app abrir.
        let context = session.receivedApplicationContext
        Task { @MainActor in
            isReady = true
            if let data = context[TripSyncPayload.contextKey] as? Data,
               let trips = TripSyncPayload.decode(data) {
                apply(trips)
            }
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        guard let data = applicationContext[TripSyncPayload.contextKey] as? Data,
              let trips = TripSyncPayload.decode(data) else { return }
        Task { @MainActor in
            apply(trips)
        }
    }
}
