//
//  LocationDetailVC.swift
//  weather-app
//
//  Created by Melih Cüneyter on 8.02.2023.
//

import UIKit

class LocationDetailVC: UIViewController {
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    var weatherLocation: WeatherLocation!
    var weatherLocations: [WeatherLocation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if weatherLocation == nil {
            weatherLocation = WeatherLocation(name: "Current Location", latitude: 0.0, longitude: 0.0)
            weatherLocations.append(weatherLocation)
        }
        
        loadLocations()
        updateUserInterface()
        // TODO: fix this.
        navigationController?.isNavigationBarHidden = true
    }
    
    private func loadLocations() {
        guard let locationsEncoded = UserDefaults.standard.value(forKey: "weatherLocations") as? Data else {
//            getLocation()
            return
        }
        
        let decoder = JSONDecoder()
        if let weatherLocations = try? decoder.decode(Array.self, from: locationsEncoded) as [WeatherLocation] {
            self.weatherLocations = weatherLocations
//            self.getDataDetail()
        } else {
//            getLocation()
            print("Error: Couldn't decode data read from UserDefaults.")
        }
    }
    
    private func updateUserInterface() {
        placeLabel.text = weatherLocation.name
        tempLabel.text = "--°"
        descLabel.text = ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! LocationListVC
        destination.weatherLocations = weatherLocations
    }
    
    @IBAction func unwindFromLocalitionListVC(segue: UIStoryboardSegue) {
        let source =  segue.source as! LocationListVC
        weatherLocations = source.weatherLocations
        weatherLocation = weatherLocations[source.selectedLocationIndex]
        updateUserInterface()
    }
}
