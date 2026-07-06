//
//  NearbyPlacesService.swift
//  vamosPraOndeApp
//
//  Lugares próximos ao destino (pontos de interesse) via MapKit —
//  MKLocalPointsOfInterestRequest, nativo e sem chave de API.
//

import Foundation
import MapKit

struct NearbyPlace: Identifiable {
    let id = UUID()
    let name: String
    let category: MKPointOfInterestCategory?
    let coordinate: CLLocationCoordinate2D
    let distance: CLLocationDistance?

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
