//
//  MapViewController.swift
//  GetGoingClass
//
//  Created by Parijat Bandyopadhyay on 04/03/19.
//  Copyright © 2019 SMU. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var places: [PlaceDetails]!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Map View"
        setMapViewCoordinate()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeIt(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func setMapViewCoordinate() {
        mapView.delegate = self
        for place in places {
            guard let coordinate = place.coordinate else { return }
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
        centerMapOnLocation(location: places[0].coordinate!)
        
        // indicates in blue user's current location if available
        mapView.showsUserLocation = true
    }
    
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let radius = 5000
        
        let distance = CLLocationDistance(Double(radius) * 2)
        let region = MKCoordinateRegion.init(center: location, latitudinalMeters: distance, longitudinalMeters: distance)
        
        mapView.setRegion(region, animated: true)
    }
    
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        
        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "reusablePin")
        // allowing to show extra information in the pin view
        view.canShowCallout = true
        // "i" button
        view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        view.pinTintColor = UIColor.blue
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation
        
        let launchingOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeTransit]
        if let coordinate = location?.coordinate {
            location?.mapItem(coordinate: coordinate).openInMaps(launchOptions: launchingOptions)
        }
    }
}


extension MKAnnotation {
    func mapItem(coordinate: CLLocationCoordinate2D) -> MKMapItem {
        let placemark = MKPlacemark(coordinate: coordinate)
        return MKMapItem(placemark: placemark)
    }
}




