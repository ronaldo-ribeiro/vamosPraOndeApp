//
//  NewDestinationViewController.swift
//  vamosPraOndeApp
//
//  Created by Ronaldo Ribeiro on 17/12/22.
//

import MapKit
import UIKit

protocol SearchViewControllerDelegate: AnyObject {
    func searchViewController(_ vc: NewDestinationViewController, didSelectLocationWith coordinates: CLLocationCoordinate2D?)
}

class NewDestinationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: SearchViewControllerDelegate?
    
    @IBOutlet weak var newDestinationTiitleLabel: UILabel!
    
    @IBOutlet weak var searchDestinationTextField: UITextField!
    
    @IBOutlet weak var dateAndHourDatePicker: UIDatePicker!
    
    @IBOutlet weak var saveButton: UIButton!
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
 
    
    var locations = [Location]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        configDatePicker()
        tableView.delegate = self
        tableView.dataSource = self
        searchDestinationTextField.layer.cornerRadius = 10.0
        saveButton.layer.cornerRadius = 10.0
        
        searchDestinationTextField.delegate = self
        
        hideKeyboardGesture()
        
    }
    
    func hideKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
    }
    
    func configDatePicker() {
        // Create a DatePicker and posiiton date picket within a view
        let datePicker = UIDatePicker(frame: CGRect(x: 130, y: 300, width: 50, height: 50))
        
        // Set some of UIDatePicker properties
        datePicker.timeZone = NSTimeZone.local
        datePicker.backgroundColor = UIColor.white
        
        // Add an event to call onDidChangeDate function when value is changed.
        datePicker.addTarget(self, action: #selector(NewDestinationViewController.datePickerValueChanged(_:)), for: .valueChanged)
        
        // Add DataPicker to the view
        self.view.addSubview(datePicker)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker){
            
            // Create date formatter
            let dateFormatter: DateFormatter = DateFormatter()
            
            // Set date format
            dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
            
            // Apply date format
            let selectedDate: String = dateFormatter.string(from: sender.date)
            
            print("Selected value \(selectedDate)")
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }

    
    
    @IBAction func tappedSaveButton(_ sender: UIButton) {
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let tableY: CGFloat = searchDestinationTextField.frame.origin.y+searchDestinationTextField.frame.size.height+5
        tableView.frame = CGRect(x: 0, y: tableY, width: view.frame.size.width, height: view.frame.size.height-tableY)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = locations[indexPath.row].title
        cell.textLabel?.numberOfLines = 0
        cell.backgroundColor = .secondarySystemBackground
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let coordinate = locations[indexPath.row].coordinates
        
        delegate?.searchViewController(self, didSelectLocationWith: coordinate)
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
                    self?.tableView.reloadData()
                }
            }
        }
        return true
    }
    
}
