//
//  EditExhibitionViewController.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 13/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class EditExhibitionViewController: UIViewController {
    
    weak var databaseController: DatabaseProtocol?
    
    var currentExhibition: Exhibition!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var exhibitionNameLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        exhibitionNameLabel.text = currentExhibition.name
        descriptionTextField.text = currentExhibition.desc
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let newDesc = descriptionTextField.text!
        databaseController?.updateExhibition(exhibition: currentExhibition, newDesc: newDesc)
        navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
