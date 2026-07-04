//
//  VamosWidget.swift
//  VamosWidget
//
//  Widget de contagem regressiva da próxima viagem (tema Wanderlust).
//

import WidgetKit
import SwiftUI

@main
struct VamosWidgetBundle: WidgetBundle {
    var body: some Widget {
        CountdownWidget()
    }
}

struct CountdownWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "CountdownWidget", provider: TripProvider()) { entry in
            CountdownWidgetView(entry: entry)
        }
        .configurationDisplayName("Próxima viagem")
        .description("Conte os dias até a sua próxima aventura.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Timeline

struct TripEntry: TimelineEntry {
    let date: Date
    let trip: NextTripSnapshot?
}

struct TripProvider: TimelineProvider {
    func placeholder(in context: Context) -> TripEntry {
        TripEntry(date: Date(), trip: .sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (TripEntry) -> Void) {
        let trip = context.isPreview ? (NextTripSnapshot.load() ?? .sample) : NextTripSnapshot.load()
        completion(TripEntry(date: Date(), trip: trip))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TripEntry>) -> Void) {
        let trip = NextTripSnapshot.load()
        let calendar = Calendar.current
        var entries = [TripEntry(date: Date(), trip: trip)]
        // Uma entrada por virada de dia, para o countdown avançar sozinho.
        for day in 1...7 {
            if let midnight = calendar.date(byAdding: .day, value: day, to: calendar.startOfDay(for: Date())) {
                entries.append(TripEntry(date: midnight, trip: trip))
            }
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

// MARK: - View

struct CountdownWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: TripEntry

    private var countdown: Countdown? {
        entry.trip.map { Countdown(to: $0.date, from: entry.date) }
    }

    var body: some View {
        Group {
            if let trip = entry.trip, let countdown {
                switch family {
                case .systemMedium:
                    medium(trip: trip, countdown: countdown)
                default:
                    small(trip: trip, countdown: countdown)
                }
            } else {
                empty
            }
        }
        .containerBackground(for: .widget) { sunset }
    }

    private func small(trip: NextTripSnapshot, countdown: Countdown) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("PRÓXIMA VIAGEM")
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .kerning(1)
                .foregroundStyle(WidgetPalette.peach)
            Text(trip.cityName)
                .font(.system(size: 20, weight: .heavy, design: .rounded).italic())
                .foregroundStyle(WidgetPalette.cream)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 0)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(countdown.value)
                    .font(.system(size: 34, weight: .heavy, design: .rounded).italic())
                    .foregroundStyle(WidgetPalette.cream)
                    .minimumScaleFactor(0.6)
                if !countdown.unit.isEmpty {
                    Text(countdown.unit)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(WidgetPalette.cream)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Próxima viagem: \(trip.cityName), \(countdown.phrase).")
    }

    private func medium(trip: NextTripSnapshot, countdown: Countdown) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text("PRÓXIMA VIAGEM")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .kerning(1.2)
                    .foregroundStyle(WidgetPalette.peach)
                Text(trip.cityName)
                    .font(.system(size: 26, weight: .heavy, design: .rounded).italic())
                    .foregroundStyle(WidgetPalette.cream)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if !trip.subtitle.isEmpty {
                    Text(trip.subtitle)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(WidgetPalette.cream.opacity(0.9))
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                Text(Self.shortDate.string(from: trip.date))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(WidgetPalette.cream.opacity(0.9))
            }
            Spacer()
            VStack(spacing: 0) {
                Text(countdown.value)
                    .font(.system(size: 44, weight: .heavy, design: .rounded).italic())
                    .foregroundStyle(WidgetPalette.cream)
                    .minimumScaleFactor(0.6)
                if !countdown.unit.isEmpty {
                    Text(countdown.unit)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(WidgetPalette.peach)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Próxima viagem: \(trip.cityName), \(countdown.phrase).")
    }

    private var empty: some View {
        VStack(spacing: 6) {
            Image(systemName: "airplane.departure")
                .font(.system(size: 24))
                .foregroundStyle(WidgetPalette.cream)
            Text("Adicione uma viagem no app")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(WidgetPalette.cream)
                .multilineTextAlignment(.center)
        }
    }

    private var sunset: LinearGradient {
        LinearGradient(
            colors: [
                WidgetPalette.color(0xF7CE9E),
                WidgetPalette.color(0xEC9E66),
                WidgetPalette.color(0xC0552F),
                WidgetPalette.color(0x7E3626)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private static let shortDate: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "d 'de' MMMM"
        return f
    }()
}

enum WidgetPalette {
    static func color(_ hex: UInt) -> Color {
        Color(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }

    static let cream = color(0xFBF6EE)
    static let peach = color(0xFBE9C6)
}
