//
//  TimeZoneService.swift
//  vamosPraOndeApp
//
//  Fuso horário de um destino a partir da coordenada (geocodificação reversa).
//

import Foundation
import CoreLocation

enum TimeZoneService {
    static func timeZone(for coordinate: CLLocationCoordinate2D) async -> TimeZone? {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let placemarks = try? await CLGeocoder().reverseGeocodeLocation(location)
        return placemarks?.first?.timeZone
    }

    /// Diferença de horas do destino em relação ao fuso do usuário
    /// (positivo = destino à frente). Pode ser fracionária (ex.: Índia +0,5h... raro).
    static func hoursAhead(_ destination: TimeZone, from local: TimeZone = .current, at date: Date = Date()) -> Double {
        Double(destination.secondsFromGMT(for: date) - local.secondsFromGMT(for: date)) / 3600
    }

    /// Texto amigável da diferença: "mesmo horário que o seu", "4h à frente", "3h atrás".
    static func differencePhrase(_ destination: TimeZone, from local: TimeZone = .current, at date: Date = Date()) -> String {
        let hours = hoursAhead(destination, from: local, at: date)
        if hours == 0 { return "mesmo horário que o seu" }
        let absHours = abs(hours)
        let formatted = absHours == absHours.rounded()
            ? "\(Int(absHours))h"
            : String(format: "%.1fh", absHours).replacingOccurrences(of: ".", with: ",")
        return hours > 0 ? "\(formatted) à frente" : "\(formatted) atrás"
    }
}
