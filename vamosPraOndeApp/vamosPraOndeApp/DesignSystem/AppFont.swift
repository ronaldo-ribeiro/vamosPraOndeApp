//
//  AppFont.swift
//  vamosPraOndeApp
//
//  Design System — tipografia Urbanist, escalando com Dynamic Type.
//  As fontes já estão embarcadas e registradas em Info.plist (UIAppFonts).
//

import SwiftUI

enum AppFont {
    /// Título editorial em itálico pesado — a "voz" da marca (ex.: "Vamos pra onde?").
    static func display(_ size: CGFloat) -> Font {
        .custom("Urbanist-BlackItalic", size: size, relativeTo: .largeTitle)
    }

    /// Número gigante do countdown.
    static func countdown(_ size: CGFloat) -> Font {
        .custom("Urbanist-BlackItalic", size: size, relativeTo: .largeTitle)
    }

    /// Títulos de seção e nomes.
    static func title(_ size: CGFloat) -> Font {
        .custom("Urbanist-Bold", size: size, relativeTo: .headline)
    }

    static func semibold(_ size: CGFloat) -> Font {
        .custom("Urbanist-SemiBold", size: size, relativeTo: .body)
    }

    static func medium(_ size: CGFloat) -> Font {
        .custom("Urbanist-Medium", size: size, relativeTo: .body)
    }

    /// Texto de corpo.
    static func body(_ size: CGFloat) -> Font {
        .custom("Urbanist-Regular", size: size, relativeTo: .body)
    }

    /// Rótulos pequenos em maiúsculas (overlines).
    static func overline(_ size: CGFloat = 12) -> Font {
        .custom("Urbanist-SemiBold", size: size, relativeTo: .caption)
    }
}
