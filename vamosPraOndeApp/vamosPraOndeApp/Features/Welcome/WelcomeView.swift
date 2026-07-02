//
//  WelcomeView.swift
//  vamosPraOndeApp
//
//  Tela de boas-vindas (Fase 0) — valida o Design System rodando em SwiftUI.
//  Na Fase 1 os botões passam a navegar para login / cadastro.
//

import SwiftUI

struct WelcomeView: View {
    var onLogin: () -> Void = {}
    var onSignUp: () -> Void = {}

    var body: some View {
        ZStack {
            Color.vpoSand.ignoresSafeArea()

            VStack(spacing: 0) {
                cover
                content
            }
        }
    }

    private var cover: some View {
        SunsetCover()
            .frame(height: 320)
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("as suas viagens")
                        .font(AppFont.overline())
                        .kerning(1.5)
                        .textCase(.uppercase)
                        .foregroundStyle(Color(hex: 0xFBE9C6))
                    Text("Vamos\npra onde?")
                        .font(AppFont.display(44))
                        .foregroundStyle(Color.vpoOnColor)
                        .lineSpacing(-4)
                }
                .padding(24)
            }
            .ignoresSafeArea(edges: .top)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Conte os dias até a sua próxima aventura.")
                .font(AppFont.medium(18))
                .foregroundStyle(Color.vpoInk)
                .padding(.top, Spacing.xl)

            Text("Guarde os destinos dos seus sonhos e acompanhe quanto falta para embarcar.")
                .font(AppFont.body(15))
                .foregroundStyle(Color.vpoInkSoft)

            Spacer()

            VStack(spacing: Spacing.sm) {
                Button("Entrar", action: onLogin)
                    .buttonStyle(PrimaryButtonStyle())
                Button("Criar conta", action: onSignUp)
                    .buttonStyle(OutlineButtonStyle())
            }
            .padding(.bottom, Spacing.md)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.lg)
    }
}

#Preview {
    WelcomeView()
}
