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

    var body: some View {
        Group {
            if auth.isSignedIn {
                HomeView()
            } else {
                AuthFlowView()
            }
        }
        .animation(.easeInOut, value: auth.isSignedIn)
    }
}
