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

class MapViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var routeButton: UIButton!
    @IBOutlet weak var zoomButton: UIButton!
    @IBOutlet weak var beginButton: UIButton!
    @IBOutlet weak var destinationLocationField: UITextField!
    @IBOutlet weak var mapNavigationItem: UINavigationItem!
    
    let locationManager: CLLocationManager = CLLocationManager()
    let geoCoder = CLGeocoder()
    var currentLocation: CLLocation?
    let meteorites = Meteorite.retrieve()
    var originalRouteButtonColor = UIColor()
    var routeButtonPressed = false
    var beginButtonPressed = false
    var fromTextFieldEnter = false
    
    var selectedMeteorite: Meteorite?
    var currentRoute: MKRoute?
    
    var activityIndicator = UIActivityIndicatorView()
    var indicatorLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Map Setup
        mapView.showsUserLocation = true
        mapView.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        currentLocation = nil
        
        // Button Setup
        originalRouteButtonColor = routeButton?.backgroundColor ?? UIColor.green
        routeButton.layer.cornerRadius = 10
        routeButton.clipsToBounds = true
        zoomButton.layer.cornerRadius = 10
        zoomButton.clipsToBounds = true
        zoomButton.alpha = 0
        beginButton.layer.cornerRadius = 10
        beginButton.clipsToBounds = true
        beginButton.alpha = 0
        
        // Title Setup
        self.tabBarController?.navigationItem.title="MeteoRoute"
        
        // Field Setup
        destinationLocationField.delegate = self
        destinationLocationField.clearButtonMode = .whileEditing
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func routeButtonPressed(_ sender: Any) {
        destinationLocationField.resignFirstResponder()
        createRoute()
    }
    
    func createRoute() {
        
        if routeButtonPressed == false {
            if let destinationLocation = destinationLocationField.text {
                if !destinationLocation.isEmpty {
                    if let startingLocationEncoded = locationManager.location {
                        
                        // Toggle Go Button
                        fromTextFieldEnter = false
                        routeButtonPressed = true
                        routeButton.backgroundColor = UIColor.red
                        routeButton.setTitle("Clear", for: .normal)
                        destinationLocationField.isEnabled = false
                        destinationLocationField.alpha = 0.6
                        
                        zoomButton.isEnabled = true
                        zoomButton.alpha = 1
                        beginButton.isEnabled = true
                        beginButton.alpha = 1
                        
                        // Convert String to CLLocation
                        geoCoder.geocodeAddressString(destinationLocation) { (placemarks, error) in
                            guard let placemarks = placemarks, let destinationLocation = placemarks.first?.location
                                else {return}
                            self.activityIndicator("Generating Route")
                            let destinationLocationEncoded = destinationLocation
                            
                            let directionRequest = MKDirectionsRequest()
                            directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: startingLocationEncoded.coordinate))
                            directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationLocationEncoded.coordinate))
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
                                Singletons.sharedInstance.currentRoute = response.routes[0]
                                Singletons.sharedInstance.fullRoute = response.routes[0]
                                
                                DispatchQueue.main.async {
                                    var rect = Singletons.sharedInstance.currentRoute?.polyline.boundingMapRect
                                    rect?.size.height += 10000000
                                    rect?.size.width += 10000000
                                    rect?.origin.x -= 5000000
                                    rect?.origin.y -= 5000000
                                    self.mapView.add((Singletons.sharedInstance.currentRoute?.polyline)!, level: MKOverlayLevel.aboveRoads)
                                    self.mapView.setRegion(MKCoordinateRegionForMapRect(rect!), animated: true)
                                    self.zoomButton.alpha = 1
                                    self.beginButton.alpha = 1
                                }
                                
                                
                                // Load the Meteorites in
                                for meteorite in self.meteorites {
                                    
                                    let annotation = MeteoriteAnnotation(meteorite: meteorite)
                                    let annotationLatitude = annotation.coordinate.latitude
                                    let annotationLongitude = annotation.coordinate.longitude
                                    
                                    for step in (Singletons.sharedInstance.currentRoute?.steps)! {
                                        let stepLatitude = step.polyline.coordinate.latitude
                                        let stepLongitude = step.polyline.coordinate.longitude
                                        if stepLatitude-1.0...stepLatitude+1.0 ~= annotationLatitude &&
                                            stepLongitude-1.0...stepLongitude+1.0 ~= annotationLongitude {
                                            if Singletons.sharedInstance.selectedMeteorites.contains(where: { $0.id == annotation.meteorite.id }) {
                                            }else {
                                                Singletons.sharedInstance.selectedMeteorites.append(annotation.meteorite)
                                                self.mapView.addAnnotation(annotation)
                                            }
                                        }
                                    }
                                }
                                
                            });
                        }
                    }
                }
            }
        } else {
            routeButtonPressed = false
            routeButton.setTitle("Go", for: .normal)
            destinationLocationField.text = ""
            destinationLocationField.isEnabled = true
            destinationLocationField.alpha = 1
            routeButton.backgroundColor = originalRouteButtonColor
            Singletons.sharedInstance.currentRoute = nil
            Singletons.sharedInstance.fullRoute = nil
            zoomButton.isEnabled = false
            zoomButton.alpha = 0
            beginButton.isEnabled = false
            beginButton.alpha = 0
            mapView.removeOverlays(mapView.overlays)
            mapView.removeAnnotations(mapView.annotations)
            Singletons.sharedInstance.selectedMeteorites = []
            let span = MKCoordinateSpanMake(0.1, 0.1)
            let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        fromTextFieldEnter = true
        createRoute()
        self.resignFirstResponder()
        return false
    }
    
    func activityIndicator(_ title: String) {
        
        //indicatorLabel.removeFromSuperview()
        activityIndicator.removeFromSuperview()
//        effectView.removeFromSuperview()
        
//        indicatorLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 160, height: 46))
//        indicatorLabel.text = title
//        indicatorLabel.font = .systemFont(ofSize: 14, weight: .medium)
//        indicatorLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
        
//        effectView.frame = CGRect(x: view.frame.midX - indicatorLabel.frame.width/2, y: view.frame.midY - indicatorLabel.frame.height/2 , width: 160, height: 46)
//        effectView.layer.cornerRadius = 15
//        effectView.layer.masksToBounds = true
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicator.startAnimating()
        
//        effectView.addSubview(activityIndicator)
//        effectView.addSubview(indicatorLabel)
//        view.addSubview(effectView)
        view.addSubview(activityIndicator)
    }
    
    @IBAction func handleDefaultZoom(_ sender: Any) {
        guard let currentRoute = Singletons.sharedInstance.currentRoute else {return}
        
        var rect = currentRoute.polyline.boundingMapRect
        rect.size.height += 10000000
        rect.size.width += 10000000
        rect.origin.x -= 5000000
        rect.origin.y -= 5000000
        mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        mapView.deselectAnnotation(mapView.selectedAnnotations.first, animated: true)
    }
    
    @IBAction func handleBeginRoute(_ sender: Any) {
       
        if beginButtonPressed == false {
            guard let currentRoute = Singletons.sharedInstance.currentRoute else {return}
            if currentRoute != Singletons.sharedInstance.fullRoute {
                beginButtonPressed = true
                beginButton.setTitle("Restore Route", for: .normal)
            }
            
            if (UIApplication.shared.canOpenURL(URL(string:"http://maps.apple.com")!)) {
                UIApplication.shared.openURL(URL(string:
                    "http://maps.apple.com:/?saddr=\(currentRoute.steps.first?.polyline.coordinate.latitude ?? 0),\(currentRoute.steps.first?.polyline.coordinate.longitude ?? 0)&daddr=\(currentRoute.steps.last?.polyline.coordinate.latitude ?? 0),\(currentRoute.steps.last?.polyline.coordinate.longitude ?? 0)&dirflg=d")!)
            }
        }else {
            guard let fullRoute = Singletons.sharedInstance.fullRoute else {
                beginButtonPressed = false
                return
            }
            beginButtonPressed = false
            if currentRoute?.steps.last?.polyline.coordinate.latitude != fullRoute.steps.last?.polyline.coordinate.latitude {
                beginButton.setTitle("Begin Route", for: .normal)
                //Singletons.sharedInstance.currentRoute = Singletons.sharedInstance.fullRoute
                
                let directionRequest = MKDirectionsRequest()
                directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: mapView.userLocation.coordinate))
                directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: (Singletons.sharedInstance.fullRoute?.steps.last?.polyline.coordinate)!))
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
                    
                    Singletons.sharedInstance.fullRoute = response.routes[0]
                    Singletons.sharedInstance.currentRoute = response.routes[0]
                    var rect = Singletons.sharedInstance.currentRoute?.polyline.boundingMapRect
                    rect?.size.height += 10000000
                    rect?.size.width += 10000000
                    rect?.origin.x -= 5000000
                    rect?.origin.y -= 5000000
                    self.mapView.removeOverlays(self.mapView.overlays)
                    self.mapView.add((Singletons.sharedInstance.currentRoute?.polyline)!, level: MKOverlayLevel.aboveRoads)
                    self.mapView.setRegion(MKCoordinateRegionForMapRect(rect!), animated: true)
                    
 
                });
            }
            
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = sender as? MapViewController {
            if let meteorite = vc.selectedMeteorite {
                if (segue.identifier == "meteoriteSegue" ){
                    let destination = segue.destination as! MeteoriteViewController
                    
                    if  let meteoriteTitle = meteorite.name,
                        let meteoriteClass = meteorite.recclass,
                        let meteoriteMass = meteorite.mass,
                        let meteoriteYear = meteorite.year,
                        let meteoriteCoordinates = meteorite.GeoLocation,
                        let meteoriteId = meteorite.id {
                        destination.titleText = meteoriteTitle + " " + meteoriteId
                        destination.classText = meteoriteClass
                        destination.massText = meteoriteMass
                        destination.yearText = meteoriteYear
                        destination.coordinatesText = meteoriteCoordinates
                        destination.meteorite = meteorite
                        destination.mapView = mapView
                        destination.addRouteButtonIsEnabled = true
                    }
                    
                    
                }
            }
        }
    }
    
    @objc func meteoriteDetail() {
        if selectedMeteorite != nil {
            performSegue(withIdentifier: "meteoriteSegue", sender: self)
        }
    }
}

