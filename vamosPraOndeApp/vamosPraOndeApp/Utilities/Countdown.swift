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
        if days == 0 { return "Hoje" }
        if days == 1 { return "Amanhã" }
        if days < 45 { return "\(days)" }
        return "\(months)"
    }

    /// Unidade que acompanha o `value` (vazia para Hoje/Amanhã).
    var unit: String {
        if days <= 1 { return "" }
        if days < 45 { return "dias" }
        return months == 1 ? "mês" : "meses"
    }

    /// Frase amigável para subtítulos (ex.: "faltam 58 dias", "é hoje!").
    var phrase: String {
        if isPast { return "viagem já passou" }
        if isToday { return "é hoje! 🎉" }
        if isTomorrow { return "é amanhã!" }
        if days < 45 { return "faltam \(days) dias" }
        let mês = "\(months) " + (months == 1 ? "mês" : "meses")
        if remainderDays == 0 { return "faltam \(mês)" }
        let dia = "\(remainderDays) " + (remainderDays == 1 ? "dia" : "dias")
        return "faltam \(mês) e \(dia)"
    }
}

enum DateStyle {
    /// "quinta, 18 de setembro de 2026"
    static let long: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "EEEE, d 'de' MMMM 'de' yyyy"
        return f
    }()

    /// "18 set"
    static let short: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "d MMM"
        return f
    }()
}
