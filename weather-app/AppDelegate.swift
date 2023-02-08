//
//  AppDelegate.swift
//  weather-app
//
//  Created by Melih Cüneyter on 6.02.2023.
//

import UIKit
import GooglePlaces

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //MARK: - Override Dark Mode each VC.
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = .dark
        }
        
        GMSPlacesClient.provideAPIKey(APIKeys.googlePlacesKey)
        
        return true
    }
}
