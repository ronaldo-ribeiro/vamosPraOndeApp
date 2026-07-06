//
//  RootView.swift
//  vamosPraOndeApp
//
//  Raiz da navegação: decide entre o fluxo de autenticação
//  e o app, conforme o estado de login.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var auth: AuthService
    @State private var showSplash = true
    /// Apresentação inicial: mostrada uma única vez, antes do primeiro login.
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        ZStack {
            Group {
                if auth.isSignedIn {
                    MainTabView()
                } else if !hasSeenOnboarding {
                    OnboardingView {
                        withAnimation(.easeInOut) { hasSeenOnboarding = true }
                    }
                } else {
                    AuthFlowView()
                }
            }
            .animation(.easeInOut, value: auth.isSignedIn)

            if showSplash {
                SplashScreen {
                    withAnimation(.easeInOut(duration: 0.5)) { showSplash = false }
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
    }
}
