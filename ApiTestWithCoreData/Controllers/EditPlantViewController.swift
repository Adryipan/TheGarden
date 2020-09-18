//
//  EditPlantViewController.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 14/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class EditPlantViewController: UIViewController {

    var currentPlant: Plant!
    
    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var plantNameLabel: UILabel!
    @IBOutlet weak var scientificNameTextField: UITextField!
    @IBOutlet weak var familyTextField: UITextField!
    @IBOutlet weak var yearDiscoveredTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        plantNameLabel.text = currentPlant.commonName
        scientificNameTextField.text = currentPlant.scientificName
        familyTextField.text = currentPlant.family
        yearDiscoveredTextField.text = currentPlant.year
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
    }
    
    @IBAction func save(_ sender: Any) {
        
        if plantNameLabel.text != "" && scientificNameTextField.text != "" && familyTextField.text != "" && yearDiscoveredTextField.text != ""{
            let commonName = plantNameLabel.text!
            let scienceName = scientificNameTextField.text!
            let family = familyTextField.text!
            let year = yearDiscoveredTextField.text!
            databaseController?.updatePlant(plant: currentPlant, commonName: commonName, scienceName: scienceName, year: year, family: family)

            navigationController?.popViewController(animated: true)
            return
        }

        var errorMsg = "Please ensure all fields are filled:\n"

        if plantNameLabel.text == ""{
            errorMsg += "- Must provide a common name\n"
        }
        if scientificNameTextField.text == ""{
            errorMsg += "- Must provide a science name"
        }
        if familyTextField.text == ""{
            errorMsg += "- Must provide a family\n"
        }
        if yearDiscoveredTextField.text == ""{
            errorMsg += "- Must provide year discovered"
        }

        DisplayMessages.displayAlert(title: "Not all fields filled", message: errorMsg)
        
        
    }


}
