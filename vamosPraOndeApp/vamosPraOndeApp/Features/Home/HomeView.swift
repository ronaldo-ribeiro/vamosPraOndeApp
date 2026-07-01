//
//  HomeView.swift
//  vamosPraOndeApp
//
//  Placeholder da Home (Fase 1). Na próxima etapa passa a listar
//  os destinos do usuário com countdown.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var auth: AuthService

    var body: some View {
        ZStack {
            Color.vpoSand.ignoresSafeArea()

            VStack(spacing: 0) {
                SunsetCover()
                    .frame(height: 240)
                    .overlay(alignment: .bottomLeading) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("bem-vindo a bordo")
                                .font(AppFont.overline())
                                .kerning(1.5)
                                .textCase(.uppercase)
                                .foregroundStyle(Color(hex: 0xFBE9C6))
                            Text("Vamos pra onde?")
                                .font(AppFont.display(32))
                                .foregroundStyle(Color.vpoCream)
                        }
                        .padding(Spacing.lg)
                    }
                    .ignoresSafeArea(edges: .top)

                VStack(spacing: Spacing.md) {
                    Text("Logado como")
                        .font(AppFont.overline())
                        .textCase(.uppercase)
                        .foregroundStyle(Color.vpoInkSoft)
                    Text(auth.displayEmail)
                        .font(AppFont.title(18))
                        .foregroundStyle(Color.vpoInk)

                    Text("Em breve: os seus destinos e a contagem regressiva de cada viagem.")
                        .font(AppFont.body(15))
                        .foregroundStyle(Color.vpoInkSoft)
                        .multilineTextAlignment(.center)
                        .padding(.top, Spacing.sm)

                    Spacer()

                    Button("Sair", action: logout)
                        .buttonStyle(OutlineButtonStyle())
                        .padding(.bottom, Spacing.md)
                }
                .padding(.top, Spacing.xl)
                .padding(.horizontal, Spacing.lg)
            }
        }
    }

    private func logout() {
        try? auth.signOut()
    }
}
