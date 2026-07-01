//
//  AppColor.swift
//  vamosPraOndeApp
//
//  Design System — paleta "Wanderlust editorial".
//

import SwiftUI

extension Color {
    /// Fundo papel/areia — cor base das telas.
    static let vpoSand = Color(hex: 0xF3E9DB)
    /// Superfícies claras (cards, barras).
    static let vpoCream = Color(hex: 0xFBF6EE)
    /// Texto principal — tinta quente.
    static let vpoInk = Color(hex: 0x2A2622)
    /// Texto secundário — areia escura.
    static let vpoInkSoft = Color(hex: 0x8A7B67)
    /// Acento principal — terracota do pôr do sol.
    static let vpoTerracotta = Color(hex: 0xC0552F)
    /// Acento secundário — teal do horizonte.
    static let vpoTeal = Color(hex: 0x1F5C55)
    /// Dourado — detalhes e realces quentes.
    static let vpoGold = Color(hex: 0xC08A2D)

    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

extension LinearGradient {
    /// Gradiente de pôr do sol usado como capa/fallback dos destinos.
    static let vpoSunset = LinearGradient(
        colors: [
            Color(hex: 0xF7CE9E),
            Color(hex: 0xEC9E66),
            Color(hex: 0xC0552F),
            Color(hex: 0x7E3626)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}
