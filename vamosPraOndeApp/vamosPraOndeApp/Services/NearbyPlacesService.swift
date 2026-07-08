//
//  NearbyPlacesService.swift
//  vamosPraOndeApp
//
//  Lugares próximos ao destino (pontos de interesse) via MapKit —
//  MKLocalPointsOfInterestRequest, nativo e sem chave de API.
//

import Foundation
import MapKit
import FirebaseFunctions

struct NearbyPlace: Identifiable {
    let id = UUID()
    let name: String
    let category: MKPointOfInterestCategory?
    let coordinate: CLLocationCoordinate2D
    let distance: CLLocationDistance?
    /// Nota (0–5) e nº de avaliações — só existem quando vêm do Google Places.
    var rating: Double? = nil
    var ratingCount: Int? = nil

    /// Abre o lugar no app Mapas da Apple.
    func openInMaps() {
        let item = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        item.name = name
        item.openInMaps()
    }
}

/// Categorias oferecidas ao usuário na seção "Por perto".
enum NearbyCategory: String, CaseIterable, Identifiable {
    case attractions = "Atrações"
    case food = "Comida"
    case stay = "Hospedagem"

    var id: String { rawValue }

    /// Rótulo localizado para a UI.
    var label: String {
        switch self {
        case .attractions: return String(localized: "Atrações")
        case .food: return String(localized: "Comida")
        case .stay: return String(localized: "Hospedagem")
        }
    }

    var symbol: String {
        switch self {
        case .attractions: return "camera.fill"
        case .food: return "fork.knife"
        case .stay: return "bed.double.fill"
        }
    }

    /// Chave enviada à Cloud Function (mapeia p/ os tipos do Google Places).
    var functionKey: String {
        switch self {
        case .attractions: return "attractions"
        case .food: return "food"
        case .stay: return "lodging"
        }
    }

    var poiCategories: [MKPointOfInterestCategory] {
        switch self {
        case .attractions:
            return [.museum, .park, .nationalPark, .amusementPark, .aquarium,
                    .zoo, .beach, .stadium, .theater, .movieTheater, .marina]
        case .food:
            return [.restaurant, .cafe, .bakery, .brewery, .winery, .foodMarket, .nightlife]
        case .stay:
            return [.hotel, .campground]
        }
    }
}

enum NearbyPlacesService {
    /// Recomendações da cidade rankeadas por popularidade (Google Places, via
    /// Cloud Function `nearbyPlaces` com cache no Firestore). Se a função
    /// falhar por qualquer motivo (cota/billing/rede), CAI NO MapKit (grátis) —
    /// o recurso nunca quebra e o custo fica limitado por natureza.
    static func ranked(
        near coordinate: CLLocationCoordinate2D,
        category: NearbyCategory
    ) async -> [NearbyPlace] {
        let functions = Functions.functions(region: "southamerica-east1")
        let payload: [String: Any] = [
            "latitude": coordinate.latitude,
            "longitude": coordinate.longitude,
            "category": category.functionKey
        ]
        do {
            let result = try await functions.httpsCallable("nearbyPlaces").call(payload)
            guard let dict = result.data as? [String: Any],
                  let raw = dict["places"] as? [[String: Any]] else {
                return await search(near: coordinate, category: category)
            }
            let origin = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let places: [NearbyPlace] = raw.compactMap { p in
                guard let name = p["name"] as? String, !name.isEmpty else { return nil }
                let lat = p["latitude"] as? Double ?? 0
                let lng = p["longitude"] as? Double ?? 0
                let dist = CLLocation(latitude: lat, longitude: lng).distance(from: origin)
                return NearbyPlace(
                    name: name,
                    category: nil,
                    coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                    distance: dist,
                    rating: p["rating"] as? Double,
                    ratingCount: p["ratingCount"] as? Int
                )
            }
            // Sem resultados úteis → fallback grátis.
            return places.isEmpty ? await search(near: coordinate, category: category) : places
        } catch {
            return await search(near: coordinate, category: category)
        }
    }

    /// Busca até `limit` lugares da categoria num raio ao redor da coordenada.
    static func search(
        near coordinate: CLLocationCoordinate2D,
        category: NearbyCategory,
        radius: CLLocationDistance = 5_000,
        limit: Int = 8
    ) async -> [NearbyPlace] {
        let request = MKLocalPointsOfInterestRequest(center: coordinate, radius: radius)
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: category.poiCategories)

        let origin = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        do {
            let response = try await MKLocalSearch(request: request).start()
            return response.mapItems.prefix(limit).map { item in
                let coord = item.placemark.coordinate
                let distance = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
                    .distance(from: origin)
                return NearbyPlace(
                    name: item.name ?? "Lugar",
                    category: item.pointOfInterestCategory,
                    coordinate: coord,
                    distance: distance
                )
            }
        } catch {
            return []
        }
    }

    /// SF Symbol para a categoria de um POI específico.
    static func symbol(for category: MKPointOfInterestCategory?) -> String {
        switch category {
        case .some(.restaurant), .some(.foodMarket): return "fork.knife"
        case .some(.cafe), .some(.bakery): return "cup.and.saucer.fill"
        case .some(.brewery), .some(.winery), .some(.nightlife): return "wineglass.fill"
        case .some(.museum): return "building.columns.fill"
        case .some(.theater), .some(.movieTheater): return "theatermasks.fill"
        case .some(.park), .some(.nationalPark): return "tree.fill"
        case .some(.beach): return "beach.umbrella.fill"
        case .some(.amusementPark): return "sparkles"
        case .some(.aquarium): return "fish.fill"
        case .some(.zoo): return "pawprint.fill"
        case .some(.stadium): return "sportscourt.fill"
        case .some(.marina): return "sailboat.fill"
        case .some(.hotel), .some(.campground): return "bed.double.fill"
        default: return "mappin"
        }
    }
}
