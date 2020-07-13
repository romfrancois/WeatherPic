//
//  LocationListViewController.swift
//  WeatherPic
//
//  Created by Romain Francois on 05/07/2020.
//  Copyright © 2020 Romain Francois. All rights reserved.
//

import UIKit
import GooglePlaces

class LocationListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    var weatherLocations: [WeatherLocation] = []
    var selectedLocationIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func saveLocations() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(weatherLocations) {
            UserDefaults.standard.set(encoded, forKey: "weatherLocations")
        } else {
            print("ERROR: Saving encoded didn't work!")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        selectedLocationIndex = tableView.indexPathForSelectedRow!.row
        
        saveLocations()
    }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
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
    
    @IBAction func addLocationPressed(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self

        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
    }
    
}

extension LocationListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weatherLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = weatherLocations[indexPath.row].name
        cell.detailTextLabel?.text = "Lat: \(weatherLocations[indexPath.row].latitude), Long: \(weatherLocations[indexPath.row].longitude)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            weatherLocations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemtoMove = weatherLocations[sourceIndexPath.row]
        weatherLocations.remove(at: sourceIndexPath.row)
        weatherLocations.insert(itemtoMove, at: destinationIndexPath.row)
    }
    
    // MARK: - tableView methods to freeze the first cell
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0 ? true : false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0 ? true : false
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return proposedDestinationIndexPath.row == 0 ? sourceIndexPath : proposedDestinationIndexPath
    }
}

extension LocationListViewController: GMSAutocompleteViewControllerDelegate {

  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    let newLocation = WeatherLocation(name: place.name ?? "unknown place", latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
    weatherLocations.append(newLocation)
    tableView.reloadData()
    
    dismiss(animated: true, completion: nil)
  }

  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }

  // User canceled the operation.
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    dismiss(animated: true, completion: nil)
  }

//  // Turn the network activity indicator on and off again.
//  func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
//    UIApplication.shared.isNetworkActivityIndicatorVisible = true
//  }
//
//  func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
//    UIApplication.shared.isNetworkActivityIndicatorVisible = false
//  }

}
