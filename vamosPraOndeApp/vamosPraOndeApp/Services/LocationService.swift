//
//  LocationService.swift
//  vamosPraOndeApp
//
//  Busca de cidades por nome, reaproveitando o LocationManager (CLGeocoder).
//

import Foundation
import CoreLocation

struct CitySuggestion: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

enum LocationService {
    static func search(_ query: String) async -> [CitySuggestion] {
        await withCheckedContinuation { continuation in
            LocationManager.shared.findLocations(with: query) { locations in
                let suggestions = locations.compactMap { location -> CitySuggestion? in
                    guard let coordinate = location.coordinates else { return nil }
                    return CitySuggestion(
                        title: location.title,
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude
                    )
                }
                continuation.resume(returning: suggestions)
            }
        }
    }
}
