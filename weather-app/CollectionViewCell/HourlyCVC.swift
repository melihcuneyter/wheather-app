//
//  HourlyCVC.swift
//  weather-app
//
//  Created by Melih Cüneyter on 8.02.2023.
//

import UIKit

class HourlyCVC: UICollectionViewCell {
    @IBOutlet weak var hourlyTimeLabel: UILabel!
    @IBOutlet weak var hourlyIconImageView: UIImageView!
    @IBOutlet weak var hourlyTempLabel: UILabel!
    
    var hourlyWeather: HourlyWeather! {
        didSet {
            hourlyTimeLabel.text = "\(hourlyWeather.hour):00"
            hourlyIconImageView.image = UIImage(systemName: hourlyWeather.hourlyIcon)
            hourlyTempLabel.text = " \(hourlyWeather.hourlyTemperature)°"
        }
    }
}
