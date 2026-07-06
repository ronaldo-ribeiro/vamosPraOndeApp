//
//  OnboardingView.swift
//  vamosPraOndeApp
//
//  Boas-vindas na primeira abertura: 3 telas vendendo o valor do app.
//  Aparece uma única vez (flag em @AppStorage, controlada pelo RootView).
//

import SwiftUI

struct OnboardingView: View {
    /// Chamado ao concluir ou pular.
    let onFinish: () -> Void

    @State private var page = 0
    private let lastPage = 2

    var body: some View {
        ZStack {
            Color.vpoSand.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button("Pular") {
                        Haptics.tap()
                        onFinish()
                    }
                    .font(AppFont.semibold(15))
                    .foregroundStyle(Color.vpoInkSoft)
                    .padding(.trailing, Spacing.lg)
                    .padding(.top, Spacing.sm)
                    .accessibilityLabel("Pular apresentação")
                }

                TabView(selection: $page) {
                    OnboardPage(
                        icon: "calendar.badge.clock",
                        tint: .vpoTerracotta,
                        title: "Conte os dias",
                        text: "Guarde os destinos dos seus sonhos e acompanhe uma contagem regressiva linda até cada embarque."
                    )
                    .tag(0)

                    OnboardPage(
                        icon: "sparkles",
                        tint: .vpoTeal,
                        title: "Tudo sobre a viagem",
                        text: "Clima, fuso horário, checklist de mala e o que fazer perto do destino — num só lugar."
                    )
                    .tag(1)

                    OnboardPage(
                        icon: "map.fill",
                        tint: .vpoGold,
                        title: "Seu mapa do mundo",
                        text: "Veja num mapa-múndi onde você já foi, para onde vai e os lugares que ainda sonha visitar."
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .animation(.easeInOut(duration: 0.3), value: page)

                Button(page == lastPage
                    ? String(localized: "Começar") : String(localized: "Avançar")) {
                    Haptics.tap()
                    if page < lastPage {
                        withAnimation { page += 1 }
                    } else {
                        onFinish()
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.xl)
                .padding(.top, Spacing.md)
            }
        }
    }
}

private struct OnboardPage: View {
    let icon: String
    let tint: Color
    // LocalizedStringKey: os literais das páginas entram no catálogo.
    let title: LocalizedStringKey
    let text: LocalizedStringKey

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            ZStack {
                Circle()
                    .fill(LinearGradient.vpoSunset)
                    .frame(width: 140, height: 140)
                    .shadow(color: tint.opacity(0.35), radius: 18, y: 8)
                Image(systemName: icon)
                    .font(.system(size: 54, weight: .medium))
                    .foregroundStyle(Color.vpoOnColor)
            }

            Text(title)
                .font(AppFont.display(32))
                .foregroundStyle(Color.vpoInk)
                .multilineTextAlignment(.center)

            Text(text)
                .font(AppFont.body(16))
                .foregroundStyle(Color.vpoInkSoft)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)

            Spacer()
            Spacer()
        }
        .accessibilityElement(children: .combine)
    }
}
