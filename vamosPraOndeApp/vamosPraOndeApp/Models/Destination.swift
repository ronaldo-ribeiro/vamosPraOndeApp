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

    /// Restante ("Estado, País") após a cidade.
    var subtitle: String {
        let parts = title.split(separator: ",").dropFirst()
            .map { $0.trimmingCharacters(in: .whitespaces) }
        return parts.joined(separator: ", ")
    }

    static func == (lhs: Destination, rhs: Destination) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
