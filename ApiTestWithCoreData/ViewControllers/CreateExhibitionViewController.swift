//
//  CreateExhibitionViewController.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 13/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import MapKit

class CreateExhibitionViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var plantNumberLabel: UILabel!
    @IBOutlet weak var addedPlantTableView: UITableView!
    
    var lat: Double?
    var long: Double?
    
    var listenerType: ListenerType = .all
    weak var databaseController: DatabaseProtocol?
    var addedPlantList: [Plant] = []
    
    let CELL_PLANT = "addedPlantCell"
    
    var tempExhibition: Exhibition?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Database delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        // TextField delegate
        nameTextField.delegate = self
        descriptionTextField.delegate = self
        
        // Do any additional setup after loading the view.
        mapView.delegate = self
        //Ref:
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        mapView.addGestureRecognizer(longPressGesture)
        // Focus on Royal botanic garden
        let location = LocationAnnotation(title: "Royal Botanic Gardens Victoria", subtitle: "", lat: -37.830184, long: 144.979640, image_url: "")
        let zoomRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 900, longitudinalMeters: 900)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
        
        addedPlantTableView.delegate = self
        addedPlantTableView.dataSource = self
        
        tempExhibition = databaseController?.getExhibition(name: "Temp")
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    // MARK: - Register gesture and add annotation on map
    // Ref:
    @objc func longPress(sender: UIGestureRecognizer){
        if sender.state == .began{
            // Get the location on the view
            let locationInView = sender.location(in: mapView)
            
            // Convert it to location data for the mapview
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            addAnnotationOnMap(location: locationOnMap)
        }
    }
    
    func addAnnotationOnMap(location: CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        // Register the coordinate for saving
        lat = location.latitude
        long = location.longitude
        annotation.title = "New Exhibition"
        annotation.subtitle = ""
        self.mapView.addAnnotation(annotation)
    }
    
    @IBAction func save(_ sender: Any) {
        
        if nameTextField.text != "" && descriptionTextField.text != "" && lat != nil && long != nil && addedPlantList.count >= 3{
            let name = nameTextField.text!
            let description = descriptionTextField.text!
            
            let newExhibition = databaseController?.addExhibition(name: name, desc: description, lat: lat!, long: long!, isTracking: false, image_url: "https://cdn.pixabay.com/photo/2017/05/06/14/13/pathway-2289978_150.jpg")
            
            for thisPlant in addedPlantList{
                newExhibition?.addToPlants(thisPlant)
            }

            navigationController?.popViewController(animated: true)
            return
        }
    
        var errorMsg = "Please make sure all fields are filled:\n"
        if nameTextField.text == ""{
            errorMsg += "- Name must not be empty\n"
        }
        if descriptionTextField.text == ""{
            errorMsg += "- Description of must not be empty\n"
        }
        if lat == nil || long == nil{
            errorMsg += "- Please pin the location\n"
        }
        if addedPlantList.count < 3{
            errorMsg += "- Please add 3 or more plants"
        }
        
        DisplayMessages.displayAlert(title: "Please provide more details", message: errorMsg)
    }

}

// MARK: - MapView Delegate
extension CreateExhibitionViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else{
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

// MARK: - TableView delegates
extension CreateExhibitionViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addedPlantList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let addedPlantCell = tableView.dequeueReusableCell(withIdentifier: CELL_PLANT, for: indexPath)
        
        let addedPlant = addedPlantList[indexPath.row]
        
        addedPlantCell.textLabel?.text = addedPlant.commonName
        addedPlantCell.detailTextLabel?.text = addedPlant.scientificName
        
        return addedPlantCell
    }
    
    
}


// MARK: - Database Listeners
extension CreateExhibitionViewController: DatabaseListener{
    
    func onExhibitionPlantListChange(change: DatabaseChange, exhibitionPlants: [Plant]) {
        addedPlantList = exhibitionPlants
        addedPlantTableView.reloadData()
    }
    
    func onPlantsRecordChange(change: DatabaseChange, plants: [Plant]) {
        // Not called
    }
    
    func onExhibitionRecordChange(change: DatabaseChange, exhibitions: [Exhibition]) {
        // Not called
    }
    
    
}

// MARK: - TextField delegate
extension CreateExhibitionViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
