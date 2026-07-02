//
//  CountdownTests.swift
//  vamosPraOndeAppTests
//
//  Testes da contagem regressiva e seus textos em pt-BR.
//

import Testing
import Foundation
@testable import vamosPraOndeApp

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
        #expect(c.value == "Hoje")
        #expect(c.unit == "")
        #expect(c.phrase == "é hoje! 🎉")
    }

    @Test func amanha() {
        let c = Countdown(to: date(2026, 7, 3), from: now)
        #expect(c.days == 1)
        #expect(c.isTomorrow)
        #expect(c.value == "Amanhã")
        #expect(c.phrase == "é amanhã!")
    }

    @Test func poucosDias() {
        let c = Countdown(to: date(2026, 7, 20), from: now) // 18 dias
        #expect(c.days == 18)
        #expect(c.value == "18")
        #expect(c.unit == "dias")
        #expect(c.phrase == "faltam 18 dias")
    }

    @Test func emMeses() {
        let c = Countdown(to: date(2026, 9, 18), from: now) // 2 meses e 16 dias
        #expect(c.value == "2")
        #expect(c.unit == "meses")
        #expect(c.phrase == "faltam 2 meses e 16 dias")
    }

    @Test func umMesSingular() {
        // 49 dias (> 45) => passa a contar em meses; 1 mês e 18 dias.
        let c = Countdown(to: date(2026, 8, 20), from: now)
        #expect(c.value == "1")
        #expect(c.unit == "mês")
        #expect(c.phrase == "faltam 1 mês e 18 dias")
    }

    @Test func passado() {
        let c = Countdown(to: date(2026, 6, 30), from: now)
        #expect(c.isPast)
        #expect(c.value == "—")
        #expect(c.phrase == "viagem já passou")
    }
}
