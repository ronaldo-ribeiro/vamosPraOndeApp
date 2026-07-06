//
//  Countdown.swift
//  vamosPraOndeApp
//
//  Contagem regressiva até a data de uma viagem, com textos em pt-BR.
//

import Foundation

struct Countdown {
    /// Dias corridos entre hoje e o destino (negativo = já passou).
    let days: Int
    private let months: Int
    private let remainderDays: Int

    init(to date: Date, from now: Date = Date(), calendar: Calendar = .current) {
        let start = calendar.startOfDay(for: now)
        let target = calendar.startOfDay(for: date)
        days = calendar.dateComponents([.day], from: start, to: target).day ?? 0
        let comps = calendar.dateComponents([.month, .day], from: start, to: target)
        months = max(0, comps.month ?? 0)
        remainderDays = max(0, comps.day ?? 0)
    }

    var isPast: Bool { days < 0 }
    var isToday: Bool { days == 0 }
    var isTomorrow: Bool { days == 1 }

    /// Número grande para o herói e mini-cards (ex.: "58", "2", "Hoje").
    var value: String {
        if days < 0 { return "—" }
        if days == 0 { return String(localized: "Hoje") }
        if days == 1 { return String(localized: "Amanhã") }
        if days < 45 { return "\(days)" }
        return "\(months)"
    }

    /// Unidade que acompanha o `value` (vazia para Hoje/Amanhã).
    var unit: String {
        if days <= 1 { return "" }
        if days < 45 { return String(localized: "dias") }
        return months == 1 ? String(localized: "mês") : String(localized: "meses")
    }

    /// Frase amigável para subtítulos (ex.: "faltam 58 dias", "é hoje!").
    var phrase: String {
        if isPast { return String(localized: "viagem já passou") }
        if isToday { return String(localized: "é hoje! 🎉") }
        if isTomorrow { return String(localized: "é amanhã!") }
        if days < 45 { return String(localized: "faltam \(days) dias") }
        let mês = "\(months) " + (months == 1 ? String(localized: "mês") : String(localized: "meses"))
        if remainderDays == 0 { return String(localized: "faltam \(mês)") }
        let dia = "\(remainderDays) " + (remainderDays == 1 ? String(localized: "dia") : String(localized: "dias"))
        return String(localized: "faltam \(mês) e \(dia)")
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
}
