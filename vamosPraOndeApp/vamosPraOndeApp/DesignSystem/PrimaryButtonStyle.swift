//
//  PrimaryButtonStyle.swift
//  vamosPraOndeApp
//
//  Design System — botão primário (terracota) e variação de contorno.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.title(17))
            .foregroundStyle(Color.vpoCream)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.vpoTerracotta)
            .clipShape(RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct OutlineButtonStyle: ButtonStyle {
    var tint: Color = .vpoTerracotta

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.title(16))
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                    .stroke(tint, lineWidth: 1.5)
            )
            .opacity(configuration.isPressed ? 0.7 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
