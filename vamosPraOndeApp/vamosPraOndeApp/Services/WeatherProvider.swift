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

struct TripDayForecast {
    let high: String           // ex.: "24°"
    let low: String            // ex.: "16°"
    let description: String    // ex.: "Céu limpo"
    let symbolName: String
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

    /// Previsão para o dia da viagem, se estiver dentro da janela de ~10 dias
    /// coberta pelo WeatherKit. Retorna nil fora da janela.
    static func forecast(for coordinate: CLLocationCoordinate2D, on date: Date) async throws -> TripDayForecast? {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let daily = try await WeatherService.shared.weather(for: location, including: .daily)
        guard let day = daily.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) else {
            return nil
        }
        return TripDayForecast(
            high: "\(Int(day.highTemperature.converted(to: .celsius).value.rounded()))°",
            low: "\(Int(day.lowTemperature.converted(to: .celsius).value.rounded()))°",
            description: description(for: day.condition),
            symbolName: day.symbolName
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
