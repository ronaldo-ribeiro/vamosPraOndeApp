//
//  TabBarController.swift
//  vamosPraOndeApp
//
//  Created by Ronaldo Ribeiro on 28/12/22.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configItems()
        configTabBar()
    }
    
    func configItems() {
        guard let items = tabBar.items else { return }
        items[0].title = "Destinos"
        items[1].title = "Perfil"
    }
    
    func configTabBar() {
        tabBar.layer.borderWidth = 0.2
        tabBar.layer.borderColor = UIColor.black.cgColor
        tabBar.backgroundColor = .white
    }
    

}
