//
//  FeatureLogicTests.swift
//  vamosPraOndeAppTests
//
//  Testes de ordenação/filtro e do cálculo de data das notificações.
//

import Testing
import Foundation
@testable import vamosPraOndeApp

private let now = DateComponents(calendar: .current, year: 2026, month: 7, day: 2, hour: 12).date!

private func day(_ y: Int, _ m: Int, _ d: Int) -> Date {
    DateComponents(calendar: .current, year: y, month: m, day: d, hour: 12).date!
}

struct DestinationSortingTests {
    private func dest(_ name: String, _ y: Int, _ m: Int, _ d: Int) -> Destination {
        Destination(id: name, title: name, latitude: 0, longitude: 0, date: day(y, m, d), createdAt: now)
    }

    private func wish(_ name: String) -> Destination {
        Destination(id: name, title: name, latitude: 0, longitude: 0, date: nil, createdAt: now)
    }

    private var sample: [Destination] {
        [dest("Tóquio", 2026, 12, 1), dest("Lisboa", 2026, 9, 18), dest("Belém", 2026, 6, 1)]
    }

    @Test func ordenaPorData() {
        let r = DestinationSorting.apply(sample, sort: .dateAsc, filter: .all, now: now)
        #expect(r.map(\.cityName) == ["Belém", "Lisboa", "Tóquio"])
    }

    @Test func ordenaPorNome() {
        let r = DestinationSorting.apply(sample, sort: .name, filter: .all, now: now)
        #expect(r.map(\.cityName) == ["Belém", "Lisboa", "Tóquio"])
    }

    @Test func filtraFuturas() {
        let r = DestinationSorting.apply(sample, sort: .dateAsc, filter: .upcoming, now: now)
        #expect(r.map(\.cityName) == ["Lisboa", "Tóquio"])
    }

    @Test func filtraPassadas() {
        let r = DestinationSorting.apply(sample, sort: .dateAsc, filter: .past, now: now)
        #expect(r.map(\.cityName) == ["Belém"])
    }

    @Test func desejosPorUltimoNaOrdemPorData() {
        let mix = sample + [wish("Bali"), wish("Aruba")]
        let r = DestinationSorting.apply(mix, sort: .dateAsc, filter: .all, now: now)
        // Datados em ordem; desejos por último em ordem alfabética.
        #expect(r.map(\.cityName) == ["Belém", "Lisboa", "Tóquio", "Aruba", "Bali"])
    }

    @Test func filtraSomenteDesejos() {
        let mix = sample + [wish("Bali")]
        let r = DestinationSorting.apply(mix, sort: .dateAsc, filter: .wishlist, now: now)
        #expect(r.map(\.cityName) == ["Bali"])
    }

    @Test func categoriaClassificaCorretamente() {
        #expect(dest("Belém", 2026, 6, 1).category(now: now) == .past)
        #expect(dest("Lisboa", 2026, 9, 18).category(now: now) == .upcoming)
        #expect(wish("Bali").category(now: now) == .wishlist)
    }
}

struct NotificationFireDateTests {
    @Test func seteDiasAntesAs9h() throws {
        let fire = NotificationService.fireDate(tripDate: day(2026, 9, 18), daysBefore: 7, hour: 9, from: now)
        let c = Calendar.current.dateComponents([.month, .day, .hour], from: try #require(fire))
        #expect(c.month == 9)
        #expect(c.day == 11)
        #expect(c.hour == 9)
    }

    @Test func naoAgendaQuandoJaPassou() {
        // Viagem em 3 dias: o lembrete de 7 dias antes já ficou no passado.
        let fire = NotificationService.fireDate(tripDate: day(2026, 7, 5), daysBefore: 7, from: now)
        #expect(fire == nil)
    }
}
