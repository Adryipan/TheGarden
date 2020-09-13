//
//  CurrentExhibitionViewController.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 13/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class CurrentExhibitionViewController: UIViewController, CLLocationManagerDelegate, DatabaseListener{

    var listenerType: ListenerType = .exhibitions
    weak var databaseController: DatabaseProtocol?
    
    var currentExhibition: Exhibition!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var exhibitionLocation: CLLocationCoordinate2D?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the database controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController

        // Setup the location manager delegate and accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        
        self.exhibitionLocation = CLLocationCoordinate2D(latitude: currentExhibition!.lat, longitude: currentExhibition!.long)
        
        // Check for authorisation status
        let authorisationStatus = CLLocationManager.authorizationStatus()
        if authorisationStatus != .authorizedAlways || authorisationStatus != .authorizedWhenInUse{
            locationManager.requestWhenInUseAuthorization()
        }
        
        // Do any additional setup after loading the view.
        nameLabel.text = currentExhibition?.name
        descriptionLabel.text = currentExhibition?.desc
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        databaseController?.removeListener(listener: self)
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Database Listeners
    
    func onExhibitionPlantListChange(change: DatabaseChange, exhibitionPlants: [Plant]) {
        // Not called
    }
    
    func onPlantsRecordChange(change: DatabaseChange, plants: [Plant]) {
        // Not Called
    }
    
    func onExhibitionRecordChange(change: DatabaseChange, exhibitions: [Exhibition]) {
        // Update the screen when the user edited the exhibition
        currentExhibition = databaseController?.getExhibition(name: currentExhibition.name!)
        nameLabel.text = currentExhibition?.name
        descriptionLabel.text = currentExhibition?.desc
    }
    
    // MARK: - CLLocationManager delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            currentLocation = location.coordinate
            let userLocation = CLLocation(latitude: currentLocation!.latitude, longitude: currentLocation!.longitude)
            let exhibitionLocation = CLLocation(latitude: currentExhibition!.lat, longitude: currentExhibition!.long)
            let distanceInMeter = round(userLocation.distance(from: exhibitionLocation))
            distanceLabel.text = "Distance from you: \(distanceInMeter) meters"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationManager.startUpdatingLocation()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editExhibitionSegue"{
            let destination = segue.destination as! EditExhibitionViewController
            destination.currentExhibition = currentExhibition
        }
    }
    

}
