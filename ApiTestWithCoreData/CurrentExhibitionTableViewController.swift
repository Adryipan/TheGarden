//
//  CurrentExhibitionTableViewController.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 12/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class CurrentExhibitionTableViewController: UITableViewController, DatabaseListener {

    

    
    
    let SECTION_PLANT = 0
    let SECTION_INFO = 1
    let CELL_PLANT = "plantCell"
    let CELL_INFO = "exhibitionSizeCell"
    
    var currentExhibitionPlantList: [Plant] = []
    weak var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .exhibitions
    weak var currentExhibition: Exhibition?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    // MARK: - Database listener
    func onExhibitionPlantListChange(change: DatabaseChange, exhibitionPlants: [Plant]) {
        currentExhibitionPlantList = exhibitionPlants
        tableView.reloadData()
    }
    
    func onPlantsRecordChange(change: DatabaseChange, plants: [Plant]) {
        // Not called
    }
    
    func onExhibitionRecordChange(change: DatabaseChange, exhibitions: [Exhibition]) {
        // Not called
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_INFO:
            return 1
        case SECTION_PLANT:
            return currentExhibitionPlantList.count
        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == SECTION_PLANT{
            let plantCell = tableView.dequeueReusableCell(withIdentifier: CELL_PLANT, for: indexPath)
            
            let plant = currentExhibitionPlantList[indexPath.row]
            
            plantCell.textLabel?.text = plant.commonName
            plantCell.detailTextLabel?.text = plant.scientificName
            
            return plantCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath)
        
        cell.textLabel?.textColor = .secondaryLabel
        cell.selectionStyle = .none
        if currentExhibitionPlantList.count > 0{
            cell.textLabel?.text = "\(currentExhibitionPlantList.count) plants in this exhibition"
        }else{
            cell.textLabel?.text = "No plant added to this exhibition. Click + to add some"
        }
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == SECTION_PLANT{
            // Delete the row from the data source
            self.databaseController!.removePlantFromExhibition(plant: currentExhibitionPlantList[indexPath.row], exhibition: currentExhibition!)
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    }
    

}
