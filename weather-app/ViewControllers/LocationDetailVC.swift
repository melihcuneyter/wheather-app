//
//  LocationDetailVC.swift
//  weather-app
//
//  Created by Melih Cüneyter on 8.02.2023.
//

import UIKit
import CoreLocation

final class LocationDetailVC: UIViewController {
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var weatherDetail: WeatherDetail!
    var locationIndex = 0
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearUI()
        
        tableView.register(.init(nibName: "DailyTVC", bundle: nil), forCellReuseIdentifier: "DailyTVC")
        collectionView.register(.init(nibName: "HourlyCVC", bundle: nil), forCellWithReuseIdentifier: "HourlyCVC")
        
        tableView.layer.cornerRadius = 10
        collectionView.layer.cornerRadius = 10
        
        if locationIndex == 0 {
            getLocation()
        }
        
        updateUI()
    }
    
    private func updateUI() {
        let pageVC = UIApplication.shared.windows.first!.rootViewController as! PageVC
        let weatherLocation = pageVC.weatherLocations[locationIndex]
        weatherDetail = WeatherDetail(name: weatherLocation.name, latitude: weatherLocation.latitude, longitude: weatherLocation.longitude)
        
        pageControl.numberOfPages = pageVC.weatherLocations.count
        pageControl.currentPage = locationIndex
        
        weatherDetail.getData {
            DispatchQueue.main.async {
                self.placeLabel.text = self.weatherDetail.name
                self.tempLabel.text = "\(self.weatherDetail.temperature)°"
                self.descLabel.text = self.weatherDetail.summary.uppercased()
                self.collectionView.reloadData()
                self.tableView.reloadData()
            }
        }
    }
    
    private func clearUI() {
        placeLabel.text = ""
        tempLabel.text = "--°"
        descLabel.text = ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! LocationListVC
        let pageVC = UIApplication.shared.windows.first!.rootViewController as! PageVC
        
        destination.weatherLocations = pageVC.weatherLocations
    }
    
    @IBAction func unwindFromLocalitionListVC(segue: UIStoryboardSegue) {
        let source =  segue.source as! LocationListVC
        locationIndex = source.selectedLocationIndex
        
        let pageVC = UIApplication.shared.windows.first!.rootViewController as! PageVC
        pageVC.weatherLocations = source.weatherLocations
        pageVC.setViewControllers([pageVC.createLocationDetailVC(forPage: locationIndex)], direction: .forward, animated: false, completion: nil)
    }
    
    @IBAction func pageControlTapped(_ sender: UIPageControl) {
        let pageVC = UIApplication.shared.windows.first!.rootViewController as! PageVC
        
        var direction: UIPageViewController.NavigationDirection = .forward
        
        if sender.currentPage < locationIndex {
            direction = .reverse
        }
        
        pageVC.setViewControllers([pageVC.createLocationDetailVC(forPage: sender.currentPage)], direction: direction, animated: true, completion: nil)
    }
}

// MARK: - TableView Delegate
extension LocationDetailVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - TableView Datasource
extension LocationDetailVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherDetail.dailyWeatherData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DailyTVC", for: indexPath) as! DailyTVC
        cell.dailyWeather = weatherDetail.dailyWeatherData[indexPath.row]
        return cell
    }
}

// MARK: - CollectionView Delegate
extension LocationDetailVC: UICollectionViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

// MARK: - CollectionView Datasource
extension LocationDetailVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherDetail.hourlyWeatherData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let hourlyCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyCVC", for: indexPath) as! HourlyCVC
        hourlyCell.hourlyWeather = weatherDetail.hourlyWeatherData[indexPath.row]
        return hourlyCell
    }
}

// MARK: - CLLoctionManager Delegate
extension LocationDetailVC: CLLocationManagerDelegate {
    func getLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleAuthenticalStatus(status: status)
    }
    
    func handleAuthenticalStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("ERROR!")
        case .denied:
            showAlertToPrivacySettings(title: "User has not authorized location services", message: "Change device settings this app")
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            print("")
        }
    }
    
    func showAlertToPrivacySettings(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            print("Error from openSettingsURLString")
            return
        }
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last ?? CLLocation()
        print("Current Location is: \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            var locationName = ""
            if placemarks != nil {
                let placemark = placemarks?.last
                locationName = placemark?.name ?? "Unknown"
            } else {
                print("ERROR: \(String(describing: error?.localizedDescription))")
                locationName = "Could not find location"
            }
            
            let pageVC = UIApplication.shared.windows.first!.rootViewController as! PageVC
            pageVC.weatherLocations[self.locationIndex].name = locationName
            pageVC.weatherLocations[self.locationIndex].latitude = currentLocation.coordinate.latitude
            pageVC.weatherLocations[self.locationIndex].longitude = currentLocation.coordinate.longitude
            self.updateUI()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}
