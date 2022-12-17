//
//  SignUpViewController.swift
//  vamosPraOndeApp
//
//  Created by Ronaldo Ribeiro on 18/11/22.
//

import UIKit

//class CustonTextField: UITextField {
//
//}

class SignUpViewController: UIViewController {

    @IBOutlet weak var registerTitleLabel: UILabel!
    
    @IBOutlet weak var instructionsLabel: UILabel!
    
    @IBOutlet weak var fullNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var charactersInformationLabel: UILabel!
    
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var accountQuestionLabel: UILabel!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fullNameTextField.layer.cornerRadius = 10.0
        emailTextField.layer.cornerRadius = 10.0
        passwordTextField.layer.cornerRadius = 10.0
        confirmPasswordTextField.layer.cornerRadius = 10.0
        registerButton.layer.cornerRadius = 10.0
        
        emailTextField.keyboardType = .emailAddress
        
        fullNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        registerButton.isEnabled = false
        registerButton.setTitleColor(.white.withAlphaComponent(0.4), for: .disabled)
        registerButton.setTitleColor(.white, for: .normal)
        
        hideKeyboardGesture()
    }
    
    
    @IBAction func tappedRegisterButton(_ sender: UIButton) {
    }
    
    @IBAction func tappedLoginButton(_ sender: UIButton) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is ViewController {
                self.navigationController!.popToViewController(aViewController, animated: true)
            }
        }
    }
    
    func validateTextField() {
        if fullNameTextField.text != "" && emailTextField.text != "" && passwordTextField.text != "" && confirmPasswordTextField.text != "" {
            registerButton.isEnabled = true
        } else {
            registerButton.isEnabled = false
        }
    }
     
}

extension SignUpViewController: UITextFieldDelegate {
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
