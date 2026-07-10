//
//  WatchTripDetailView.swift
//  VamosWatch
//
//  Detalhes de uma viagem no pulso: countdown, datas, hora local do
//  destino e checklist de mala marcável.
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
                    .font(.system(size: 13))
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
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundStyle(WatchTheme.cream)
                Text(days == 1 ? "dia" : "dias")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(WatchTheme.cream.opacity(0.85))
            }
            if let date = trip.date {
                Text(WatchCountdown.shortDate(date))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(WatchTheme.cream.opacity(0.85))
            }
            if let endDate = trip.endDate {
                Text("volta em \(WatchCountdown.shortDate(endDate))")
                    .font(.system(size: 11))
                    .foregroundStyle(WatchTheme.cream.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(WatchTheme.sunset, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
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
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                    Text(differencePhrase(zone, at: context.date))
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .accessibilityLabel("Hora local em \(trip.cityName)")
    }

    private func checklistSection(_ trip: TripSync, checklist: [ChecklistItem]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("mala")
                    .font(.system(size: 11, weight: .semibold))
                    .textCase(.uppercase)
                    .kerning(1)
                    .foregroundStyle(WatchTheme.sky)
                Spacer()
                Text("\(checklist.doneCount)/\(checklist.count)")
                    .font(.system(size: 11, weight: .semibold))
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
                            .font(.system(size: 14, weight: .medium))
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
        var calendar = Calendar.current
        calendar.timeZone = zone
        let formatter = DateFormatter()
        formatter.timeZone = zone
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }

    /// "mesmo horário", "4h à frente", "3h atrás" (versão compacta do app).
    private func differencePhrase(_ zone: TimeZone, at date: Date) -> String {
        let hours = Double(zone.secondsFromGMT(for: date) - TimeZone.current.secondsFromGMT(for: date)) / 3600
        if hours == 0 { return "mesmo horário que o seu" }
        let absHours = abs(hours)
        let formatted = absHours == absHours.rounded()
            ? "\(Int(absHours))h"
            : String(format: "%.1fh", absHours).replacingOccurrences(of: ".", with: ",")
        return hours > 0 ? "\(formatted) à frente" : "\(formatted) atrás"
    }
}
