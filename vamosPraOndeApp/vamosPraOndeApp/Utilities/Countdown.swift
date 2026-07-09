//
//  Countdown.swift
//  vamosPraOndeApp
//
//  Contagem regressiva até a data de uma viagem, com textos em pt-BR.
//

import Foundation

struct Countdown {
    /// Dias corridos entre hoje e o destino (negativo = já passou).
    /// A contagem é SEMPRE em dias — "300 dias" conta mais do que "10 meses".
    let days: Int

    init(to date: Date, from now: Date = Date(), calendar: Calendar = .current) {
        let start = calendar.startOfDay(for: now)
        let target = calendar.startOfDay(for: date)
        days = calendar.dateComponents([.day], from: start, to: target).day ?? 0
    }

    var isPast: Bool { days < 0 }
    var isToday: Bool { days == 0 }
    var isTomorrow: Bool { days == 1 }

    /// Número grande para o herói e mini-cards (ex.: "58", "300", "Hoje").
    var value: String {
        if days < 0 { return "—" }
        if days == 0 { return String(localized: "Hoje") }
        if days == 1 { return String(localized: "Amanhã") }
        return "\(days)"
    }

    /// Unidade que acompanha o `value` (vazia para Hoje/Amanhã).
    var unit: String {
        days <= 1 ? "" : String(localized: "dias")
    }

    /// Frase amigável para subtítulos (ex.: "faltam 58 dias", "é hoje!").
    var phrase: String {
        if isPast { return String(localized: "viagem já passou") }
        if isToday { return String(localized: "é hoje! 🎉") }
        if isTomorrow { return String(localized: "é amanhã!") }
        return String(localized: "faltam \(days) dias")
    }
}

enum DateStyle {
    /// "quinta, 18 de setembro de 2026" (no idioma do aparelho).
    static let long: DateFormatter = {
        let f = DateFormatter()
        f.locale = .autoupdatingCurrent
        f.setLocalizedDateFormatFromTemplate("EEEEdMMMMyyyy")
        return f
    }()

    /// "18 set" (no idioma do aparelho).
    static let short: DateFormatter = {
        let f = DateFormatter()
        f.locale = .autoupdatingCurrent
        f.setLocalizedDateFormatFromTemplate("dMMM")
        return f
    }()

    /// "mar de 2026" (no idioma do aparelho) — usado nas lembranças.
    static let monthYear: DateFormatter = {
        let f = DateFormatter()
        f.locale = .autoupdatingCurrent
        f.setLocalizedDateFormatFromTemplate("MMMyyyy")
        return f
    }()
}
