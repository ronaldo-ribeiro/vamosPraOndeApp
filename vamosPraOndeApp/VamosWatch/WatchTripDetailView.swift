//
//  WatchTripDetailView.swift
//  VamosWatch
//
//  Detalhes de uma viagem no pulso: countdown sobre a capa procedural,
//  datas, hora local do destino e checklist de mala marcável.
//

import SwiftUI

struct WatchTripDetailView: View {
    @EnvironmentObject private var store: WatchTripStore
    let tripID: String

    private var trip: TripSync? { store.trip(id: tripID) }

    var body: some View {
        Group {
            if let trip {
                content(trip)
            } else {
                Text("Essa viagem não está mais aqui.")
                    .font(WatchFont.medium(13))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func content(_ trip: TripSync) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                header(trip)
                if let zoneID = trip.timeZoneID, let zone = TimeZone(identifier: zoneID) {
                    localTimeRow(trip, zone: zone)
                }
                if let checklist = trip.checklist, !checklist.isEmpty {
                    checklistSection(trip, checklist: checklist)
                }
            }
        }
        .navigationTitle(trip.cityName)
    }

    private func header(_ trip: TripSync) -> some View {
        let days = trip.date.map { WatchCountdown.days(to: $0) } ?? 0
        return VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text("\(max(days, 0))")
                    .font(WatchFont.display(34))
                    .foregroundStyle(WatchTheme.cream)
                Text(days == 1 ? "dia" : "dias")
                    .font(WatchFont.semibold(14))
                    .foregroundStyle(WatchTheme.cream.opacity(0.9))
            }
            if let date = trip.date {
                Text(WatchCountdown.shortDate(date))
                    .font(WatchFont.medium(12))
                    .foregroundStyle(WatchTheme.cream.opacity(0.9))
            }
            if let endDate = trip.endDate {
                Text("volta em \(WatchCountdown.shortDate(endDate))")
                    .font(WatchFont.medium(11))
                    .foregroundStyle(WatchTheme.cream.opacity(0.75))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background {
            ProceduralCover(seed: trip.seed, style: trip.coverStyle, city: trip.cityName)
                .overlay {
                    LinearGradient(
                        colors: [.black.opacity(0.3), .clear],
                        startPoint: .bottom, endPoint: .top
                    )
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    /// Hora local do destino, viva (atualiza a cada minuto).
    private func localTimeRow(_ trip: TripSync, zone: TimeZone) -> some View {
        TimelineView(.everyMinute) { context in
            HStack {
                Image(systemName: "clock.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(WatchTheme.teal)
                VStack(alignment: .leading, spacing: 0) {
                    Text(localTime(context.date, in: zone))
                        .font(WatchFont.bold(17))
                    Text(differencePhrase(zone, at: context.date))
                        .font(WatchFont.medium(11))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .accessibilityLabel(Text("Hora local em \(trip.cityName)"))
    }

    private func checklistSection(_ trip: TripSync, checklist: [ChecklistItem]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("mala")
                    .font(WatchFont.semibold(10))
                    .textCase(.uppercase)
                    .kerning(1)
                    .foregroundStyle(WatchTheme.sky)
                Spacer()
                Text("\(checklist.doneCount)/\(checklist.count)")
                    .font(WatchFont.semibold(11))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 2)
            ForEach(checklist) { item in
                Button {
                    store.toggleChecklistItem(tripID: trip.id, itemID: item.id)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 18))
                            .foregroundStyle(item.isDone ? WatchTheme.teal : .secondary)
                        Text(item.title)
                            .font(WatchFont.medium(14))
                            .strikethrough(item.isDone, color: .secondary)
                            .foregroundStyle(item.isDone ? .secondary : .primary)
                            .lineLimit(2)
                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(item.isDone ? [.isSelected] : [])
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Fuso

    private func localTime(_ date: Date, in zone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = zone
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }

    /// "mesmo horário", "4h à frente", "3h atrás" (mesmas chaves do app).
    private func differencePhrase(_ zone: TimeZone, at date: Date) -> String {
        let hours = Double(zone.secondsFromGMT(for: date) - TimeZone.current.secondsFromGMT(for: date)) / 3600
        if hours == 0 { return String(localized: "mesmo horário que o seu") }
        let absHours = abs(hours)
        let formatted = absHours == absHours.rounded()
            ? "\(Int(absHours))h"
            : String(format: "%.1fh", absHours).replacingOccurrences(of: ".", with: ",")
        return hours > 0
            ? String(localized: "\(formatted) à frente")
            : String(localized: "\(formatted) atrás")
    }
}
