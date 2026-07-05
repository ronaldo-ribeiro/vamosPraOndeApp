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
        .nextTripAccessory(nextTrip)
        .task { repo.start() }
        .onChange(of: repo.destinations) { _, destinations in
            syncWidget(with: destinations)
        }
    }

    /// Próxima viagem futura (com data), para o acessório da tab bar.
    private var nextTrip: Destination? {
        let today = Calendar.current.startOfDay(for: Date())
        return repo.destinations
            .filter { d in d.date.map { Calendar.current.startOfDay(for: $0) >= today } ?? false }
            .min { ($0.date ?? .distantFuture) < ($1.date ?? .distantFuture) }
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

    /// No iOS 26, mostra uma pílula de vidro "Próxima viagem" acima da tab bar.
    /// Sem viagem futura (ou em versões anteriores), não mostra nada.
    @ViewBuilder
    func nextTripAccessory(_ trip: Destination?) -> some View {
        if #available(iOS 26.0, *) {
            self.tabViewBottomAccessory {
                if let trip { NextTripPill(destination: trip) }
            }
        } else {
            self
        }
    }
}

/// Pílula do acessório da tab bar com a próxima viagem.
private struct NextTripPill: View {
    let destination: Destination

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "airplane.departure")
                .font(.system(size: 17))
                .foregroundStyle(Color.vpoTerracotta)

            VStack(alignment: .leading, spacing: 1) {
                Text("Próxima viagem")
                    .font(AppFont.overline(10))
                    .kerning(1)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.vpoInkSoft)
                Text(subtitle)
                    .font(AppFont.semibold(15))
                    .foregroundStyle(Color.vpoInk)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var subtitle: String {
        guard let date = destination.date else { return destination.cityName }
        return "\(destination.cityName) · \(Countdown(to: date).phrase)"
    }
}
