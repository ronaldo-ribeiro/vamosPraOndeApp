//
//  ViewController.swift
//  vamosPraOndeApp
//
//  Created by Ronaldo Ribeiro on 10/11/22.
//

import UIKit
import Firebase

protocol ViewControllerProtocol: AnyObject {
    func tappedLoginButton()
}

class ViewController: UIViewController {
    
    private weak var delegate: ViewControllerProtocol?
    
    public func delegate(delegate: ViewControllerProtocol?) {
        self.delegate = delegate
    }
    
    var viewModel: LoginViewModel = LoginViewModel()

    @IBOutlet weak var loginLabel: UILabel!
    
    @IBOutlet weak var instructionsLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextLabel: UITextField!
    
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var dontHaveAnAccountLabel: UILabel!
    
    @IBOutlet weak var registerButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate(delegate: self)
        
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
    
<<<<<<< HEAD
=======
    func hideKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
    }
>>>>>>> feature/home
    

    @IBAction func tappedForgotPasswordButton(_ sender: UIButton) {
        let vc = UIStoryboard(name: "ResetPasswordViewController", bundle: nil).instantiateViewController(withIdentifier: "ResetPasswordViewController") as? ResetPasswordViewController
        
        navigationController?.pushViewController(vc ?? UIViewController(), animated: true)
    }
    
    @IBAction func tappedLoginButton(_ sender: UIButton) {
        viewModel.login(email: emailTextField.text ?? "", password: passwordTextLabel.text ?? "")
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

extension ViewController: LoginViewModelProtocol {
    func sucessLogin() {
        let vc = UIStoryboard(name: "HomeViewController", bundle: nil).instantiateViewController(withIdentifier: "TabBarController") as? TabBarController
        navigationController?.pushViewController(vc ?? UIViewController(), animated: true)
    }
    
    func errorLogin(errorMessage: String) {
        print(#function)
        Alert(controller: self).showAlertInformation(title: "Ops, error login!", message: errorMessage)
    }
    
    
}
