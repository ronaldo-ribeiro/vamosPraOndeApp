//
//  AuthFlowView.swift
//  vamosPraOndeApp
//
//  Fluxo de autenticação (boas-vindas → login / cadastro / recuperar senha).
//

import SwiftUI

enum AuthRoute: Hashable {
    case login
    case signUp
    case reset
}

struct AuthFlowView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            WelcomeView(
                onLogin: { path.append(AuthRoute.login) },
                onSignUp: { path.append(AuthRoute.signUp) }
            )
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .login:
                    LoginView(
                        onForgotPassword: { path.append(AuthRoute.reset) },
                        onSignUp: { path.append(AuthRoute.signUp) }
                    )
                case .signUp:
                    SignUpView()
                case .reset:
                    ResetPasswordView()
                }
            }
        }
        .tint(.vpoTerracotta)
    }
}
