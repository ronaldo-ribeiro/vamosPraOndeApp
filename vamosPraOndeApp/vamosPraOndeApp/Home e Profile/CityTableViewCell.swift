//
//  CityTableViewCell.swift
//  vamosPraOndeApp
//
//  Created by Ronaldo Ribeiro on 12/01/23.
//

import UIKit

class CityTableViewCell: UITableViewCell {

    @IBOutlet weak var cityNameLabel: UILabel!
    
    @IBOutlet weak var timeRemaingLabel: UILabel!
    
    static let identifier: String = "CityTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupCell(city: CityModel) {
        cityNameLabel.text = city.cityName
        timeRemaingLabel.text = city.timeRemaing
    }
}
