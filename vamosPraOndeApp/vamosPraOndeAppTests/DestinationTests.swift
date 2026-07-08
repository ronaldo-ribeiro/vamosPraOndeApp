//
//  DestinationTests.swift
//  vamosPraOndeAppTests
//
//  Testes de parsing de cidade/subtítulo e erros de autenticação.
//

import Testing
import Foundation
@testable import vamosPraOndeApp

struct DestinationTests {
    private func make(_ title: String) -> Destination {
        Destination(id: "x", title: title, latitude: 0, longitude: 0, date: Date(), createdAt: Date())
    }

    @Test func cidadeComPais() {
        let d = make("Lisboa, Lisboa, Portugal")
        #expect(d.cityName == "Lisboa")
        #expect(d.subtitle == "Portugal")
    }

    @Test func cidadeSemPais() {
        let d = make("Tóquio")
        #expect(d.cityName == "Tóquio")
        #expect(d.subtitle == "")
    }

    @Test func aparaEspacos() {
        let d = make("São Paulo,  SP,  Brasil")
        #expect(d.cityName == "São Paulo")
        #expect(d.subtitle == "Brasil")
    }
}

struct TripStopTests {
    private func base() -> Destination {
        Destination(id: "x", title: "Rio de Janeiro, Brasil",
                    latitude: -22.9, longitude: -43.1,
                    date: Date(timeIntervalSince1970: 1_000_000), createdAt: Date())
    }

    @Test func destinoUnicoResolveUmTrecho() {
        let d = base()
        #expect(d.isMultiStop == false)
        let stops = d.resolvedStops
        #expect(stops.count == 1)
        #expect(stops[0].name == "Rio de Janeiro, Brasil")
        #expect(stops[0].latitude == -22.9)
        #expect(stops[0].startDate == d.date)
    }

    @Test func settingStopsMultiEspelhaOTopo() {
        let s1 = TripStop(name: "Barcelona, Espanha", latitude: 41.4, longitude: 2.1,
                          startDate: Date(timeIntervalSince1970: 2_000_000))
        let s2 = TripStop(name: "Paris, França", latitude: 48.8, longitude: 2.3,
                          startDate: Date(timeIntervalSince1970: 3_000_000))
        let updated = base().settingStops([s1, s2])
        #expect(updated.isMultiStop == true)
        #expect(updated.stops?.count == 2)
        // O topo (title/coord/date) espelha o 1º trecho — countdown e clientes
        // antigos seguem funcionando.
        #expect(updated.title == "Barcelona, Espanha")
        #expect(updated.latitude == 41.4)
        #expect(updated.date == s1.startDate)
        #expect(updated.resolvedStops.count == 2)
    }

    @Test func settingStopsUmTrechoVoltaAoDestinoUnico() {
        let s1 = TripStop(name: "Barcelona, Espanha", latitude: 41.4, longitude: 2.1, startDate: nil)
        let updated = base().settingStops([s1])
        #expect(updated.isMultiStop == false)
        #expect(updated.stops == nil)          // demovido: sem array
        #expect(updated.title == "Barcelona, Espanha")
        #expect(updated.date == nil)           // trecho sem data → "quero visitar"
    }
}

struct AuthErrorTests {
    @Test func codigoDesconhecidoUsaMensagemGenerica() {
        let erro = NSError(domain: "FIRAuthErrorDomain", code: 999_999)
        // Independente de idioma: compara com a mesma chave do catálogo.
        #expect(AuthErrorMessage.of(erro) == String(localized: "Algo deu errado. Tente novamente."))
    }
}
