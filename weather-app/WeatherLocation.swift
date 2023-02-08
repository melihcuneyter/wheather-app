//
//  WeatherLocation.swift
//  weather-app
//
//  Created by Melih Cüneyter on 8.02.2023.
//

import Foundation

class WeatherLocation: Codable {
    var name: String
    var latitude: Double
    var longitude: Double
    
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}
