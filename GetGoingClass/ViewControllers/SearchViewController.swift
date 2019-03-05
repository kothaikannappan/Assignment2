//
//  SearchViewController.swift
//  GetGoingClass
//
//  Created by Alla Bondarenko on 2019-01-16.
//  Copyright © 2019 SMU. All rights reserved.
//

import UIKit
import CoreLocation

class SearchViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var filterBtn: UIButton!
    
    // MARK: - Properties
    var searchParameter: String?
    var currentLocation: CLLocationCoordinate2D?
    var rank: String?
    var radius: Double?
    var openNow: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.isHidden = true
        searchTextField.delegate = self
        LocationService.shared.startUpdatingLocation()
        LocationService.shared.delegate = self
    }

    //MARK: - Activity Indicator

    func showActivityIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        searchButton.isEnabled = false
    }

    func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        searchButton.isEnabled = true
    }

    @IBAction func loadLastSavedResults(_ sender: UIButton) {
        guard let places = loadPlacesFromLocalStorage() else {
            presentErrorAlert(message: "No results were previously stored")
            return
        }
        presentSearchResults(places: places)
    }

    @IBAction func presentFilters(_ sender: UIButton) {
//        performSegue(withIdentifier: "FiltersSegue", sender: self)
         FilterService.shared.delegate = self
        guard let filtersViewController = UIStoryboard(name: "Filters", bundle: nil).instantiateViewController(withIdentifier: "FiltersViewController") as? FiltersViewController else { return }
        present(filtersViewController, animated: true, completion: nil)

    }
    
    @IBAction func segmentedObserver(_ sender: UISegmentedControl) {
        print("segmented control option was changed to \(sender.selectedSegmentIndex)")
        if sender.selectedSegmentIndex == 1 {
            LocationService.shared.startUpdatingLocation()
            LocationService.shared.delegate = self
        }
    }

    @IBAction func searchButtonAction(_ sender: UIButton) {
        print("search button was tapped")
        guard let query = searchTextField.text else {
            print("query is nil")
            return
        }

        searchTextField.resignFirstResponder()
        showActivityIndicator()
        
        
        guard let location = currentLocation else { return }
        
        switch segmentControl.selectedSegmentIndex {
        case 0:
            GooglePlacesAPI.requestPlaces(query, rankBy: rank ?? "prominence", radius: radius ?? 0.0, coordinate: location, isOpen: openNow ?? true) { (status, json) in
                print(json ?? "")
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                }
                guard let jsonObj = json else { return }
                let results = APIParser.parseNearbySearchResults(jsonObj: jsonObj)

                self.savePlacesToLocalStorage(places: results)

                if results.isEmpty {
                    // TODO: - Present an alert
                    // On the main thread!
                    DispatchQueue.main.async {
                        self.presentErrorAlert(message: "No results")
                    }
                } else {
                    self.presentSearchResults(places: results)
                }
            }
        case 1:
            GooglePlacesAPI.requestPlacesNearby(for: location, radius: radius ?? 500, query, isOpen: openNow ?? true) { (status, json) in
                print(json ?? "")
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                }
                guard let jsonObj = json else { return }
                let results = APIParser.parseNearbySearchResults(jsonObj: jsonObj)
                self.savePlacesToLocalStorage(places: results)

                if results.isEmpty {
                    // TODO: - Present an alert
                    // On the main thread!
                    DispatchQueue.main.async {
                        self.presentErrorAlert(message: "No results")
                    }
                } else {
                    self.presentSearchResults(places: results)
                }
            }
        default:
            break
        }

    }

    // MARK: - Navigation methods

    func presentSearchResults(places: [PlaceDetails]) {
        guard let searchResultsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchResultsViewController") as? SearchResultsViewController else { return }

        searchResultsViewController.places = places
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(searchResultsViewController, animated: true)
        }
    }

    func presentErrorAlert(title: String = "Error", message: String?) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let okButtonAction = UIAlertAction(title: "Ok",
                                     style: .default,
                                     handler: nil)
        alert.addAction(okButtonAction)
        present(alert, animated: true)
    }

    // MARK: - NSCoding

    func savePlacesToLocalStorage(places: [PlaceDetails]) {
        // save data to the local storage
        NSKeyedArchiver.archiveRootObject(places, toFile: Constants.ArchiveURL.path)
    }

    func loadPlacesFromLocalStorage() -> [PlaceDetails]? {
        // pull data from the local storage
        return NSKeyedUnarchiver.unarchiveObject(withFile: Constants.ArchiveURL.path) as? [PlaceDetails]
    }
}

extension SearchViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
            searchTextField.resignFirstResponder()
            print("textFieldShouldReturn")
            return true
        }
        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == searchTextField {
            searchParameter = textField.text
            print(textField.text ?? "")
        }
    }
}

extension SearchViewController: LocationServiceDelegate {
    func didUpdateLocation(location: CLLocation) {
        print("latitude \(location.coordinate.latitude) longitude \(location.coordinate.longitude)")
        currentLocation = location.coordinate
    }
}
extension SearchViewController: FilterServiceDelegate {
    func applyFilter(rankBy: String?, rad: Double?, open: Bool?) {
        rank = rankBy ?? "prominence"
        radius = rad ?? 0.0
        openNow = open ?? true
        if(rankBy != nil || rad != nil || open != nil){
            filterBtn.setImage(UIImage(named: "filters"), for: UIControl.State.normal)
        } else {
            filterBtn.setImage(UIImage(named: "filtersDefault"), for: UIControl.State.normal)
        }
    }
    
    
}

