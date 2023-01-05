//
//  DetailsViewController.swift
//  vamosPraOndeApp
//
//  Created by Ronaldo Ribeiro on 17/12/22.
//

import UIKit
import MapKit


class DetailsViewController: UIViewController {

    @IBOutlet weak var saoPauloLabel: UILabel!
    
    @IBOutlet weak var remainLabel: UILabel!
    
    @IBOutlet weak var timeToGoLabel: UILabel!
    
    @IBOutlet weak var localityMKMapView: MKMapView!
    
    @IBOutlet weak var weatherView: UIView!
    
    @IBOutlet weak var deleteDestinationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localityMKMapView.layer.cornerRadius = 10.0
        weatherView.layer.cornerRadius = 10.0
        deleteDestinationButton.layer.cornerRadius = 10.0
        configBackButton()

    }
    
    func configBackButton() {
        let yourBackImage = UIImage(systemName: "chevron.left.circle")
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        self.navigationController?.navigationBar.backItem?.title = ""
    }

    @IBAction func tappedDeleteDestinationButton(_ sender: UIButton) {
    }
    
}