class MeteoriteAnnotation: NSObject, MKAnnotation {
    var meteorite: Meteorite
    var coordinate: CLLocationCoordinate2D
    
    init(meteorite: Meteorite) {
        self.meteorite = meteorite
        self.coordinate = CLLocationCoordinate2D(latitude: Double(meteorite.reclat!) ?? 0, longitude: Double(meteorite.reclong!) ?? 0)
        super.init()
    }
    
    var title: String? {
        return meteorite.name
    }
}


extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 3
        return renderer
    }
    
    //Handle Selection of Pin
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        
        for annotationDeselect in mapView.annotations {
            if let annotation = view.annotation {
                if annotationDeselect.isEqual(annotation){
                    mapView.view(for: annotation)?.isEnabled = true
                }else {
                    if let notSelfAnnotation = annotationDeselect as? MeteoriteAnnotation {
                        mapView.view(for: notSelfAnnotation)?.isHidden = true
                    }
                }
            }
        }
        
        if let annotation = view.annotation as? MeteoriteAnnotation {
            
            selectedMeteorite = annotation.meteorite
            if let stringLatitude = selectedMeteorite?.reclat, let stringLongitude = selectedMeteorite?.reclong {
                if let latitude = Double(stringLatitude), let longitude = Double(stringLongitude) {
                    mapView.setCenter(CLLocationCoordinate2D(latitude: latitude, longitude: longitude), animated: true)
                    
                    let span = MKCoordinateSpanMake(1.5, 1.5)
                    //Only zoom in, not zoom out
                    if span.latitudeDelta < mapView.region.span.latitudeDelta {
                        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
                        mapView.setRegion(region, animated: true)
                    }
                }
            }
        }
    }
    
    //Handle Deselection of Pin
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        selectedMeteorite = nil
        for annotationSelect in mapView.annotations {
            if let annotation = view.annotation {
                mapView.view(for: annotationSelect)?.isEnabled = true
                mapView.view(for: annotationSelect)?.isHidden = false
                mapView.view(for: annotation)?.isEnabled = true
                mapView.view(for: annotation)?.isHidden = false
            }
            
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        if let meteoriteAnnotation = annotation as? MeteoriteAnnotation {
            let reuseId = "marker"
            let markerView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            markerView.titleVisibility = .visible
            markerView.canShowCallout = true
        
            let discloseButton = UIButton.init(type: .detailDisclosure)
            discloseButton.addTarget(self, action: #selector(self.meteoriteDetail), for: .touchUpInside)
            markerView.rightCalloutAccessoryView = discloseButton
            
            
            return markerView
        }
        return nil
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

extension MKMapView {
    func animatedZoom(zoomRegion:MKCoordinateRegion, duration:TimeInterval) {
        MKMapView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.setRegion(zoomRegion, animated: true)
        }, completion: nil)
    }
}
