//
//  LoginViewModel.swift
//  vamosPraOndeApp
//
//  Created by Ronaldo Ribeiro on 14/01/23.
//

import UIKit
import Firebase

protocol LoginViewModelProtocol: AnyObject {
    func sucessLogin()
    func errorLogin(errorMessage: String)
}

class LoginViewModel {

    private weak var delegeate: LoginViewModelProtocol?
    private var auth = Auth.auth()
    
    public func delegate(delegate: LoginViewModelProtocol?) {
        self.delegeate = delegate
    }
    
    public func login(email: String, password: String) {
        auth.signIn(withEmail: email, password: password) { authResult, error in
            if error == nil {
                print("sucesso login")
                self.delegeate?.sucessLogin()
            } else {
                print("error login, erro: \(error?.localizedDescription ?? "")")
                self.delegeate?.errorLogin(errorMessage: error?.localizedDescription ?? "")
            }
        }
    }
}
