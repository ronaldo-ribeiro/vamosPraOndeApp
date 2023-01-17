//
//  SignUpViewModel.swift
//  vamosPraOndeApp
//
//  Created by Ronaldo Ribeiro on 14/01/23.
//

import UIKit
import Firebase

protocol SignUpViewModelProtocol: AnyObject {
    func sucessRegister()
    func errorRegister(errorMessage: String)
}

class SignUpViewModel {

    private weak var delegeate: SignUpViewModelProtocol?
    private var auth = Auth.auth()
    
    public func delegate(delegate: SignUpViewModelProtocol?) {
        self.delegeate = delegate
    }
    
    public func registerUser(email: String, password: String) {
        auth.createUser(withEmail: email, password: password) { authResult, error in
            if error == nil {
                print("sucesso cadastro")
                self.delegeate?.sucessRegister()
            } else {
                print("error cadastro, erro: \(error?.localizedDescription ?? "")")
                self.delegeate?.errorRegister(errorMessage: error?.localizedDescription ?? "")
            }
        }
    }
}
