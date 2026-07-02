//
//  Destination.swift
//  vamosPraOndeApp
//
//  Um destino de viagem do usuário (cidade + data), persistido no Firestore.
//

import Foundation
import CoreLocation
import FirebaseFirestoreSwift

struct Destination: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var title: String
    var latitude: Double
    var longitude: Double
    var date: Date
    var createdAt: Date
    /// Anotações da viagem (opcional — destinos antigos podem não ter).
    var notes: String? = nil

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
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
