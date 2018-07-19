//
//  MapViewController.swift
//  DataRoutr
//
//  Created by Zukosky,Jonah on 7/19/18.
//  Copyright © 2018 Zukosky,Jonah. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Map Setup
        mapView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        currentLocation = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count != 0 {
            if currentLocation == nil {
                if let location = locations.first {
                    let span = MKCoordinateSpanMake(0.05, 0.05)
                    let region = MKCoordinateRegion(center: location.coordinate, span: span)
                    mapView.setRegion(region, animated: true)
                }
            }
            currentLocation = locations[locations.count - 1]
        }
    }
}
