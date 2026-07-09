//
//  CountdownTests.swift
//  vamosPraOndeAppTests
//
//  Testes da contagem regressiva. Como os textos agora são localizados
//  (pt-BR/en), as expectativas usam o mesmo catálogo — os testes validam a
//  LÓGICA (dias, ramo escolhido, composição), em qualquer idioma.
//

import Testing
import Foundation
@testable import vamosPraOndeApp

/// Atalho: resolve a chave no catálogo, no idioma em que o teste roda.
private func L(_ key: String.LocalizationValue) -> String {
    String(localized: key)
}

struct CountdownTests {
    /// "Agora" fixo para tornar os testes determinísticos: 02/07/2026 12:00.
    private let now = DateComponents(
        calendar: .current, year: 2026, month: 7, day: 2, hour: 12
    ).date!

    private func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        DateComponents(calendar: .current, year: y, month: m, day: d, hour: 12).date!
    }

    @Test func hoje() {
        let c = Countdown(to: date(2026, 7, 2), from: now)
        #expect(c.days == 0)
        #expect(c.isToday)
        #expect(c.value == L("Hoje"))
        #expect(c.unit == "")
        #expect(c.phrase == L("é hoje! 🎉"))
    }

    @Test func amanha() {
        let c = Countdown(to: date(2026, 7, 3), from: now)
        #expect(c.days == 1)
        #expect(c.isTomorrow)
        #expect(c.value == L("Amanhã"))
        #expect(c.phrase == L("é amanhã!"))
    }

    @Test func poucosDias() {
        let c = Countdown(to: date(2026, 7, 20), from: now) // 18 dias
        #expect(c.days == 18)
        #expect(c.value == "18")
        #expect(c.unit == L("dias"))
        #expect(c.phrase == String(localized: "faltam \(18) dias"))
    }

    @Test func longePermaneceEmDias() {
        // A contagem é sempre em dias — nada de "2 meses".
        let c = Countdown(to: date(2026, 9, 18), from: now) // 78 dias
        #expect(c.days == 78)
        #expect(c.value == "78")
        #expect(c.unit == L("dias"))
        #expect(c.phrase == String(localized: "faltam \(78) dias"))
    }

    @Test func muitoLongeTambemEmDias() {
        let c = Countdown(to: date(2027, 5, 2), from: now) // 304 dias
        #expect(c.days == 304)
        #expect(c.value == "304")
        #expect(c.unit == L("dias"))
    }

    @Test func passado() {
        let c = Countdown(to: date(2026, 6, 30), from: now)
        #expect(c.isPast)
        #expect(c.value == "—")
        #expect(c.phrase == L("viagem já passou"))
    }
}
