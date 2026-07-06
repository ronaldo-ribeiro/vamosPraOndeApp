//
//  Haptics.swift
//  vamosPraOndeApp
//
//  Feedback tátil discreto nas interações principais — detalhe que faz
//  o app parecer "de verdade" na mão.
//

import UIKit

enum Haptics {
    /// Toque leve (seleção de chips, botões secundários).
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    /// Confirmação de sucesso (salvar destino, concluir checklist).
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    /// Ação destrutiva ou alerta (excluir).
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
