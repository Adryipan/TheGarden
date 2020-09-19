//
//  AllExhibitionTableViewController.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 13/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class AllExhibitionTableViewController: UITableViewController {
    
    let SECTION_EXHIBITION = 0
    let SECTION_INFO = 1
    let CELL_EXHIBITION = "exhibitionCell"
    let CELL_INFO = "exhibitionSizeCell"
    
    let API_KEY = "18367910-d1d4d4e596c65c27ea5bec894"
    let REQUEST_STRING = "https://pixabay.com/api/?key="
    
    var allExhibitionList: [Exhibition] = []
    var filteredExhibitionList: [Exhibition] = []
    weak var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .exhibitions
    
    weak var mapViewController: MapViewController?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        // Setup the Sort button on the nav bar
        let sortButton = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(showSortMenu))
        
        navigationItem.leftBarButtonItem = sortButton
        
        // Setup the search controller delegate and view
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Exhibition"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        if (databaseController?.checkExhibition(name: "Temp"))!{
            databaseController?.removeExhibition(exhibition: (databaseController?.getExhibition(name: "Temp"))!)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    // Show the sort option menu
    let sortLauncher = SortLauncher()
    @objc func showSortMenu(){
        sortLauncher.sortItemDelegate = self
        sortLauncher.showSortMenu()
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
            let exhibitionCell = tableView.dequeueReusableCell(withIdentifier: CELL_EXHIBITION, for: indexPath) as! ExhibitionTableViewCell
            
            let exhibition = filteredExhibitionList[indexPath.row]
            
            exhibitionCell.exhibitionImageView.loadIcon(urlString: "https://cdn.pixabay.com/photo/2017/05/06/14/13/pathway-2289978_150.jpg")
            exhibitionCell.nameLabel.text = exhibition.name
            exhibitionCell.descriptionLabel.text = exhibition.desc
            
            return exhibitionCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath)
        
        cell.textLabel?.textColor = .secondaryLabel
        cell.selectionStyle = .none
        if filteredExhibitionList.count > 0{
            cell.textLabel?.text = "\(filteredExhibitionList.count) exhibitions saved"
        }else{
            cell.textLabel?.text = "No exhibition saved"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedExhibition = filteredExhibitionList[indexPath.row]
        let location = LocationAnnotation(title: selectedExhibition.name!, subtitle: selectedExhibition.desc!, lat: selectedExhibition.lat, long: selectedExhibition.long)
        mapViewController?.focusOn(annotation: location)
        if let mapVC = mapViewController{
            splitViewController?.showDetailViewController(mapVC, sender: nil)
        }
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createExhibitionSegue"{
            databaseController?.configureTemp()
        }
   }
    

}

// MARK: - Database listener
extension AllExhibitionTableViewController: DatabaseListener{

    func onExhibitionPlantListChange(change: DatabaseChange, exhibitionPlants: [Plant]) {
        // Not called
    }
    
    func onPlantsRecordChange(change: DatabaseChange, plants: [Plant]) {
        // Not called
    }
    
    func onExhibitionRecordChange(change: DatabaseChange, exhibitions: [Exhibition]) {
        allExhibitionList = exhibitions
        filteredExhibitionList = allExhibitionList
        tableView.reloadData()
        for thisExhibition in allExhibitionList{
            let location = LocationAnnotation(title: thisExhibition.name!, subtitle: thisExhibition.desc!, lat: thisExhibition.lat, long: thisExhibition.long)
            mapViewController?.mapView.addAnnotation(location)
        }
    }
}

// MARK: - Add exhibition delegate
extension AllExhibitionTableViewController: AddExhibitionDelegate{
    func addExhibitionDelegate(newExhibition: Exhibition) -> Bool {
        
        if (databaseController?.getExhibition(name: newExhibition.name!))!.name == "Temp" {
            return false
        }
        
        
        let addedPlantList = databaseController?.getExhibitionPlants(exhibitionName: "Temp")
        if addedPlantList?.count == 0{
            return false
        }
        
        let temp = databaseController?.getExhibition(name: "Temp")
        
        newExhibition.addToPlants((temp?.plants)!)
        return true
    }
    
}

// MARK: - Search Controller Delegate
extension AllExhibitionTableViewController: UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else{
            return
        }
        
        if searchText.count > 0{
            filteredExhibitionList = allExhibitionList.filter({(exhibition: Exhibition) -> Bool in
                guard let exhibitionName = exhibition.name else{
                    return false
                }
                
                return exhibitionName.contains(searchText)
            })
        } else {
            filteredExhibitionList = allExhibitionList
        }
        
        tableView.reloadData()
    }
    
}

// MARK: - Sort Exhibition Delegate
extension AllExhibitionTableViewController: SortDelegate{
    func sortExhibitionDelegate(actionCode: Int) {
        // Sort the array base on the response
        // 0: Ascending and 1: Descending
        switch actionCode {
        case 0:
            filteredExhibitionList = filteredExhibitionList.sorted{
                return $0.name! < $1.name!
            }
            tableView.reloadData()
        case 1:
            filteredExhibitionList = filteredExhibitionList.sorted{
                return $0.name! > $1.name!
            }
            tableView.reloadData()
        default:
            filteredExhibitionList = allExhibitionList
        }
    }
    
    
}
