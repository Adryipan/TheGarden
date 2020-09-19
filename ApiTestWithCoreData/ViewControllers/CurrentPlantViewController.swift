//
//  CurrentPlantViewController.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 17/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class CurrentPlantViewController: UIViewController {
    
    var currentPlant: Plant!
    
    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commonNameLabel: UILabel!
    @IBOutlet weak var scienceNameLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var familyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

     //   currentPlant = databaseController?.getPlant(name: currentPlant.commonName!)
        imageView.loadIcon(urlString: currentPlant.image_url ?? "")
        commonNameLabel.text = currentPlant.commonName?.uppercased()
        scienceNameLabel.text = currentPlant.scientificName
        yearLabel.text = "Discovered in year \(currentPlant.year!)"
        familyLabel.text = "Family of \(currentPlant.family!)"
        
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editPlantSegue"{
            let destination = segue.destination as! EditPlantViewController
            destination.currentPlant = currentPlant
        }
    }
    

}
