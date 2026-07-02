//
//  LoginView.swift
//  vamosPraOndeApp
//

import SwiftUI

struct LoginView: View {
    var onForgotPassword: () -> Void = {}
    var onSignUp: () -> Void = {}

    @EnvironmentObject private var auth: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    private var isValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && password.count >= 6
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                AuthHeader(
                    overline: "bem-vindo de volta",
                    title: "Entrar",
                    subtitle: "Que bom te ver de novo. Vamos planejar a próxima?"
                )

                VStack(spacing: Spacing.sm) {
                    AppTextField(
                        placeholder: "Seu e-mail",
                        text: $email,
                        icon: "envelope",
                        keyboard: .emailAddress,
                        textContentType: .emailAddress
                    )
                    AppTextField(
                        placeholder: "Sua senha",
                        text: $password,
                        icon: "lock",
                        isSecure: true,
                        textContentType: .password
                    )
                }

                Button("Esqueceu a senha?", action: onForgotPassword)
                    .font(AppFont.semibold(14))
                    .foregroundStyle(Color.vpoTeal)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                if let errorMessage {
                    ErrorBanner(message: errorMessage)
                }

                Button(action: login) {
                    if isLoading {
                        ProgressView().tint(.vpoOnColor)
                    } else {
                        Text("Entrar")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!isValid || isLoading)
                .opacity(isValid ? 1 : 0.6)

                HStack(spacing: 4) {
                    Text("Não tem uma conta?")
                        .foregroundStyle(Color.vpoInkSoft)
                    Button("Cadastre-se", action: onSignUp)
                        .foregroundStyle(Color.vpoTerracotta)
                }
                .font(AppFont.medium(15))
                .frame(maxWidth: .infinity)
                .padding(.top, Spacing.sm)
            }
            .padding(Spacing.lg)
        }
        .background(Color.vpoSand.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    private func login() {
        errorMessage = nil
        isLoading = true
        Task {
            do {
                try await auth.signIn(email: email.trimmingCharacters(in: .whitespaces), password: password)
            } catch {
                errorMessage = AuthErrorMessage.of(error)
            }
            isLoading = false
        }
    }
}
