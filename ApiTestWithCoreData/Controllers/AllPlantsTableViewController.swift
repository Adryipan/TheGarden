//
//  AllPlantsTableViewController.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 12/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class AllPlantsTableViewController: UITableViewController{

    
    
    var listenerType: ListenerType = .plants
    
    let CELL_PLANT = "plantCell"
    let SECTION_PLANT = 0
    let CELL_INFO = "plantCountCell"
    let SECTION_INFO = 1
    
    var allPlants: [Plant] = []
    var filteredPlants: [Plant] = []
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        filteredPlants = allPlants
        
        // Setup the search controller delegate and view
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Plants"
        navigationItem.searchController = searchController
        
        definesPresentationContext = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SECTION_PLANT{
            return filteredPlants.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == SECTION_INFO{
            tableView.deselectRow(at: indexPath, animated: false)
            return
        }
        
        let _ = databaseController?.addPlantToExhibition(plant: filteredPlants[indexPath.row], exhibition: (databaseController?.getExhibition(name: "Temp"))!)
        navigationController?.popViewController(animated: true)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_PLANT{
             let plantCell = tableView.dequeueReusableCell(withIdentifier: CELL_PLANT,for: indexPath) as! PlantTableViewCell
                   let plant = filteredPlants[indexPath.row]
                   
                   plantCell.commonNameLabel.text = plant.commonName
            plantCell.scienceNameLabel.text = plant.scientificName
            if plant.image != nil{
                plantCell.imageView?.image = UIImage(data: plant.image!)
            } else {
                plantCell.imageView?.image = UIImage(named: "tree")
            }
            return plantCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath)
        if filteredPlants.count > 0{
            cell.textLabel?.text = "\(filteredPlants.count) plants found."
        } else {
            cell.textLabel?.text = "Cancel and click + to search from the internet."
        }
        cell.selectionStyle = .none
        return cell
        
    }    
}

// MARK: - Database Listener
extension AllPlantsTableViewController: DatabaseListener{
    func onExhibitionPlantListChange(change: DatabaseChange, exhibitionPlants: [Plant]) {
        // Not called
    }

    func onPlantsRecordChange(change: DatabaseChange, plants: [Plant]) {
        allPlants = plants
        updateSearchResults(for: navigationItem.searchController!)
    }

    func onExhibitionRecordChange(change: DatabaseChange, exhibitions: [Exhibition]) {
        // Not called
    }
}

// MARK: - Search Controller Delegate
extension AllPlantsTableViewController: UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else{
            return
        }
        
        if searchText.count > 0{
            filteredPlants = allPlants.filter({(plant: Plant) -> Bool in
                guard let commonName = plant.commonName else{
                    return false
                }
                
                guard let scientificName = plant.scientificName else{
                    return false
                }
                
                return commonName.lowercased().contains(searchText) || scientificName.lowercased().contains(searchText)
            })
        } else {
            filteredPlants = allPlants
        }
        
        tableView.reloadData()
    }
    
}
