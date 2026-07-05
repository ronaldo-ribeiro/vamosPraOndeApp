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

    var body: some View {
        ZStack {
            Group {
                if auth.isSignedIn {
                    MainTabView()
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
