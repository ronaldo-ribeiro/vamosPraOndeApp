//
//  AppFont.swift
//  vamosPraOndeApp
//
//  Design System — tipografia Urbanist.
//  As fontes já estão embarcadas e registradas em Info.plist (UIAppFonts).
//

import SwiftUI

enum AppFont {
    /// Título editorial em itálico pesado — a "voz" da marca (ex.: "Vamos pra onde?").
    static func display(_ size: CGFloat) -> Font {
        .custom("Urbanist-BlackItalic", size: size)
    }

    /// Número gigante do countdown.
    static func countdown(_ size: CGFloat) -> Font {
        .custom("Urbanist-BlackItalic", size: size)
    }

    /// Títulos de seção e nomes.
    static func title(_ size: CGFloat) -> Font {
        .custom("Urbanist-Bold", size: size)
    }

    static func semibold(_ size: CGFloat) -> Font {
        .custom("Urbanist-SemiBold", size: size)
    }

    static func medium(_ size: CGFloat) -> Font {
        .custom("Urbanist-Medium", size: size)
    }

    /// Texto de corpo.
    static func body(_ size: CGFloat) -> Font {
        .custom("Urbanist-Regular", size: size)
    }

    /// Rótulos pequenos em maiúsculas (overlines).
    static func overline(_ size: CGFloat = 12) -> Font {
        .custom("Urbanist-SemiBold", size: size)
    }
}
