//
//  WeatherProvider.swift
//  vamosPraOndeApp
//
//  Clima atual do destino via WeatherKit.
//  Requer a capability WeatherKit habilitada no target (Signing & Capabilities).
//

import Foundation
import CoreLocation
import WeatherKit

struct DestinationWeather {
    let temperature: String   // ex.: "22°"
    let description: String    // ex.: "Céu limpo"
    let symbolName: String     // SF Symbol do WeatherKit
}

enum WeatherProvider {
    static func current(for coordinate: CLLocationCoordinate2D) async throws -> DestinationWeather {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let current = try await WeatherService.shared.weather(for: location, including: .current)

        let celsius = current.temperature.converted(to: .celsius).value
        return DestinationWeather(
            temperature: "\(Int(celsius.rounded()))°",
            description: description(for: current.condition),
            symbolName: current.symbolName
        )
    }

    /// Descrição em pt-BR para as condições mais comuns.
    private static func description(for condition: WeatherCondition) -> String {
        switch condition {
        case .clear, .mostlyClear, .hot:
            return "Céu limpo"
        case .partlyCloudy:
            return "Parcialmente nublado"
        case .cloudy, .mostlyCloudy:
            return "Nublado"
        case .foggy, .haze, .smoky:
            return "Neblina"
        case .drizzle, .sunShowers:
            return "Garoa"
        case .rain, .freezingRain, .freezingDrizzle:
            return "Chuva"
        case .heavyRain:
            return "Chuva forte"
        case .isolatedThunderstorms, .scatteredThunderstorms, .thunderstorms, .strongStorms:
            return "Tempestade"
        case .snow, .flurries, .heavySnow, .sleet, .wintryMix, .blizzard, .blowingSnow, .sunFlurries:
            return "Neve"
        case .windy, .breezy, .blowingDust:
            return "Ventando"
        case .frigid:
            return "Frio intenso"
        case .hail:
            return "Granizo"
        case .hurricane, .tropicalStorm:
            return "Tempestade tropical"
        default:
            return "Tempo instável"
        }
    }
}
