//
//  HomeViewController.swift
//  vamosPraOndeApp
//
//  Created by Ronaldo Ribeiro on 17/12/22.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    var cityList: [CityModel] = [CityModel(cityName: "São Paulo", timeRemaing: "Em 2 meses e 18 dias")]
    
    @IBOutlet weak var addDestinationButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CityTableViewCell.nib(), forCellReuseIdentifier: CityTableViewCell.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.hidesBackButton = true
    }
    
    @IBAction func tappedAddDestinationButton(_ sender: UIButton) {
        let vc = UIStoryboard(name: "NewDestinationViewController", bundle: nil).instantiateViewController(withIdentifier: "NewDestinationViewController") as? NewDestinationViewController
//        vc?.delegate = self
        navigationController?.pushViewController(vc ?? UIViewController(), animated: true)
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CityTableViewCell.identifier, for: indexPath) as? CityTableViewCell
        cell?.setupCell(city: cityList[indexPath.row])
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

//extension HomeViewController: NewDestinationViewControllerDelegate {
//    func didSaveCity(city: String) {
//        let newCity = CityModel(cityName: city, timeRemaing: "")
//        cityList.append(newCity)
//        tableView.reloadData()
//    }
//}
