//
//  AppleAuth.swift
//  vamosPraOndeApp
//
//  Utilitários para o "Entrar com a Apple": nonce aleatório + SHA256,
//  exigidos pelo Firebase para validar o token da Apple com segurança.
//

import Foundation
import CryptoKit

enum AppleAuth {
    /// Nonce aleatório (usado cru no Firebase e com hash no request da Apple).
    static func randomNonce(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remaining = length

        while remaining > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let status = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if status != errSecSuccess {
                    fatalError("Não foi possível gerar o nonce. Código \(status)")
                }
                return random
            }
            for random in randoms where remaining > 0 {
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remaining -= 1
                }
            }
        }
        return result
    }

    /// SHA256 em hexadecimal do nonce (o que vai no request da Apple).
    static func sha256(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }
}
