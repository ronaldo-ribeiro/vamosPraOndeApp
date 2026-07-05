//
//  AuthService.swift
//  vamosPraOndeApp
//
//  Camada de autenticação sobre o Firebase Auth.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

@MainActor
final class AuthService: ObservableObject {
    /// Usuário autenticado no momento (nil = deslogado).
    @Published private(set) var user: User?

    private var listenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        user = Auth.auth().currentUser
        listenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in self?.user = user }
        }
    }

    deinit {
        if let listenerHandle {
            Auth.auth().removeStateDidChangeListener(listenerHandle)
        }
    }

    var isSignedIn: Bool { user != nil }

    var displayEmail: String { user?.email ?? "" }

    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signUp(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }

    func sendPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    func signOut() throws {
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
    }

    // MARK: - Entrar com a Apple

    /// Autentica no Firebase com o token da Apple já obtido pela UI.
    func signInWithApple(idTokenString: String, rawNonce: String, fullName: PersonNameComponents?) async throws {
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: rawNonce,
            fullName: fullName
        )
        try await Auth.auth().signIn(with: credential)
    }

    // MARK: - Entrar com o Google

    /// Abre o fluxo do Google a partir de `presenting` e autentica no Firebase.
    func signInWithGoogle(presenting: UIViewController) async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw NSError(domain: "vpo.google", code: -1)
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting)
        guard let idToken = result.user.idToken?.tokenString else {
            throw NSError(domain: "vpo.google", code: -2)
        }
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )
        try await Auth.auth().signIn(with: credential)
    }

    /// Exclui a conta do usuário autenticado no Firebase Auth.
    /// Pode lançar `requiresRecentLogin` se o login for antigo.
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { return }
        try await user.delete()
    }
}

enum AuthErrorMessage {
    /// Traduz os erros mais comuns do Firebase Auth para mensagens em pt-BR.
    static func of(_ error: Error) -> String {
        let code = AuthErrorCode(rawValue: (error as NSError).code)
        switch code {
        case .invalidEmail:
            return "E-mail inválido."
        case .emailAlreadyInUse:
            return "Este e-mail já está cadastrado."
        case .weakPassword:
            return "A senha precisa ter ao menos 6 caracteres."
        case .wrongPassword, .invalidCredential:
            return "E-mail ou senha incorretos."
        case .userNotFound:
            return "Não encontramos uma conta com este e-mail."
        case .userDisabled:
            return "Esta conta foi desativada."
        case .networkError:
            return "Sem conexão. Tente novamente."
        case .tooManyRequests:
            return "Muitas tentativas. Aguarde um momento."
        case .requiresRecentLogin:
            return "Por segurança, saia e entre novamente antes de excluir a conta."
        default:
            return "Algo deu errado. Tente novamente."
        }
    }
}
