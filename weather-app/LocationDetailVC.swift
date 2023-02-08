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
    @IBOutlet weak var pageControl: UIPageControl!
    
    var weatherLocation: WeatherLocation!
    var locationIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUserInterface()
    }
    
    private func updateUserInterface() {
        let pageVC = UIApplication.shared.windows.first!.rootViewController as! PageVC
        weatherLocation = pageVC.weatherLocations[locationIndex]
        
        placeLabel.text = weatherLocation.name
        tempLabel.text = "--°"
        descLabel.text = ""
        
        pageControl.numberOfPages = pageVC.weatherLocations.count
        pageControl.currentPage = locationIndex
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
