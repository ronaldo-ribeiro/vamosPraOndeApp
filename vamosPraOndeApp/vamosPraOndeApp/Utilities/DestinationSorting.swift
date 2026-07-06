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

    /// Rótulo localizado para a UI.
    var label: String {
        switch self {
        case .dateAsc: return String(localized: "Data (mais próxima)")
        case .name: return String(localized: "Nome (A–Z)")
        }
    }
}

enum DestinationFilter: String, CaseIterable, Identifiable {
    case all = "Todas"
    case upcoming = "Próximas"
    case past = "Passadas"
    case wishlist = "Quero visitar"
    var id: String { rawValue }

    /// Rótulo localizado para a UI.
    var label: String {
        switch self {
        case .all: return String(localized: "Todas")
        case .upcoming: return String(localized: "Próximas")
        case .past: return String(localized: "Passadas")
        case .wishlist: return String(localized: "Quero visitar")
        }
    }
}

enum DestinationSorting {
    static func apply(
        _ destinations: [Destination],
        sort: DestinationSort,
        filter: DestinationFilter,
        now: Date = Date()
    ) -> [Destination] {
        let filtered = destinations.filter { destination in
            let category = destination.category(now: now)
            switch filter {
            case .all: return true
            case .upcoming: return category == .upcoming
            case .past: return category == .past
            case .wishlist: return category == .wishlist
            }
        }

        switch sort {
        case .dateAsc:
            // Com data primeiro (mais próxima → mais distante); "quero visitar" por último.
            return filtered.sorted { a, b in
                switch (a.date, b.date) {
                case let (da?, db?): return da < db
                case (_?, nil): return true
                case (nil, _?): return false
                case (nil, nil):
                    return a.cityName.localizedCaseInsensitiveCompare(b.cityName) == .orderedAscending
                }
            }
        case .name:
            return filtered.sorted {
                $0.cityName.localizedCaseInsensitiveCompare($1.cityName) == .orderedAscending
            }
        }
    }
}
