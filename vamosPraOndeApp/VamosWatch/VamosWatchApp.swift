//
//  VamosWatchApp.swift
//  VamosWatch
//
//  App do Apple Watch: countdown da próxima viagem no pulso.
//  Os dados chegam do iPhone via WatchConnectivity (sem Firebase aqui).
//

import SwiftUI

@main
struct VamosWatchApp: App {
    @StateObject private var store = WatchTripStore()

    var body: some Scene {
        WindowGroup {
            WatchHomeView()
                .environmentObject(store)
        }
    }
}
