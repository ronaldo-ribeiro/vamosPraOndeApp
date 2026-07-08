//
//  Destination.swift
//  vamosPraOndeApp
//
//  Um destino de viagem do usuário (cidade + data), persistido no Firestore.
//

import Foundation
import CoreLocation
import FirebaseFirestore

/// Em que "prateleira" o destino está.
enum TripCategory: String {
    case upcoming   // tem data no futuro (ou hoje)
    case past       // tem data no passado
    case wishlist   // sem data — "quero visitar"
}

struct Destination: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var title: String
    var latitude: Double
    var longitude: Double
    /// Data da viagem. `nil` = lista de desejos ("quero visitar", sem data marcada).
    /// `@ExplicitNull` grava `nil` como `null` (em vez de omitir o campo), para que
    /// editar de "com data" para "quero visitar" realmente limpe a data no Firestore.
    @ExplicitNull var date: Date?
    var createdAt: Date
    /// Anotações da viagem (opcional — destinos antigos podem não ter).
    var notes: String? = nil
    /// Checklist de mala/preparativos (opcional).
    var checklist: [ChecklistItem]? = nil
    /// Estilo de capa escolhido no banco de imagens (paleta + cena).
    /// `nil` = capa padrão derivada da seed do destino. Opcional SIMPLES (não
    /// `@ExplicitNull`) para tolerar docs antigos sem o campo; a limpeza (voltar
    /// ao Padrão) é feita com `FieldValue.delete()` no repositório.
    var coverStyle: CoverStyle? = nil
    /// Trechos de uma viagem multi-destino. `nil`/≤1 = viagem de destino único
    /// (legado): os campos de topo (title/coord/date) são a única parada.
    /// Quando há 2+ trechos, os campos de topo espelham o 1º (para clientes
    /// antigos degradarem bem e o countdown seguir usando o 1º trecho).
    /// Opcional simples pelo mesmo motivo (compat. com docs sem o campo).
    var stops: [TripStop]? = nil

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Sem data marcada → lista de desejos.
    var isWishlist: Bool { date == nil }

    /// Classifica o destino em próxima / passada / quero visitar.
    func category(now: Date = Date(), calendar: Calendar = .current) -> TripCategory {
        guard let date else { return .wishlist }
        let today = calendar.startOfDay(for: now)
        return calendar.startOfDay(for: date) < today ? .past : .upcoming
    }

    /// Nome curto da cidade (primeiro trecho de "Cidade, Estado, País").
    var cityName: String {
        title.split(separator: ",").first.map(String.init)?
            .trimmingCharacters(in: .whitespaces) ?? title
    }

    /// País do destino (último trecho de "Cidade, Estado, País"), usado como
    /// subtítulo enxuto. Vazio quando não há país (ou é igual à cidade).
    var subtitle: String {
        let parts = title.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        guard parts.count > 1, let country = parts.last,
              country.caseInsensitiveCompare(cityName) != .orderedSame else { return "" }
        return country
    }

    // MARK: - Trechos (viagem multi-destino)

    /// `true` quando a viagem tem 2+ trechos.
    var isMultiStop: Bool { (stops?.count ?? 0) > 1 }

    /// Trechos "resolvidos": os salvos (2+) ou um único derivado dos campos de
    /// topo (destino único legado). A UI/mapa sempre trabalham com esta lista.
    var resolvedStops: [TripStop] {
        if let stops, stops.count > 1 { return stops }
        return [TripStop(name: title, latitude: latitude, longitude: longitude, startDate: date)]
    }

    /// Cópia com os trechos definidos, mantendo os campos de topo espelhando o
    /// 1º trecho (countdown/ordenar/clientes antigos seguem funcionando). Com
    /// ≤1 trecho, volta ao modo destino único (`stops = nil`).
    func settingStops(_ newStops: [TripStop]) -> Destination {
        var copy = self
        guard let first = newStops.first else { return copy }
        copy.title = first.name
        copy.latitude = first.latitude
        copy.longitude = first.longitude
        copy.date = first.startDate
        copy.stops = newStops.count > 1 ? newStops : nil
        return copy
    }

    static func == (lhs: Destination, rhs: Destination) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
