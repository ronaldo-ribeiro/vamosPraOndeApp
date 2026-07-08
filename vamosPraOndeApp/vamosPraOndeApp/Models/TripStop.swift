//
//  TripStop.swift
//  vamosPraOndeApp
//
//  Trechos de uma viagem multi-destino (contador-first). Uma viagem é uma
//  sequência ordenada de trechos (cidades); a "rota" é implícita entre
//  trechos consecutivos. Trechos podem ter data ou não (misturável).
//

import Foundation
import CoreLocation

/// Um passeio do roteiro leve de um trecho (lista simples, marcável).
struct TripActivity: Codable, Identifiable, Hashable {
    var id: String = UUID().uuidString
    var title: String
    var isDone: Bool = false
}

/// Uma parada (trecho) da viagem: cidade + coordenada + datas opcionais +
/// roteiro leve de passeios.
struct TripStop: Codable, Identifiable, Hashable {
    var id: String = UUID().uuidString
    var name: String
    var latitude: Double
    var longitude: Double
    /// Início/chegada. `nil` = trecho sem data ("quero visitar").
    var startDate: Date? = nil
    /// Fim/partida (opcional).
    var endDate: Date? = nil
    /// Roteiro leve (opcional).
    var activities: [TripActivity]? = nil

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Nome curto da cidade (primeiro trecho de "Cidade, Estado, País").
    var cityName: String {
        name.split(separator: ",").first.map(String.init)?
            .trimmingCharacters(in: .whitespaces) ?? name
    }

    /// País (último trecho), vazio quando não há ou é igual à cidade.
    var subtitle: String {
        let parts = name.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        guard parts.count > 1, let country = parts.last,
              country.caseInsensitiveCompare(cityName) != .orderedSame else { return "" }
        return country
    }
}
