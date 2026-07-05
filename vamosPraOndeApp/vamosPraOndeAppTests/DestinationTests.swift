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

struct AuthErrorTests {
    @Test func codigoDesconhecidoUsaMensagemGenerica() {
        let erro = NSError(domain: "FIRAuthErrorDomain", code: 999_999)
        #expect(AuthErrorMessage.of(erro) == "Algo deu errado. Tente novamente.")
    }
}
