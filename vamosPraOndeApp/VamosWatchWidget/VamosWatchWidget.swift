//
//  VamosWatchWidget.swift
//  VamosWatchWidget
//
//  Complicação do mostrador: "faltam N dias" para a próxima viagem.
//  Lê o snapshot que o app do relógio guarda no App Group; a linha do
//  tempo vira a contagem à meia-noite, sem precisar abrir o app.
//

import WidgetKit
import SwiftUI

struct TripEntry: TimelineEntry {
    let date: Date
    let trip: TripSync?

    var days: Int? {
        guard let tripDate = trip?.date else { return nil }
        let calendar = Calendar.current
        return calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: date),
            to: calendar.startOfDay(for: tripDate)
        ).day
    }
}

struct TripProvider: TimelineProvider {
    func placeholder(in context: Context) -> TripEntry {
        TripEntry(date: Date(), trip: sampleTrip)
    }

    func getSnapshot(in context: Context, completion: @escaping (TripEntry) -> Void) {
        let trip = context.isPreview
            ? sampleTrip
            : TripSyncPayload.nextTrip(in: TripSyncPayload.loadCache())
        completion(TripEntry(date: Date(), trip: trip))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TripEntry>) -> Void) {
        let now = Date()
        let calendar = Calendar.current
        let trip = TripSyncPayload.nextTrip(in: TripSyncPayload.loadCache(), now: now)
        // Uma entrada agora + uma por meia-noite (a contagem desce sozinha).
        var entries = [TripEntry(date: now, trip: trip)]
        for offset in 1...14 {
            if let midnight = calendar.date(
                byAdding: .day, value: offset,
                to: calendar.startOfDay(for: now)
            ) {
                entries.append(TripEntry(date: midnight, trip: trip))
            }
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private var sampleTrip: TripSync {
        TripSync(id: "sample", cityName: "Lisboa", subtitle: "Portugal",
                 date: Calendar.current.date(byAdding: .day, value: 45, to: Date()),
                 endDate: nil, seed: "sample")
    }
}

struct VamosWatchWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: TripEntry

    var body: some View {
        Group {
            switch family {
            case .accessoryCircular: circular
            case .accessoryCorner: corner
            case .accessoryInline: inline
            default: rectangular
            }
        }
        .containerBackground(for: .widget) { Color.clear }
    }

    /// Círculo: número grande + "dias".
    private var circular: some View {
        VStack(spacing: -2) {
            if let days = entry.days {
                Text("\(max(days, 0))")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .minimumScaleFactor(0.6)
                Text(days == 1 ? "dia" : "dias")
                    .font(.system(size: 9, weight: .semibold))
                    .textCase(.uppercase)
            } else {
                Image(systemName: "airplane.departure")
                    .font(.system(size: 20, weight: .semibold))
            }
        }
    }

    /// Canto do mostrador: avião + dias no arco.
    private var corner: some View {
        Image(systemName: "airplane.departure")
            .font(.system(size: 20, weight: .semibold))
            .widgetLabel {
                if let days = entry.days, let trip = entry.trip {
                    if days == 1 {
                        Text("\(trip.cityName) · 1 dia")
                    } else {
                        Text("\(trip.cityName) · \(max(days, 0)) dias")
                    }
                } else {
                    Text("Vamos pra onde?")
                }
            }
    }

    /// Linha única no topo do mostrador.
    private var inline: some View {
        Group {
            if let days = entry.days, let trip = entry.trip {
                if days == 1 {
                    Text("✈️ \(trip.cityName) · 1 dia")
                } else {
                    Text("✈️ \(trip.cityName) · \(max(days, 0)) dias")
                }
            } else {
                Text("✈️ Vamos pra onde?")
            }
        }
    }

    /// Retângulo: cidade + faltam N dias + data.
    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let trip = entry.trip, let days = entry.days, let date = trip.date {
                Text(trip.cityName)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .widgetAccentable()
                Group {
                    if days == 1 {
                        Text("falta 1 dia")
                    } else {
                        Text("faltam \(max(days, 0)) dias")
                    }
                }
                .font(.system(size: 13, weight: .semibold))
                Text(date.formatted(.dateTime.day().month(.abbreviated)))
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            } else {
                Text("Vamos pra onde?")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .widgetAccentable()
                Text("Adicione uma viagem no iPhone")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct VamosWatchWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "VamosWatchWidget", provider: TripProvider()) { entry in
            VamosWatchWidgetView(entry: entry)
        }
        .configurationDisplayName("Próxima viagem")
        .description("Quantos dias faltam para o embarque.")
        .supportedFamilies([
            .accessoryCircular, .accessoryCorner,
            .accessoryInline, .accessoryRectangular
        ])
    }
}

@main
struct VamosWatchWidgetBundle: WidgetBundle {
    var body: some Widget {
        VamosWatchWidget()
    }
}
