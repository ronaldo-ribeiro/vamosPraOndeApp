//
//  HomeViewController.swift
//  vamosPraOndeApp
//
//  Created by Ronaldo Ribeiro on 17/12/22.
//

import UIKit

class HomeViewController: UIViewController {

    
    @IBOutlet weak var addDestinationButton: UIButton!
    
    @IBOutlet weak var saoPauloButton: UIButton!
    
    @IBOutlet weak var saoPauloLabel: UILabel!
    
    @IBOutlet weak var recifeButton: UIButton!
    
    @IBOutlet weak var recifeLabel: UILabel!
    
    @IBOutlet weak var parisButton: UIButton!
    
    @IBOutlet weak var parisLabel: UILabel!
    
    @IBOutlet weak var romaButton: UIButton!
    
    @IBOutlet weak var romaLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func tappedAddDestinationButton(_ sender: UIButton) {
        let vc = UIStoryboard(name: "NewDestinationViewController", bundle: nil).instantiateViewController(withIdentifier: "NewDestinationViewController") as? NewDestinationViewController
        
        navigationController?.pushViewController(vc ?? UIViewController(), animated: true)
        
    }
    
    @IBAction func tappedSaoPauloButton(_ sender: UIButton) {
        let vc = UIStoryboard(name: "DetailsViewController", bundle: nil).instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController
        
        navigationController?.pushViewController(vc ?? UIViewController(), animated: true)
    }
    
    @IBAction func tappedRecifeButton(_ sender: UIButton) {
    }
    
    @IBAction func tappedParisButton(_ sender: UIButton) {
    }
    
    @IBAction func tappedRomaButton(_ sender: Any) {
    }
    
}
