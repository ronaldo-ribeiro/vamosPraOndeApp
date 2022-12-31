//
//  NewDestinationViewController.swift
//  vamosPraOndeApp
//
//  Created by Ronaldo Ribeiro on 17/12/22.
//

import UIKit

class NewDestinationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var newDestinationTiitleLabel: UILabel!
    
    @IBOutlet weak var searchDestinationTextField: UITextField!
    
    @IBOutlet weak var dateAndHourDatePicker: UIDatePicker!
    
    @IBOutlet weak var saveButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchDestinationTextField.layer.cornerRadius = 10.0
        saveButton.layer.cornerRadius = 10.0
        
        searchDestinationTextField.delegate = self
        
        hideKeyboardGesture()
        
    }
    
    func hideKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func tappedSaveButton(_ sender: UIButton) {
    
    }

}
