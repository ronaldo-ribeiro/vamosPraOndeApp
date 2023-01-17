//
//  NewDestinationViewController.swift
//  vamosPraOndeApp
//
//  Created by Ronaldo Ribeiro on 17/12/22.
//

import MapKit
import CoreLocation
import UIKit
import FirebaseFirestore

//protocol NewDestinationViewControllerDelegate: AnyObject {
//    func didSaveCity(city: String)
//}

protocol SearchViewControllerDelegate: AnyObject {
    func searchViewController(_ vc: NewDestinationViewController, didSelectLocationWith coordinates: CLLocationCoordinate2D?)
}

class NewDestinationViewController: UIViewController {
    
//    weak var delegate: NewDestinationViewControllerDelegate?
    
    weak var delegate: SearchViewControllerDelegate?
    
    @IBOutlet weak var newDestinationTiitleLabel: UILabel!
    
    @IBOutlet weak var searchDestinationTextField: UITextField!
    
    @IBOutlet weak var dateAndHourDatePicker: UIDatePicker!
    
    @IBOutlet weak var saveButton: UIButton!
    
    
    var locations = [Location]()
    
    var docRef: DocumentReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchDestinationTextField.layer.cornerRadius = 10.0
        saveButton.layer.cornerRadius = 10.0
        
        searchDestinationTextField.delegate = self
        
        hideKeyboardGesture()
        
        docRef = Firestore.firestore().document("places/city")
    }
    
    func hideKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
    }

    @IBAction func tappedSaveButton(_ sender: UIButton) {
        guard let localization = searchDestinationTextField.text, !localization.isEmpty else { return }
        let dataToSave: [String: Any] = ["city": localization]
        docRef.setData(dataToSave) { (error) in
            if let error = error {
                print("Nós temos um error: \(error.localizedDescription)")
            } else {
                print("A informação não foi salva")
            }
        }
        
        
//        delegate?.(city: searchDestinationTextField.text ?? "")
        
//        MARK: Depois de pressionar para salvar a cidade, retornar a tela de destino(s)
//        let vc = UIStoryboard(name: "HomeViewController", bundle: nil).instantiateViewController(withIdentifier: "TabBarController") as? TabBarController
//        navigationController?.pushViewController(vc ?? UIViewController(), animated: true)
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
        searchDestinationTextField.resignFirstResponder()
        if let text = searchDestinationTextField.text, !text.isEmpty {
            LocationManager.shared.findLocations(with: text) { [weak self] locations in
                DispatchQueue.main.async {
                    self?.locations = locations
                }
            }
        }
        return true
    }
}
