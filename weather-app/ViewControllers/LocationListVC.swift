//
//  LocationListVC.swift
//  weather-app
//
//  Created by Melih Cüneyter on 6.02.2023.
//

import UIKit
import GooglePlaces

final class LocationListVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editBarButton: UIToolbar!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    
    var searchController = UISearchController()
    var resultsViewController: GMSAutocompleteResultsViewController?
    var resultView: UITextView?
    
    var weatherLocations: [WeatherLocation] = []
    var selectedLocationIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        tableView.separatorStyle = .none
        tableView.register(.init(nibName: "LocationTVC", bundle: nil), forCellReuseIdentifier: "LocationTVC")
        
        // MARK: GMSAutoComplete SearchController add NavigationItem and ResultViewController
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController.searchResultsUpdater = resultsViewController
        
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Şehir veya konum arayın."
        navigationItem.searchController = searchController
    }
    
    private func saveLocations() {
         let encoder = JSONEncoder()
         if let encoded = try? encoder.encode(weatherLocations) {
             UserDefaults.standard.set(encoded, forKey: "weatherLocations")
         } else {
             print("Error: Saving Encoded didn't work!")
         }
     }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        selectedLocationIndex = tableView.indexPathForSelectedRow!.row
        saveLocations()
    }
    
    @IBAction func editBarButtonPressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            sender.title = "Edit"
            addBarButton.isEnabled = true
        } else {
            tableView.setEditing(true, animated: true)
            sender.title = "Done"
            addBarButton.isEnabled = false
        }
    }
    
    @IBAction func addBarButtonPressed(_ sender: UIBarButtonItem) {
        // TODO: disabled button when pressed
        present(searchController, animated: true, completion: nil)
    }
}

// MARK: - Tableview Delegate
extension LocationListVC: UITableViewDelegate {
}

// MARK: - Tableview DataSource
extension LocationListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = weatherLocations[indexPath.row].name
        // TODO: Show Location Detail
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            weatherLocations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = weatherLocations[sourceIndexPath.row]
        weatherLocations.remove(at: sourceIndexPath.row)
        weatherLocations.insert(itemToMove, at: destinationIndexPath.row)
    }
    
    // MARK: - Freezing first element
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (indexPath.row != 0 ? true : false)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return (indexPath.row != 0 ? true : false)
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return (proposedDestinationIndexPath.row == 0 ? sourceIndexPath : proposedDestinationIndexPath)
    }
}

// MARK: - AutocompleteResultsViewController Delegate
extension LocationListVC: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {        
        let newLocation = WeatherLocation(name: place.name ?? "unknown place", latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        weatherLocations.append(newLocation)
        tableView.reloadData()
        
        searchController.searchBar.text = ""
        dismiss(animated: true, completion: nil)
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
}

