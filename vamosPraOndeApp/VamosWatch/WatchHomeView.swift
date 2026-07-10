//
//  WatchHomeView.swift
//  VamosWatch
//
//  Tela única da Fase 1: a próxima viagem em destaque (countdown grande,
//  tema pôr do sol) + as demais futuras na sequência.
//

import SwiftUI

/// Paleta Wanderlust local do relógio (sem depender do Design System iOS).
enum WatchTheme {
    static let sky = Color(red: 0.95, green: 0.61, blue: 0.36)     // laranja pôr do sol
    static let skyDeep = Color(red: 0.72, green: 0.32, blue: 0.22) // terracota profunda
    static let ink = Color(red: 0.16, green: 0.10, blue: 0.08)     // tinta quente
    static let cream = Color(red: 0.99, green: 0.95, blue: 0.89)   // papel/areia
    static let teal = Color(red: 0.22, green: 0.42, blue: 0.43)    // teal-horizonte

    static var sunset: LinearGradient {
        LinearGradient(colors: [sky, skyDeep],
                       startPoint: .top, endPoint: .bottom)
    }
}

struct WatchHomeView: View {
    @EnvironmentObject private var store: WatchTripStore

    var body: some View {
        NavigationStack {
            Group {
                if let next = store.nextTrip {
                    tripsList(next: next)
                } else {
                    emptyState
                }
            }
            .navigationTitle("Vamos pra onde?")
        }
    }

    private func tripsList(next: TripSync) -> some View {
        ScrollView {
            VStack(spacing: 8) {
                NavigationLink(value: next.id) {
                    heroCard(next)
                }
                .buttonStyle(.plain)
                ForEach(store.upcoming) { trip in
                    NavigationLink(value: trip.id) {
                        upcomingRow(trip)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationDestination(for: String.self) { tripID in
            WatchTripDetailView(tripID: tripID)
        }
    }

    /// Destaque da próxima viagem: cidade + dias + data, sobre o pôr do sol.
    private func heroCard(_ trip: TripSync) -> some View {
        let days = trip.date.map { WatchCountdown.days(to: $0) } ?? 0
        return VStack(alignment: .leading, spacing: 2) {
            Text("próxima viagem")
                .font(.system(size: 11, weight: .semibold))
                .textCase(.uppercase)
                .kerning(1)
                .foregroundStyle(WatchTheme.cream.opacity(0.8))
            Text(trip.cityName)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(WatchTheme.cream)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text("\(max(days, 0))")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(WatchTheme.cream)
                Text(days == 1 ? "dia" : "dias")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(WatchTheme.cream.opacity(0.85))
            }
            if let date = trip.date {
                Text(WatchCountdown.shortDate(date))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(WatchTheme.cream.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(WatchTheme.sunset, in: RoundedRectangleShape())
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(WatchTheme.cream.opacity(0.9))
                .frame(width: 18, height: 18)
                .padding(10)
        }
        .accessibilityElement(children: .combine)
    }

    private func upcomingRow(_ trip: TripSync) -> some View {
        let days = trip.date.map { WatchCountdown.days(to: $0) } ?? 0
        return HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(trip.cityName)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                if !trip.subtitle.isEmpty {
                    Text(trip.subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 0) {
                Text("\(days)")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(WatchTheme.sky)
                Text(days == 1 ? "dia" : "dias")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.fill.tertiary, in: RoundedRectangleShape())
        .accessibilityElement(children: .combine)
    }

    private var emptyState: some View {
        VStack(spacing: 6) {
            Image(systemName: "airplane.departure")
                .font(.system(size: 28))
                .foregroundStyle(WatchTheme.sky)
            Text(store.isReady
                 ? "Adicione uma viagem no iPhone e ela aparece aqui."
                 : "Buscando as suas viagens…")
                .font(.system(size: 13))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

/// Cantos contínuos padrão dos cards do relógio.
private struct RoundedRectangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        RoundedRectangle(cornerRadius: 12, style: .continuous).path(in: rect)
    }
}

/// Contagem em dias + data curta (mesma regra do app: sempre dias).
enum WatchCountdown {
    static func days(to date: Date, from now: Date = Date(),
                     calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: now)
        let target = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: start, to: target).day ?? 0
    }

    static func shortDate(_ date: Date) -> String {
        date.formatted(.dateTime.day().month(.abbreviated))
    }
}
