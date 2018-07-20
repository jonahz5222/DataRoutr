//
//  MeteoriteViewController.swift
//  DataRoutr
//
//  Created by Zukosky,Jonah on 7/19/18.
//  Copyright © 2018 Zukosky,Jonah. All rights reserved.
//

import UIKit
import MapKit

class MeteoriteViewController: UIViewController {

    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var massLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var coordinatesLabel: UILabel!
    @IBOutlet weak var addRouteButton: UIButton!
    
    var titleText = "Meteorite"
    var classText = "No Class"
    var massText = "No Mass"
    var yearText = "No Year"
    var coordinatesText = "No Coordinates"
    var meteorite = Meteorite()
    var mapView: MKMapView?
    var addRouteButtonIsEnabled = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = titleText
        classLabel.text = "Class: " + classText
        massLabel.text = "Mass: " + massText
        yearLabel.text = "Year: " + yearText
        coordinatesLabel.text = "Coords: " + coordinatesText
        
        if addRouteButtonIsEnabled {
            addRouteButton.isEnabled = true
            addRouteButton.alpha = 1
        }else {
            addRouteButton.isEnabled = false
            addRouteButton.alpha = 0
        }
    }

    @IBAction func addToRoute(_ sender: Any) {
        guard let currentRoute = Singletons.sharedInstance.currentRoute else {return}
        
        if let latitude = Double(meteorite.reclat ?? "0"),
            let longitude = Double(meteorite.reclong ?? "0") {
            createNewRoute(meteoriteLatitude: latitude, meteoriteLongitude: longitude)
//
//            var closestStep = MKRouteStep()
//            var closestIndex: Int
//            for (index,step) in currentRoute.steps.enumerated() {
//                if index == 0 {
//                    closestStep = step
//                    closestIndex = index
//                    continue
//                }
//                let latDelta = abs(step.polyline.coordinate.latitude - latitude)
//                let longDelta = abs(step.polyline.coordinate.longitude - longitude)
//
//                let compiledDelta = latDelta + longDelta
//
//                let closestLatDelta = abs(closestStep.polyline.coordinate.latitude - latitude)
//                let closestLongDelta = abs(step.polyline.coordinate.longitude - longitude)
//
//                let closestCompiledDelta = closestLatDelta + closestLongDelta
//
//                if compiledDelta < closestCompiledDelta {
//                    closestStep = step
//                    closestIndex = index
//                }
//
//                let newPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
//                let newItem = MKMapItem(placemark: newPlacemark)
//
//            }
            
            
        }
    }
    
    func createNewRoute(meteoriteLatitude: Double,meteoriteLongitude: Double) {
        guard let mapView = mapView else {return}
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: mapView.userLocation.coordinate))
        directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: meteoriteLatitude, longitude: meteoriteLongitude)))
        directionRequest.transportType = MKDirectionsTransportType.automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate(completionHandler: { (response, error) in
            guard let response = response else {
                if let error = error {
                    print(error)
                }
                return
            }
            // Create the route
            
            Singletons.sharedInstance.fullRoute = Singletons.sharedInstance.currentRoute
            Singletons.sharedInstance.currentRoute = response.routes[0]
            var rect = Singletons.sharedInstance.currentRoute?.polyline.boundingMapRect
            rect?.size.height += 10000000
            rect?.size.width += 10000000
            rect?.origin.x -= 5000000
            rect?.origin.y -= 5000000
            mapView.removeOverlays(mapView.overlays)
            mapView.add((Singletons.sharedInstance.currentRoute?.polyline)!, level: MKOverlayLevel.aboveRoads)
            mapView.setRegion(MKCoordinateRegionForMapRect(rect!), animated: true)

            
            
            // Load the Meteorites in
            
            
        });
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
