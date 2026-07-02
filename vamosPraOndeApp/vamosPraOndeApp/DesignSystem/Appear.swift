//
//  Appear.swift
//  vamosPraOndeApp
//
//  Entrada suave (fade + leve subida) com atraso, para revelações escalonadas.
//

import SwiftUI

private struct AppearModifier: ViewModifier {
    let delay: Double
    @State private var shown = false

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown ? 0 : 18)
            .onAppear {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.82).delay(delay)) {
                    shown = true
                }
            }
    }
}

extension View {
    /// Revela a view com fade + leve subida após `delay` segundos.
    func appear(delay: Double = 0) -> some View {
        modifier(AppearModifier(delay: delay))
    }
}
