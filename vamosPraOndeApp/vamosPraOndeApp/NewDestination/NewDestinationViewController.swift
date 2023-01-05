//
//  NewDestinationViewController.swift
//  vamosPraOndeApp
//
//  Created by Ronaldo Ribeiro on 17/12/22.
//

import MapKit
import UIKit

class NewDestinationViewController: UIViewController {

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
    
    
    @IBAction func tappedSaveButton(_ sender: UIButton) {
    
    }

}

extension NewDestinationViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.blue.cgColor
        textField.layer.borderWidth = 1
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
