//
//  AppColor.swift
//  vamosPraOndeApp
//
//  Design System — paleta "Wanderlust editorial", adaptativa (claro/escuro).
//

import SwiftUI

private func adaptive(light: UInt, dark: UInt) -> Color {
    Color(UIColor { traits in
        UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
    })
}

extension Color {
    /// Fundo papel/areia — cor base das telas.
    static let vpoSand = adaptive(light: 0xF3E9DB, dark: 0x161210)
    /// Superfícies (cards, campos, barras).
    static let vpoCream = adaptive(light: 0xFBF6EE, dark: 0x241E18)
    /// Texto principal.
    static let vpoInk = adaptive(light: 0x2A2622, dark: 0xF3E9DB)
    /// Texto secundário.
    static let vpoInkSoft = adaptive(light: 0x8A7B67, dark: 0xA99A82)
    /// Acento principal — terracota do pôr do sol.
    static let vpoTerracotta = adaptive(light: 0xC0552F, dark: 0xDA6A40)
    /// Acento secundário — teal do horizonte.
    static let vpoTeal = adaptive(light: 0x1F5C55, dark: 0x4FA093)
    /// Dourado — detalhes e realces quentes.
    static let vpoGold = adaptive(light: 0xC08A2D, dark: 0xD4A24A)

    /// Sempre claro: texto/ícone sobre superfícies coloridas
    /// (terracota, teal, capa pôr do sol) — não muda no dark mode.
    static let vpoOnColor = Color(hex: 0xFBF6EE)

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

extension UIColor {
    convenience init(hex: UInt, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}

extension LinearGradient {
    /// Gradiente de pôr do sol usado como capa/fallback dos destinos (sempre quente).
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
