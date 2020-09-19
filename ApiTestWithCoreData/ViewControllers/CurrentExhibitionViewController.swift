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

class CurrentExhibitionViewController: UIViewController{

    var listenerType: ListenerType = .all
    weak var databaseController: DatabaseProtocol?
    
    var currentExhibition: Exhibition!
    var selectedPlant: Plant?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var trackingSwitch: UISwitch!
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var exhibitionLocation: CLLocationCoordinate2D?
    
    @IBOutlet weak var plantTableView: UITableView!
    var addedPlantList: [Plant] = []
    let CELL_PLANT = "plantCell"
    
    @IBOutlet weak var mapView: MKMapView!
    
    weak var addGeoFenceDelegate: GeoFencingLimitDelegate?
    
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
        
        // Setup the map delegate and add annotation
        mapView.delegate = self
        let location = LocationAnnotation(title: currentExhibition.name!, subtitle: currentExhibition.desc!, lat: currentExhibition.lat, long: currentExhibition.long)
        mapView.addAnnotation(location)
        let zoomRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
        
        // Setup the plant list for the plant table view
        addedPlantList = (databaseController?.getExhibitionPlants(exhibitionName: currentExhibition.name!))! as [Plant]
        
        
        nameLabel.text = currentExhibition?.name
        descriptionLabel.text = currentExhibition?.desc
        
        // Setup the switch and register its target
        trackingSwitch.isOn = currentExhibition.isTracking
        trackingSwitch.addTarget(self, action: #selector(toggleAction(_:)), for: .valueChanged)
        
        plantTableView.delegate = self
        plantTableView.dataSource = self
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
    
    // MARK: - Action selector
    @objc func toggleAction(_ sender: UISwitch){
        switch sender.isOn {
        case true:
            if addGeoFenceDelegate?.geoFencingLimitDelegate() ?? false{
                databaseController?.addExhibitionTracking(exhibition: currentExhibition)
                DisplayMessages.displayAlert(title: "Limit Reached", message: "You are tracking 20 locations already. Please remove one or more to add more.")
            }
        case false:
            databaseController?.removeExhibitionTracking(exhibition: currentExhibition)
        }
    }
    


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editExhibitionSegue"{
            let destination = segue.destination as! EditExhibitionViewController
            destination.currentExhibition = currentExhibition
        } else if segue.identifier == "viewPlantSegue"{
            let destination = segue.destination as! CurrentPlantViewController
            destination.currentPlant = selectedPlant
        }
    }
    

}


// MARK: - CLLocationManager delegate
extension CurrentExhibitionViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            currentLocation = location.coordinate
            let userLocation = CLLocation(latitude: currentLocation!.latitude, longitude: currentLocation!.longitude)
            let exhibitionLocation = CLLocation(latitude: currentExhibition!.lat, longitude: currentExhibition!.long)
            let distanceInMeter = round(userLocation.distance(from: exhibitionLocation))
            distanceLabel.text = "Distance from you: \(distanceInMeter) meters"
            
            let userLocationAnnotation = MKPointAnnotation()
            userLocationAnnotation.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
            userLocationAnnotation.title = "You"
            mapView.addAnnotation(userLocationAnnotation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationManager.startUpdatingLocation()
    }
}

// MARK: - Database Listeners
extension CurrentExhibitionViewController: DatabaseListener{
    func onExhibitionPlantListChange(change: DatabaseChange, exhibitionPlants: [Plant]) {
        // Not called
    }
    
    func onPlantsRecordChange(change: DatabaseChange, plants: [Plant]) {
        // Not called
    }
    
    func onExhibitionRecordChange(change: DatabaseChange, exhibitions: [Exhibition]) {
        // Update the screen when the user edited the exhibition
        currentExhibition = databaseController?.getExhibition(name: currentExhibition.name!)
        nameLabel.text = currentExhibition?.name
        descriptionLabel.text = currentExhibition?.desc
        addedPlantList = (currentExhibition.plants)?.allObjects as! [Plant]
    }
    
}

// MARK: - TableView delegates
extension CurrentExhibitionViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addedPlantList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let addedPlantCell = tableView.dequeueReusableCell(withIdentifier: CELL_PLANT, for: indexPath) as! PlantTableViewCell
        
        let addedPlant = addedPlantList[indexPath.row]
        
        addedPlantCell.commonNameLabel.text = addedPlant.commonName
        addedPlantCell.scienceNameLabel?.text = addedPlant.scientificName
        addedPlantCell.imageView?.image = UIImage(data: addedPlant.image!)
        
        
        return addedPlantCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPlant = addedPlantList[indexPath.row]
        performSegue(withIdentifier: "viewPlantSegue", sender: nil)
    }
    
    
}

// MARK: - MapView Delegate
extension CurrentExhibitionViewController: MKMapViewDelegate{
       
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is LocationAnnotation){
            return nil
        }
        
        //Set the reusable identifier for the annotation
        let identifier = "exhibitionPin"
        var locationPin = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if locationPin == nil{
            locationPin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            locationPin?.canShowCallout = true
        } else {
            locationPin?.annotation = annotation
        }
        
        return locationPin
    }
}
