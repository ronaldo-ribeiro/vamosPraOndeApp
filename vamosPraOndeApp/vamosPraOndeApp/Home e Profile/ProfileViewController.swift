//
//  ProfileViewController.swift
//  vamosPraOndeApp
//
//  Created by Ronaldo Ribeiro on 17/12/22.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileLabel: UILabel!
    
    @IBOutlet weak var iconUserImageView: UIImageView!
    
    @IBOutlet weak var firstNameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoutButton.layer.cornerRadius = 10.0
    }
    
    @IBAction func tappedLogoutButton(_ sender: UIButton) {
//        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
//        for aViewController in viewControllers {
//            if aViewController is ViewController {
//                self.navigationController!.popToViewController(aViewController, animated: true)
//            }
//        }
        
        do {
          try Auth.auth().signOut()
        } catch {
          print("Sign out error")
        }
    }
}
