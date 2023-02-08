//
//  PageVC.swift
//  weather-app
//
//  Created by Melih Cüneyter on 8.02.2023.
//

import UIKit

class PageVC: UIPageViewController {
    var weatherLocations: [WeatherLocation] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        
        loadLocations()
        setViewControllers([createLocationDetailVC(forPage: 0)], direction: .forward, animated: false, completion: nil)
    }
    
    func loadLocations() {
        // TODO: get user location for the first element in weatherlocations
        guard let locationsEncoded = UserDefaults.standard.value(forKey: "weatherLocations") as? Data else {
            weatherLocations.append(WeatherLocation(name: "Current Location", latitude: 50.0, longitude: 50.0))
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
        
        if weatherLocations.isEmpty {
            // TODO: get user location
        }
    }
    
    func createLocationDetailVC(forPage page: Int) -> LocationDetailVC {
        let detailVC = storyboard!.instantiateViewController(withIdentifier: "LocationDetailVC") as! LocationDetailVC
        detailVC.locationIndex = page
        return detailVC
    }
}

//MARK: - PageVC Delegate
extension PageVC: UIPageViewControllerDelegate {
    
}

//MARK: - PageVC DataSource
extension PageVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let currentViewController = viewController as? LocationDetailVC {
            if currentViewController.locationIndex > 0 {
                return createLocationDetailVC(forPage: currentViewController.locationIndex - 1)
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let currentViewController = viewController as? LocationDetailVC {
            if currentViewController.locationIndex < weatherLocations.count -  1 {
                return createLocationDetailVC(forPage: currentViewController.locationIndex + 1)
            }
        }
        return nil
    }
}
