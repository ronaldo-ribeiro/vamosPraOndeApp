//
//  SignUpView.swift
//  vamosPraOndeApp
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var auth: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    private var isValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty
            && password.count >= 6
            && password == confirmPassword
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                AuthHeader(
                    overline: "comece agora",
                    title: "Criar conta",
                    subtitle: "Guarde os destinos dos seus sonhos em um só lugar."
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
                        placeholder: "Crie uma senha",
                        text: $password,
                        icon: "lock",
                        isSecure: true,
                        textContentType: .newPassword
                    )
                    AppTextField(
                        placeholder: "Confirme a senha",
                        text: $confirmPassword,
                        icon: "lock",
                        isSecure: true,
                        textContentType: .newPassword
                    )
                }

                if !confirmPassword.isEmpty && password != confirmPassword {
                    Text("As senhas não coincidem.")
                        .font(AppFont.medium(13))
                        .foregroundStyle(Color.vpoTerracotta)
                }

                if let errorMessage {
                    ErrorBanner(message: errorMessage)
                }

                Button(action: signUp) {
                    if isLoading {
                        ProgressView().tint(.vpoCream)
                    } else {
                        Text("Criar conta")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!isValid || isLoading)
                .opacity(isValid ? 1 : 0.6)

                Text("Ao criar a conta você concorda em embarcar em novas aventuras. ✈️")
                    .font(AppFont.body(13))
                    .foregroundStyle(Color.vpoInkSoft)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, Spacing.xs)
            }
            .padding(Spacing.lg)
        }
        .background(Color.vpoSand.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    private func signUp() {
        errorMessage = nil
        isLoading = true
        Task {
            do {
                try await auth.signUp(email: email.trimmingCharacters(in: .whitespaces), password: password)
            } catch {
                errorMessage = AuthErrorMessage.of(error)
            }
            isLoading = false
        }
    }
}
