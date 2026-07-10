//
//  MainTabView.swift
//  vamosPraOndeApp
//
//  Estrutura principal do app em abas (Liquid Glass no iOS 26):
//  Viagens (planejamento) · Mapa · Perfil.
//  O repositório de destinos vive aqui e é compartilhado pelas abas.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var repo = DestinationsRepository()

    var body: some View {
        TabView {
            HomeView(repo: repo)
                .tabItem { Label("Viagens", systemImage: "airplane") }

            TravelMapView(destinations: repo.destinations)
                .tabItem { Label("Mapa", systemImage: "map") }

            ProfileView(repo: repo)
                .tabItem { Label("Perfil", systemImage: "person.crop.circle") }
        }
        .tint(.vpoTerracotta)
        .tabBarMinimizeOnScrollIfAvailable()
        .task {
            repo.start()
            WatchSyncService.shared.activate()
        }
        .onChange(of: repo.destinations) { _, destinations in
            syncWidget(with: destinations)
            WatchSyncService.shared.sync(destinations)
        }
    }

    /// Mantém o widget em dia com a próxima viagem futura.
    private func syncWidget(with destinations: [Destination]) {
        let today = Calendar.current.startOfDay(for: Date())
        let next = destinations
            .compactMap { d -> (Destination, Date)? in
                guard let date = d.date, Calendar.current.startOfDay(for: date) >= today else { return nil }
                return (d, date)
            }
            .min { $0.1 < $1.1 }
        NextTripSnapshot.save(next.map { (d, date) in
            NextTripSnapshot(cityName: d.cityName, subtitle: d.subtitle, date: date)
        })
    }
}

extension View {
    /// No iOS 26, encolhe a tab bar (Liquid Glass) ao rolar para baixo,
    /// dando mais espaço ao conteúdo. Em versões anteriores, não faz nada.
    @ViewBuilder
    func tabBarMinimizeOnScrollIfAvailable() -> some View {
        if #available(iOS 26.0, *) {
            self.tabBarMinimizeBehavior(.onScrollDown)
        } else {
            self
        }
    }

}
