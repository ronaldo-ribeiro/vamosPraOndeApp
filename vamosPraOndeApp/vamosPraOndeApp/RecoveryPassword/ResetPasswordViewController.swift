//
//  ResetPasswordViewController.swift
//  vamosPraOndeApp
//
//  Created by Ronaldo Ribeiro on 04/12/22.
//

import UIKit

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var resetTitleLabel: UILabel!
    
    @IBOutlet weak var instructionsResetLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var resetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.layer.cornerRadius = 10.0
        resetButton.layer.cornerRadius = 10.0
        
        emailTextField.keyboardType = .emailAddress
        
        emailTextField.delegate = self
        
        resetButton.isEnabled = false
        resetButton.setTitleColor(.white.withAlphaComponent(0.4), for: .disabled)
        resetButton.setTitleColor(.white, for: .normal)
        
        hideKeyboardGesture()
    }
    
    @IBAction func tappedResetButton(_ sender: UIButton) {
    }
    
    func validateTextField() {
        if emailTextField.text != "" {
            resetButton.isEnabled = true
        } else {
            resetButton.isEnabled = false
        }
    }

}

extension ResetPasswordViewController: UITextFieldDelegate {
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
