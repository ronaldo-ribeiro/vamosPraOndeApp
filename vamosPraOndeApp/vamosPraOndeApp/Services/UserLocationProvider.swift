//
//  UserLocationProvider.swift
//  vamosPraOndeApp
//
//  Localização atual do usuário (apenas para calcular distância até os destinos).
//

import Foundation
import CoreLocation

@MainActor
final class UserLocationProvider: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published private(set) var coordinate: CLLocationCoordinate2D?
    @Published private(set) var authorization: CLAuthorizationStatus

    private let manager = CLLocationManager()

    override init() {
        authorization = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    /// Pede permissão (se necessário) e uma leitura de localização.
    func request() {
        switch authorization {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }

    /// Distância em metros do usuário até uma coordenada (nil se sem localização).
    func distance(to destination: CLLocationCoordinate2D) -> CLLocationDistance? {
        guard let coordinate else { return nil }
        let user = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let target = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        return user.distance(from: target)
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorization = status
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                manager.requestLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coord = locations.last?.coordinate else { return }
        Task { @MainActor in self.coordinate = coord }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Silencioso: a distância simplesmente não aparece.
    }
}

enum DistanceFormat {
    /// "8.320 km" (com separador de milhar pt-BR).
    static func string(meters: CLLocationDistance) -> String {
        let km = (meters / 1000).rounded()
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.maximumFractionDigits = 0
        let number = formatter.string(from: NSNumber(value: km)) ?? "\(Int(km))"
        return "\(number) km"
    }
}
