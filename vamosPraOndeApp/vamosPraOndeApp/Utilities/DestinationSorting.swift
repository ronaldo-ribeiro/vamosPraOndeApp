//
//  DestinationSorting.swift
//  vamosPraOndeApp
//
//  Ordenação e filtragem dos destinos (lógica pura, testável).
//

import Foundation

enum DestinationSort: String, CaseIterable, Identifiable {
    case dateAsc = "Data (mais próxima)"
    case name = "Nome (A–Z)"
    var id: String { rawValue }
}

enum DestinationFilter: String, CaseIterable, Identifiable {
    case all = "Todas"
    case upcoming = "Futuras"
    case past = "Passadas"
    var id: String { rawValue }
}

enum DestinationSorting {
    static func apply(
        _ destinations: [Destination],
        sort: DestinationSort,
        filter: DestinationFilter,
        now: Date = Date()
    ) -> [Destination] {
        let filtered = destinations.filter { destination in
            let isPast = Countdown(to: destination.date, from: now).isPast
            switch filter {
            case .all: return true
            case .upcoming: return !isPast
            case .past: return isPast
            }
        }

        switch sort {
        case .dateAsc:
            return filtered.sorted { $0.date < $1.date }
        case .name:
            return filtered.sorted {
                $0.cityName.localizedCaseInsensitiveCompare($1.cityName) == .orderedAscending
            }
        }
    }
}
