//
//  LocationTVC.swift
//  weather-app
//
//  Created by Melih Cüneyter on 8.02.2023.
//

import UIKit

class LocationTVC: UITableViewCell {
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var locationSummaryLabel: UILabel!
    @IBOutlet weak var locationTempLabel: UILabel!
    @IBOutlet weak var locationIconImageView: UIImageView!
    
    var currentWeather: WeatherDetail! {
        didSet {
            locationNameLabel.text = currentWeather.name
            locationSummaryLabel.text = currentWeather.summary
            locationTempLabel.text = " \(currentWeather.temperature)°"
            locationIconImageView.image = UIImage(systemName: currentWeather.dayIcon)
        }
    }
}
