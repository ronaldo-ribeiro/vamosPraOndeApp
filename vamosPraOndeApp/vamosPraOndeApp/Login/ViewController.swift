//
//  ViewController.swift
//  vamosPraOndeApp
//
//  Created by Ronaldo Ribeiro on 10/11/22.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var loginLabel: UILabel!
    
    @IBOutlet weak var instructionsLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextLabel: UITextField!
    
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var dontHaveAnAccountLabel: UILabel!
    
    @IBOutlet weak var registerButton: UIButton!
    
    var auth:Auth?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Posterior implementação do login com Firebase
//        Auth.auth().createUser(withEmail: "ronaldo@gmail.com", password: "123456") { authResult, error in
//            if error == nil {
//                print("cadastro com sucesso!")
//            } else {
//                print("falha ao cadastar!")
//            }
//        }
//
//        self.auth = Auth.auth()
        
        loginButton.layer.cornerRadius = 10.0
        emailTextField.layer.cornerRadius = 10.0
        passwordTextLabel.layer.cornerRadius = 10.0
        
        emailTextField.keyboardType = .emailAddress
        passwordTextLabel.keyboardType = .default
        
        emailTextField.delegate = self
        passwordTextLabel.delegate = self
        
        loginButton.isEnabled = false
        loginButton.setTitleColor(.white.withAlphaComponent(0.4), for: .disabled)
        loginButton.setTitleColor(.white, for: .normal)
        
        hideKeyboardGesture()
        
    }
    
    func hideKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
    }

    @IBAction func tappedForgotPasswordButton(_ sender: UIButton) {
        let vc = UIStoryboard(name: "ResetPasswordViewController", bundle: nil).instantiateViewController(withIdentifier: "ResetPasswordViewController") as? ResetPasswordViewController
        
        navigationController?.pushViewController(vc ?? UIViewController(), animated: true)
    }
    
    @IBAction func tappedLoginButton(_ sender: UIButton) {
        
//MARK: Posterior implementação do login com Firebase
//        let email:String = self.emailTextField.text ?? ""
//        let password:String = self.passwordTextLabel.text ?? ""
//
//        self.auth?.createUser(withEmail: email, password: password, completion: { (user, error) in
//            if error != nil {
//                print("dados incorretos, tente novamente!")
//
//            } else {
//                if user == nil {
//                    print("tivemos um problema inesperado!")
//
//            } else {
//                print("login feito com sucesso")
//            }
//        })

        
        let vc = UIStoryboard(name: "HomeViewController", bundle: nil).instantiateViewController(withIdentifier: "TabBarController") as? TabBarController

        navigationController?.pushViewController(vc ?? UIViewController(), animated: true)
    }
    
    @IBAction func tappedRegisterButton(_ sender: UIButton) {
        
        let vc = UIStoryboard(name: "SignUpViewController", bundle: nil).instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController
        
        navigationController?.pushViewController(vc ?? UIViewController(), animated: true)
    }
    
    func validateTextField() {
        if emailTextField.text != "" && passwordTextLabel.text != ""{
            loginButton.isEnabled = true
        } else {
            loginButton.isEnabled = false
        }
    }
    
}

extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.blue.cgColor
        textField.layer.borderWidth = 1
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0
        validateTextField()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
