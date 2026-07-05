//
//  SplashScreen.swift
//  vamosPraOndeApp
//
//  Abertura animada (a tela de launch do iOS é estática; esta entra logo
//  em seguida, anima e some, revelando o app).
//

import SwiftUI

struct SplashScreen: View {
    /// Chamado quando a animação termina, para revelar o conteúdo.
    let onFinished: () -> Void

    @State private var sunUp = false
    @State private var titleIn = false
    @State private var planeFly = false

    var body: some View {
        ZStack {
            SunsetCover()
                .scaleEffect(sunUp ? 1 : 1.1)

            VStack(spacing: Spacing.sm) {
                Image(systemName: "airplane")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(Color.vpoOnColor)
                    .rotationEffect(.degrees(-18))
                    .offset(x: planeFly ? 8 : -70, y: planeFly ? -4 : 22)
                    .opacity(planeFly ? 1 : 0)

                Text("Vamos pra onde?")
                    .font(AppFont.display(40))
                    .foregroundStyle(Color.vpoOnColor)
                    .multilineTextAlignment(.center)
                    .opacity(titleIn ? 1 : 0)
                    .offset(y: titleIn ? 0 : 14)

                Text("conte os dias até a próxima aventura")
                    .font(AppFont.medium(14))
                    .foregroundStyle(Color.vpoOnColor.opacity(0.9))
                    .opacity(titleIn ? 1 : 0)
            }
            .padding(.bottom, 40)
        }
        .ignoresSafeArea()
        .task {
            withAnimation(.easeOut(duration: 0.9)) { sunUp = true }
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.15)) { planeFly = true }
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.35)) { titleIn = true }
            try? await Task.sleep(nanoseconds: 1_700_000_000)
            onFinished()
        }
    }
}
