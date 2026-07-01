//
//  AuthService.swift
//  vamosPraOndeApp
//
//  Camada de autenticação sobre o Firebase Auth.
//

import Foundation
import FirebaseAuth

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
        try Auth.auth().signOut()
    }
}

enum AuthErrorMessage {
    /// Traduz os erros mais comuns do Firebase Auth para mensagens em pt-BR.
    static func of(_ error: Error) -> String {
        let code = AuthErrorCode.Code(rawValue: (error as NSError).code)
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
        default:
            return "Algo deu errado. Tente novamente."
        }
    }
}
