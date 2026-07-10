//
//  WatchHomeView.swift
//  VamosWatch
//
//  A próxima viagem em destaque (countdown sobre a capa procedural do
//  destino) + as demais futuras na sequência. Tocar abre os detalhes.
//

import SwiftUI

/// Tipografia Urbanist no pulso (mesma identidade editorial do app).
enum WatchFont {
    static func display(_ size: CGFloat) -> Font { .custom("Urbanist-BlackItalic", size: size) }
    static func bold(_ size: CGFloat) -> Font { .custom("Urbanist-Bold", size: size) }
    static func semibold(_ size: CGFloat) -> Font { .custom("Urbanist-SemiBold", size: size) }
    static func medium(_ size: CGFloat) -> Font { .custom("Urbanist-Medium", size: size) }
}

/// Cores fixas do relógio (o watch é sempre escuro; sem Design System iOS).
enum WatchTheme {
    static let sky = Color(hex: 0xE8935A)      // laranja pôr do sol
    static let ink = Color(hex: 0x2A2622)      // tinta quente
    static let cream = Color(hex: 0xFBF6EE)    // papel/areia
    static let teal = Color(hex: 0x4FA093)     // teal-horizonte (tom escuro)
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

    /// Destaque da próxima viagem: countdown sobre a capa procedural
    /// (a mesma arte do iPhone — marcos inclusive).
    private func heroCard(_ trip: TripSync) -> some View {
        let days = trip.date.map { WatchCountdown.days(to: $0) } ?? 0
        return VStack(alignment: .leading, spacing: 2) {
            Text("próxima viagem")
                .font(WatchFont.semibold(10))
                .textCase(.uppercase)
                .kerning(1)
                .foregroundStyle(WatchTheme.cream.opacity(0.85))
            Text(trip.cityName)
                .font(WatchFont.display(20))
                .foregroundStyle(WatchTheme.cream)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 12)
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text("\(max(days, 0))")
                    .font(WatchFont.display(38))
                    .foregroundStyle(WatchTheme.cream)
                Text(days == 1 ? "dia" : "dias")
                    .font(WatchFont.semibold(14))
                    .foregroundStyle(WatchTheme.cream.opacity(0.9))
                Spacer()
                if let date = trip.date {
                    Text(WatchCountdown.shortDate(date))
                        .font(WatchFont.medium(11))
                        .foregroundStyle(WatchTheme.cream.opacity(0.85))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background {
            ProceduralCover(seed: trip.seed, style: trip.coverStyle, city: trip.cityName)
                .overlay {
                    // Scrim para o texto respirar sobre a arte.
                    LinearGradient(
                        colors: [.black.opacity(0.25), .clear, .black.opacity(0.35)],
                        startPoint: .top, endPoint: .bottom
                    )
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private func upcomingRow(_ trip: TripSync) -> some View {
        let days = trip.date.map { WatchCountdown.days(to: $0) } ?? 0
        return HStack(spacing: 8) {
            ProceduralCover(seed: trip.seed, style: trip.coverStyle, city: trip.cityName)
                .frame(width: 34, height: 34)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            VStack(alignment: .leading, spacing: 0) {
                Text(trip.cityName)
                    .font(WatchFont.semibold(15))
                    .lineLimit(1)
                if !trip.subtitle.isEmpty {
                    Text(trip.subtitle)
                        .font(WatchFont.medium(11))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 0) {
                Text("\(days)")
                    .font(WatchFont.bold(17))
                    .foregroundStyle(WatchTheme.sky)
                Text(days == 1 ? "dia" : "dias")
                    .font(WatchFont.medium(10))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var emptyState: some View {
        VStack(spacing: 6) {
            Image(systemName: "airplane.departure")
                .font(.system(size: 28))
                .foregroundStyle(WatchTheme.sky)
            Text(store.isReady
                 ? String(localized: "Adicione uma viagem no iPhone e ela aparece aqui.")
                 : String(localized: "Buscando as suas viagens…"))
                .font(WatchFont.medium(13))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
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
