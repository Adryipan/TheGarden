//
//  MapViewController.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 13/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, DatabaseListener, MKMapViewDelegate {
 
    var listenerType: ListenerType = .exhibitions
    var allExhibitionList: [Exhibition] = []
    weak var databaseController: DatabaseProtocol?
    
    let locationManager: CLLocationManager = CLLocationManager()
    
    var selectedExhibition: Exhibition?
    var geoFencingCount = 0
      
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mapView.delegate = self
        
        // Get all exhibitions from the database
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        // Focus on Royal botanic garden
        let location = LocationAnnotation(title: "Royal Botanic Gardens Victoria", subtitle: "", lat: -37.830184, long: 144.979640)
        let zoomRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 900, longitudinalMeters: 900)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
        
        locationManager.delegate = self
        mapView.showsUserLocation = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    // MARK: - Geofencing
    func region(with location: LocationAnnotation) -> CLCircularRegion{
        let region = CLCircularRegion(center: location.coordinate, radius: 10, identifier: location.title!)
        
        region.notifyOnExit = true
        region.notifyOnExit = true
        
        return region
    }
    
    func startMonitor(location: LocationAnnotation){
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self){
            displayMessage(title: "Geofencing failure", message: "This device does nto support Geofencing.")
        }
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways{
            displayMessage(title: "Location Permission warning", message: "Please allow the application to always access location information for Geofencing function.")
        }
        
        let fence = region(with: location)
        locationManager.startMonitoring(for: fence)
        geoFencingCount += 1
    }
    
    func stopMonitor(location: LocationAnnotation) {
        for region in locationManager.monitoredRegions{
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == location.title else{
                continue
            }
            locationManager.stopMonitoring(for: circularRegion)
            geoFencingCount -= 1
        }
    }
    
    
    // MARK: - MapView functionalities
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is LocationAnnotation){
            return nil
        }
        
        //Ref:
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "LocationAnnotation")
        if annotationView == nil{
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "LocationAnnotation")
            annotationView?.canShowCallout = true
//            annotationView?.image = UIImage(named: "tree")!

            let deleteButton = UIButton(type: .custom) as UIButton
            deleteButton.frame.size.width = 44
            deleteButton.frame.size.height = 44
            deleteButton.backgroundColor = UIColor.red
            let trashIcon = UIImage(systemName: "trash", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
            let tintedImage = trashIcon?.withRenderingMode(.alwaysTemplate)
            deleteButton.setImage(tintedImage, for: .normal)
            deleteButton.tintColor = .white
            
            let infoButton = UIButton(type: .detailDisclosure)

            annotationView?.leftCalloutAccessoryView = deleteButton
            annotationView?.rightCalloutAccessoryView = infoButton
            
            
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let clickedBtn = control as! UIButton
        
        if clickedBtn.buttonType == .detailDisclosure{
            // Perform segue to the exhibition detail screen
            selectedExhibition = databaseController?.getExhibition(name: (view.annotation?.title)!!)
            performSegue(withIdentifier: "viewExhibitionSegue", sender: nil)
        } else {
            // The delete button is clicked and remove the exhibition
            stopMonitor(location: view.annotation as! LocationAnnotation)
            selectedExhibition = databaseController?.getExhibition(name: (view.annotation?.title)!!)
            databaseController?.removeExhibition(exhibition: selectedExhibition!)
        }
    }
    
    func focusOn(annotation: MKAnnotation){
        mapView.selectAnnotation(annotation, animated: true)
        
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
    }
    
    // MARK: - Database listeners
    
    func onExhibitionPlantListChange(change: DatabaseChange, exhibitionPlants: [Plant]) {
        // Not called
    }
    
    func onPlantsRecordChange(change: DatabaseChange, plants: [Plant]) {
        // Not called
    }
    
    func onExhibitionRecordChange(change: DatabaseChange, exhibitions: [Exhibition]) {
        allExhibitionList = exhibitions
        mapView.removeAnnotations(mapView.annotations)
        for thisExhibition in allExhibitionList{
            let location = addExhibitionAnnotation(exhibition: thisExhibition)
            stopMonitor(location: location)
            if thisExhibition.isTracking{
                startMonitor(location: location)
            }
        }
        
    }
    
    private func addExhibitionAnnotation(exhibition: Exhibition) -> LocationAnnotation{
        let location = LocationAnnotation(title: exhibition.name!, subtitle: exhibition.desc!, lat: exhibition.lat, long: exhibition.long)
        mapView.addAnnotation(location)
        return location
    }
    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewExhibitionSegue"{
            let destination = segue.destination as! CurrentExhibitionViewController
            destination.currentExhibition = selectedExhibition
            destination.addGeoFenceDelegate = self
        }
    }
    
    func displayMessage(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    

}

extension MapViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapView.showsUserLocation = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        let userLocationAnnotation = MKPointAnnotation()
        userLocationAnnotation.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
        userLocationAnnotation.title = "You"
        mapView.addAnnotation(userLocationAnnotation)
    }
    
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        print("Fail to location user with error: \(error)")
    }
}


extension MapViewController: GeoFencingLimitDelegate{
    func geoFencingLimitDelegate() -> Bool {
        return geoFencingCount + 1 <= 20
    }
}
