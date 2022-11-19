//
//  ViewController.swift
//  vamosPraOndeApp
//
//  Created by Ronaldo Ribeiro on 10/11/22.
//

import UIKit

class ViewController: UIViewController {

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
        loginButton.layer.cornerRadius = 10.0
        emailTextField.layer.cornerRadius = 10.0
        passwordTextLabel.layer.cornerRadius = 10.0
    }

    @IBAction func tappedForgotPasswordButton(_ sender: UIButton) {
    }
    
    @IBAction func tappedLoginButton(_ sender: UIButton) {
    }
    
    @IBAction func tappedRegisterButton(_ sender: UIButton) {
        let vc = UIStoryboard(name: "SignUpViewController", bundle: nil).instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController
        
        // o pushViewController ele exibe a tela da controladora
        navigationController?.pushViewController(vc ?? UIViewController(), animated: true)
    }
    
    
    

}

