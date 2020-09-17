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
    
    // MARK: - MapView functionalities
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is LocationAnnotation){
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "LocationAnnotation")
        if annotationView == nil{
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "LocationAnnotation")
            annotationView?.canShowCallout = true
            annotationView?.image = UIImage(named: "tree")!

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
            selectedExhibition = databaseController?.getExhibition(name: (view.annotation?.title)!!)
            databaseController?.removeExhibition(exhibition: selectedExhibition!)
        }
    }
    
    func focusOn(annotation: MKAnnotation){
        mapView.selectAnnotation(annotation, animated: true)
        
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 400, longitudinalMeters: 400)
        
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
            addExhibitionAnnotation(exhibition: thisExhibition)
        }
    }
    
    private func addExhibitionAnnotation(exhibition: Exhibition){
        let location = LocationAnnotation(title: exhibition.name!, subtitle: exhibition.desc!, lat: exhibition.lat, long: exhibition.long)
        mapView.addAnnotation(location)
    }
    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewExhibitionSegue"{
            let destination = segue.destination as! CurrentExhibitionViewController
            destination.currentExhibition = selectedExhibition
        }
    }
    

}

extension MapViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapView.showsUserLocation = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("LocationFound")
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
