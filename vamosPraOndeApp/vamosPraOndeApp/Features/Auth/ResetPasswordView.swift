//
//  ResetPasswordView.swift
//  vamosPraOndeApp
//

import SwiftUI

struct ResetPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var auth: AuthService
    @State private var email = ""
    @State private var errorMessage: String?
    @State private var didSend = false
    @State private var isLoading = false

    private var isValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                AuthHeader(
                    overline: "sem problemas",
                    title: "Recuperar senha",
                    subtitle: "Enviaremos um link para você redefinir a sua senha."
                )

                if didSend {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(Color.vpoTeal)
                        Text("Link enviado para \(email).")
                            .font(AppFont.title(18))
                            .foregroundStyle(Color.vpoInk)
                        Text("Confira a sua caixa de entrada e o spam.")
                            .font(AppFont.body(15))
                            .foregroundStyle(Color.vpoInkSoft)
                        Button("Voltar") { dismiss() }
                            .buttonStyle(OutlineButtonStyle(tint: .vpoTeal))
                            .padding(.top, Spacing.sm)
                    }
                } else {
                    AppTextField(
                        placeholder: "Seu e-mail",
                        text: $email,
                        icon: "envelope",
                        keyboard: .emailAddress,
                        textContentType: .emailAddress
                    )

                    if let errorMessage {
                        ErrorBanner(message: errorMessage)
                    }

                    Button(action: sendReset) {
                        if isLoading {
                            ProgressView().tint(.vpoOnColor)
                        } else {
                            Text("Enviar link")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(!isValid || isLoading)
                    .opacity(isValid ? 1 : 0.6)
                }
            }
            .padding(Spacing.lg)
        }
        .background(Color.vpoSand.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sendReset() {
        errorMessage = nil
        isLoading = true
        Task {
            do {
                try await auth.sendPasswordReset(email: email.trimmingCharacters(in: .whitespaces))
                didSend = true
            } catch {
                errorMessage = AuthErrorMessage.of(error)
            }
            isLoading = false
        }
    }
}
