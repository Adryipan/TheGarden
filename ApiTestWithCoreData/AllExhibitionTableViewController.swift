//
//  AllExhibitionTableViewController.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 13/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class AllExhibitionTableViewController: UITableViewController, DatabaseListener {
    
    let SECTION_EXHIBITION = 0
    let SECTION_INFO = 1
    let CELL_EXHIBITION = "exhibitionCell"
    let CELL_INFO = "exhibitionSizeCell"
    
    var allExhibitionList: [Exhibition] = []
    weak var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .exhibitions
    
    weak var mapViewController: MapViewController?
    

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
        // Not called
    }
    
    func onPlantsRecordChange(change: DatabaseChange, plants: [Plant]) {
        // Not called
    }
    
    func onExhibitionRecordChange(change: DatabaseChange, exhibitions: [Exhibition]) {
        allExhibitionList = exhibitions
        tableView.reloadData()
        for thisExhibition in allExhibitionList{
            let location = LocationAnnotation(title: thisExhibition.name!, subtitle: thisExhibition.desc!, lat: thisExhibition.lat, long: thisExhibition.long)
            mapViewController?.mapView.addAnnotation(location)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_INFO:
            return 1
        case SECTION_EXHIBITION:
            return allExhibitionList.count
        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == SECTION_EXHIBITION{
            let exhibitionCell = tableView.dequeueReusableCell(withIdentifier: CELL_EXHIBITION, for: indexPath)
            
            let exhibition = allExhibitionList[indexPath.row]
            
            exhibitionCell.textLabel?.text = exhibition.name
            exhibitionCell.detailTextLabel?.text = exhibition.desc
            
            return exhibitionCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath)
        
        cell.textLabel?.textColor = .secondaryLabel
        cell.selectionStyle = .none
        if allExhibitionList.count > 0{
            cell.textLabel?.text = "\(allExhibitionList.count) exhibitions saved"
        }else{
            cell.textLabel?.text = "No exhibition saved"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedExhibition = allExhibitionList[indexPath.row]
        let location = LocationAnnotation(title: selectedExhibition.name!, subtitle: selectedExhibition.desc!, lat: selectedExhibition.lat, long: selectedExhibition.long)
        mapViewController?.focusOn(annotation: location)
        if let mapVC = mapViewController{
            splitViewController?.showDetailViewController(mapVC, sender: nil)
        }
        
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createExhibitionSegue"{
            databaseController?.configureTemp()
        }
   }
    

}
