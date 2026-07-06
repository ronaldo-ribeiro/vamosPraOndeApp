//
//  SocialSignInButtons.swift
//  vamosPraOndeApp
//
//  Botões "Entrar com a Apple" e "Continuar com o Google", usados nas
//  telas de login e cadastro.
//

import SwiftUI
import AuthenticationServices

struct SocialSignInButtons: View {
    /// Chamado com uma mensagem quando o login social falha.
    var onError: (String) -> Void

    @EnvironmentObject private var auth: AuthService
    @Environment(\.colorScheme) private var colorScheme
    @State private var currentNonce: String?

    private let googleBlue = Color(red: 0.26, green: 0.52, blue: 0.96)

    var body: some View {
        VStack(spacing: Spacing.md) {
            divider

            SignInWithAppleButton(.continue, onRequest: configureApple, onCompletion: handleApple)
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                .frame(height: 52)
                .clipShape(RoundedRectangle(cornerRadius: Radius.control, style: .continuous))

            Button(action: googleSignIn) {
                HStack(spacing: Spacing.sm) {
                    Text("G")
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundStyle(googleBlue)
                    Text("Continuar com o Google")
                        .font(AppFont.semibold(16))
                        .foregroundStyle(Color.vpoInk)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.vpoCream)
                .clipShape(RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                        .stroke(Color.vpoInk.opacity(0.12), lineWidth: 1)
                )
            }
            .accessibilityLabel("Continuar com o Google")
        }
    }

    private var divider: some View {
        HStack(spacing: Spacing.sm) {
            line
            Text("ou")
                .font(AppFont.medium(13))
                .foregroundStyle(Color.vpoInkSoft)
            line
        }
    }

    private var line: some View {
        Rectangle().fill(Color.vpoInk.opacity(0.12)).frame(height: 1)
    }

    // MARK: - Apple

    private func configureApple(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = AppleAuth.randomNonce()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = AppleAuth.sha256(nonce)
    }

    private func handleApple(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard
                let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let nonce = currentNonce,
                let tokenData = credential.identityToken,
                let idToken = String(data: tokenData, encoding: .utf8)
            else {
                onError(String(localized: "Não foi possível validar o login da Apple."))
                return
            }
            Task {
                do {
                    try await auth.signInWithApple(
                        idTokenString: idToken, rawNonce: nonce, fullName: credential.fullName
                    )
                } catch {
                    onError(AuthErrorMessage.of(error))
                }
            }
        case .failure(let error):
            // Cancelamento pelo usuário não é erro.
            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                onError(String(localized: "Login da Apple falhou. Tente novamente."))
            }
        }
    }

    // MARK: - Google

    private func googleSignIn() {
        guard let presenting = UIApplication.shared.topViewController else {
            onError(String(localized: "Não foi possível abrir o login do Google."))
            return
        }
        Task {
            do {
                try await auth.signInWithGoogle(presenting: presenting)
            } catch {
                // -5 = cancelado pelo usuário (GIDSignInError.canceled).
                if (error as NSError).code != -5 {
                    onError(String(localized: "Login do Google falhou. Tente novamente."))
                }
            }
        }
    }
}

extension UIApplication {
    /// View controller no topo, para apresentar o fluxo do Google.
    var topViewController: UIViewController? {
        let scene = connectedScenes
            .first { $0.activationState == .foregroundActive } as? UIWindowScene
        var top = scene?.keyWindow?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}
